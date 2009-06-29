#!/usr/bin/env ruby -wKU

module JEdI
  class Program
    G  = 6.67428 * 10 ** -11
    M  = 6 * 10 ** 24
    GM = G * M
    
    def self.subclasses
      @subclasses ||= Array.new
    end
    
    def self.inherited(program)
      subclasses << program
    end
    
    def self.for_configuration(configuration)
      subclasses.find { |program|
        configuration / 1000 == program::CONFIGURATION
      }
    end
    
    def self.binary_path
      PROBLEMS_DIR + "bin#{const_get(:CONFIGURATION)}.obf"
    end
    
    def initialize(configuration, options = Hash.new)
      @vm            = VM.new(self.class.binary_path, options)
      @configuration = configuration
      @score         = nil
      @fuel          = nil
      @x             = nil
      @y             = nil

      @initial_radius = nil
      @delta_v        = nil
      @delta_v_prime  = nil
      @time_to_prime  = nil
    end
    
    attr_reader :score
    
    def run
      @vm.configure(@configuration)
      loop do
        @vm.loop
        update_satellite_statistics
        break if @score.nonzero?
        adjust_actuators
        @vm.update
      end
      @vm.finish
    end
    
    private
    
    def update_satellite_statistics
      @score = @vm.output_ports[SCORE_OUTPUT_PORT]
      @fuel  = @vm.output_ports[FUEL_OUTPUT_PORT]
      @x     = @vm.output_ports[X_PORT]
      @y     = @vm.output_ports[Y_PORT]
    end
    
    def thrust(x, y)
      @vm.write_input(X_PORT, x)
      @vm.write_input(Y_PORT, y)
    end
      
    def calculate_hohmann_transfer
      return if @delta_v and @delta_v_prime
      
      @initial_radius = Math.sqrt(@x ** 2 + @y ** 2)
      
      @delta_v        = Math.sqrt(GM / @initial_radius) *
                        ( Math.sqrt( 2 * @target_radius /
                                     (@initial_radius + @target_radius) ) - 1 )
      @delta_v_prime  = Math.sqrt(GM / @target_radius) *
                        ( 1 - Math.sqrt( 2 * @initial_radius /
                                        (@initial_radius + @target_radius) ) )
      @time_to_prime  = ( Math::PI *
                          Math.sqrt( (@initial_radius + @target_radius) ** 3 /
                                     (8 * GM) ) ).round
    end
      
    def fire_delta_v
      calculate_hohmann_transfer
      # thrust(*apply_thrust(@delta_v))
      delta_x, delta_y = apply_thrust(@delta_v)
      thrust(-delta_x, -delta_y)
      @mode = :fire_delta_v_prime
    end
    
    def apply_thrust(delta)
      if @x.zero?
        raise "x = #{@x}, y = #{@y}"
      else
        radius_slope  = @y / @x
        tangent_slope = -1 / radius_slope
        delta_x       = Math.sqrt(delta ** 2 / (1 + tangent_slope ** 2))
        delta_y       = tangent_slope * delta_x
      end
      [delta_x, delta_y]
    end
    
    def fire_delta_v_prime
      if (@time_to_prime -= 1) <= 0
        # delta_x, delta_y = apply_thrust(@delta_v_prime)
        # thrust(-delta_x, -delta_y)
        thrust(*apply_thrust(@delta_v_prime))
        @mode = :coast
      else
        coast
      end
    end
    
    def coast
      thrust(0.0, 0.0)
    end
  end
end
