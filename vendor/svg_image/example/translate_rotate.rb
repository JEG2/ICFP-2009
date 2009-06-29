#!/usr/bin/env ruby -wKU

require File.join(File.dirname(__FILE__), *%w[.. lib svg])

SVG::Image.new(200, 200) do
  g :transform => 'translate(32,32) rotate(-15,67,67)' do
    rect 0, 0, 90, 90, :fill => :red
    circle 90, 90, 45, :fill => :blue
  end
end.display
