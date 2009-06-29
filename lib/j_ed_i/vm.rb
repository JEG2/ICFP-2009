#!/usr/bin/env ruby -wKU

module JEdI
  class VM
    MAX_ADDRESS   = 0b11_1111_1111_1111
    CONFIGURATION = 0x3E80
    
    def initialize(binary_path, options = Hash.new)
      @options      = options
      @insructions  = Array.new
      @data         = Array.new(MAX_ADDRESS, 0.0)
      @input_ports  = Hash.new(0.0)
      @output_ports = Hash.new(0.0)
      @status       = false
      @step         = 0
      @solution     = nil
      @radar        = Radar.new(@options[:frequency])
      
      load(binary_path)
    end
    
    attr_reader :data
    attr_reader :input_ports
    attr_reader :output_ports
    attr_writer :status
    attr_reader :step
    
    def status?
      @status
    end
    
    def configure(configuration)
      @input_ports[X_PORT]                   = 0.0
      @input_ports[Y_PORT]                   = 0.0
      @input_ports[CONFIGURATION_INPUT_PORT] = configuration
      @solution                              = Solution.new(configuration)
      @solution.update(@step, @input_ports)
    end
    
    def loop
      @insructions.each_with_index do |instruction, address|
        if data = instruction.execute(self)
          @data[address] = data
        end
      end
    end
    
    def update
      @step += 1
      @solution.update(@step, @input_ports)
      @radar.update(@input_ports[CONFIGURATION_INPUT_PORT], @output_ports) \
        if @options[:svg]
    end
    
    def write_output(port, value)
      @output_ports[port] = value
    end
    
    def write_input(port, value)
      @input_ports[port] = value
    end
    
    def finish
      @solution.finish(@step)
    end
    
    private
    
    def load(binary_path)
      open(binary_path) do |binary|
        while frame = binary.read(12)
          if @insructions.size % 2 == 0
            data, opcode = frame.unpack("a8a4")
          else
            opcode, data = frame.unpack("a4a8")
          end
          @data[@insructions.size] =  data.unpack("E").first
          @insructions             << opcode_for(opcode)
        end
      end
    end
    
    def opcode_for(opcode)
      if ("%032b" % opcode.unpack("V"))[0..3] == "0000"
        STypeOpcode.new(opcode)
      else
        DTypeOpcode.new(opcode)
      end
    end
  end
end
