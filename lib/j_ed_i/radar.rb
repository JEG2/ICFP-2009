#!/usr/bin/env ruby -wKU

module JEdI
  class Radar
    SCALE            = 200_000.0
    EARTH_RADIUS     = 6.357 * 10 ** 6
    SATELLITE_RADIUS = EARTH_RADIUS * 0.1
    
    def initialize(frequency)
      @frequency       = frequency
      @step            = 0
      @configuration   = nil
      @satellite_orbit = nil
      @target_orbit    = nil
    end
    
    def update(configuration, outputs)
      update_configuration(configuration)
      update_outputs(outputs)
    end
    
    private
    
    def update_configuration(configuration)
      if @configuration.nil? and configuration.nonzero?
        @configuration = configuration
      end
    end
    
    def update_outputs(outputs)
      update_orbits(outputs)
      draw_image(outputs)

      @step += 1
    end
    
    def update_orbits(outputs)
      @satellite_orbit =   Math.sqrt(outputs[2] ** 2 + outputs[3] ** 2)
      if @configuration >= 2000
        @target_orbit ||= Math.sqrt( (outputs[2] - outputs[4]) ** 2 +
                                     (outputs[3] - outputs[5]) ** 2 )
      else
        @target_orbit ||= outputs[4]
      end
    end
    
    def image
      @image ||= SVG::Image.new(image_size, image_size) do |i|
        if @configuration >= 2000
          i.circle( image_size / 2,
                    image_size / 2,
                    SATELLITE_RADIUS / SCALE,
                    :fill  => :red,
                    :title => "Them" )
        else
          i.circle( image_size / 2,
                    image_size / 2,
                    @target_orbit / SCALE,
                    :fill   => :white,
                    :stroke => :red )
        end
        i.circle( image_size / 2,
                  image_size / 2,
                  EARTH_RADIUS / SCALE,
                  :fill => :blue )
        i.circle( image_size / 2,
                  image_size / 2,
                  SATELLITE_RADIUS / SCALE,
                  :fill    => :green,
                  :opacity => 0.6,
                  :title   => "Us" )
      end
    end
    
    def image_size
      @image_size ||= [@satellite_orbit, @target_orbit].max * 2 / SCALE + 20
    end
    
    def draw_image(outputs)
      return unless @step % @frequency == 0
      
      if @configuration >= 2000
        image["Them"].attrs["transform"] =
          "translate(#{(outputs[2] - outputs[4]) / SCALE}," +
          "#{-(outputs[3] - outputs[5]) / SCALE})"
      end
      image["Us"].attrs["transform"] =
        "translate(#{outputs[2] / SCALE},#{-outputs[3] / SCALE})"
      
      File.open(File.join(IMAGES_DIR, "%010i.svg" % @step), "w") do |svg|
        svg << image.to_s.gsub(%r{>\s+<title>.+</title>\s+</circle>\n}, "/>")
      end
    end
  end
end
