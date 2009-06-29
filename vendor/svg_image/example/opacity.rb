#!/usr/bin/env ruby -wKU

require File.join(File.dirname(__FILE__), *%w[.. lib svg])

SVG::Image.new(200, 200) do
  rect 32, 32, 90, 90, :fill => :red
  circle 122, 122, 45, :fill => :blue, :opacity => 0.6
end.display
