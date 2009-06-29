#!/usr/bin/env ruby -wKU

require File.join(File.dirname(__FILE__), *%w[.. lib svg])

SVG::Image.new(640, 480) do
  rect 20, 20, 185, 210, :fill => :red
  
  rounded_rect 225, 20, 185, 210, 10, 10, :fill   => :aqua,
                                          :stroke => :blueviolet
  
  circle 522, 125, 92, :fill => :white, :stroke => '#BBBBBB'
  
  ellipse 522, 125, 50, 70, :fill => :lime
  
  line 20, 460, 205, 250, :stroke => :black
  
  point 117, 360, :stroke => :black
  
  polyline [225, 460], [225, 250], [317, 302], [235, 354], [410, 406],
           :fill         => :none,
           :stroke       => :black,
           :stroke_width => 5
  
  polygon [430, 250], [585, 250], [615, 460], [460, 460], :fill => :gold
end.display
