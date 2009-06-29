#!/usr/bin/env ruby -wKU

module JEdI
  class Program
    class MeetAndGreet < Program
      CONFIGURATION = 2

      def initialize(configuration, options = Hash.new)
        super
        @previous_target_x = nil
        @previous_target_y = nil
        @target_x          = nil
        @target_y          = nil
        @target_radius     = nil
        @angle_of_error    = nil
        @mode              = :determine_target_velocity
      end
      
      def adjust_actuators
        update_target_position_and_radius
        calculate_hohmann_transfer
        send(@mode)
      end
      
      private
      
      def update_target_position_and_radius
        @target_x = @x - @vm.output_ports[4]
        @target_y = @y - @vm.output_ports[5]
        if @target_radius.nil? and @angle_of_error.nil?
          @target_radius  = Math.sqrt(@target_x ** 2 + @target_y ** 2)
          @angle_of_error = Math.asin(1000 / (@target_radius * 2)) / 2
        end
      end
      
      def determine_target_velocity
        if @previous_target_x.nil? and @previous_target_y.nil?
          @previous_target_x = @target_x
          @previous_target_y = @target_y
        else
          chord_length  = Math.sqrt( (@previous_target_x - @target_x) ** 2 +
                                     (@previous_target_y - @target_y) ** 2 )
          central_angle = Math.asin(chord_length / (@target_radius * 2)) / 2
          
          hohmann_axis   = @initial_radius + @target_radius
          radius_slope   = @y / @x
          delta_x        = Math.sqrt( hohmann_axis ** 2 /
                                      (1 + radius_slope ** 2) )
          delta_y        = radius_slope * delta_x
          meet_x, meet_y = @x + delta_x, @y + delta_y
          unless (Math.sqrt(meet_x ** 2 + meet_y ** 2) - @target_radius).abs <=
                 10.0
            meet_x, meet_y = @x - delta_x, @y - delta_y
          end
          meet_chord_length = Math.sqrt( (meet_x - @target_x) ** 2 +
                                         (meet_y - @target_y) ** 2 )
          if meet_chord_length > @target_radius * 2
            meet_chord_length = @target_radius * 2
          end
          meet_angle = Math.asin(meet_chord_length / (@target_radius * 2)) / 2
          
          if (meet_angle - central_angle * (@time_to_prime - 0.5)).abs <
             @angle_of_error
            fire_delta_v
          else
            @previous_target_x = @target_x
            @previous_target_y = @target_y
          end
        end
      end
    end
  end
end
