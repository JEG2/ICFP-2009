#!/usr/bin/env ruby -wKU

require File.join(File.dirname(__FILE__), *%w[.. lib svg])

SVG::Image.new(400, 50) do
  text 'by James Edward Gray II', 20, 38, :font_family => 'Georgia',
                                          :font_size   => 18,
                                          :fill        => :blue
end.display
