#!/usr/bin/env ruby -wKU

# standarad library
require "pathname"
require "optparse"

module JEdI
  DIR                      = Pathname.new( File.join( File.dirname(__FILE__),
                                                      ".." ) )
  PROBLEMS_DIR             = DIR + "problems"
  SOLUTIONS_DIR            = DIR + "solutions"
  IMAGES_DIR               = DIR + "images"
  PROGRAM_DIR              = JEdI::DIR.join(*%w[lib j_ed_i program])

  TEAM_ID                  = 97
  
  X_PORT                   = 2
  Y_PORT                   = 3
  CONFIGURATION_INPUT_PORT = 0x3E80
  SCORE_OUTPUT_PORT        = 0
  FUEL_OUTPUT_PORT         = 1
end

# vendored
require JEdI::DIR.join(*%w[vendor svg_image lib svg])

# our code
require "j_ed_i/vm"
require "j_ed_i/opcode"
require "j_ed_i/radar"
require "j_ed_i/program"
JEdI::PROGRAM_DIR.each_entry do |program|
  require JEdI::PROGRAM_DIR + program if program.extname == ".rb"
end
require "j_ed_i/solution"
