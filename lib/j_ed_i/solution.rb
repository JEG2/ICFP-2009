#!/usr/bin/env ruby -wKU

module JEdI
  class Solution
    def initialize(configuration)
      @solution = File.open(SOLUTIONS_DIR + "#{configuration}.osf", "w")
      @solution.write [0xCAFEBABE, TEAM_ID, configuration].pack("V3")
      @previous_inputs = Hash.new
    end
    
    def update(timestep, input_ports)
      changed = Hash.new
      input_ports.each do |port, value|
        if @previous_inputs[port] != value
          @previous_inputs[port] = changed[port] = value
        end
      end
      return if changed.empty?
      @solution.write [timestep, changed.size].pack("V2")
      changed.keys.sort.each do |port|
        @solution.write [port, changed[port]].pack("VE")
      end
    end
    
    def finish(timestep)
      @solution.write [timestep + 1, 0].pack("V2")
    end
  end
end
