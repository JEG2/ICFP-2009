#!/usr/bin/env ruby -wKU

module JEdI
  class Program
    class Hohmann < Program
      CONFIGURATION = 1
      
      def initialize(configuration, options = Hash.new)
        super
        @mode = :fire_delta_v
      end
      
      def adjust_actuators
        update_target_radius
        send(@mode)
      end
      
      private
      
      def update_target_radius
        @target_radius ||= @vm.output_ports[4]
      end
    end
  end
end
