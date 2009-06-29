#!/usr/bin/env ruby -wKU

def path_from_here(rel_path)
  File.join(File.dirname(__FILE__), *Array(rel_path))
end

require path_from_here(%w[.. lib svg])

Dir.mkdir(path_from_here('animation')) rescue nil

color = 13
frame = SVG::Image.new(400, 100) do
  line   5,  5,  395, 5
  circle 45, 50, 40, :fill => :blue, :title => 'Ball'
  line   5,  95, 395, 95
end

11.times do |i|
  frame['Ball'].attrs['transform'] = "translate(#{i * 31},0)"
  color -= 1
  frame.each do |s|
    s.attrs['stroke'] = "##{color.to_s(16).upcase * 6}" if s.name == 'line'
  end
  
  File.open(path_from_here(%W[animation #{'%02d' % i}.svg]), 'w') do |f|
    f << frame.to_s.sub(%r{>\s+<title>.+</title>\s+</circle>\n}, '/>')
  end
end