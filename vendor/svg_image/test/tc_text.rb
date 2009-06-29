#!/usr/bin/env ruby -wKU

require 'test/unit'

require 'svg'

class TestText < Test::Unit::TestCase
  def test_text_encloses_content
    assert_match(%r{\A<text[^>]*>\s*test\s*</text>\Z}, text('test').to_s)
  end
  
  def test_text_adds_a_trailing_newline_if_needed
    assert_match(%r{newline\n[ \t]*</text>},    text("newline\n").to_s)
    assert_match(%r{no newline\n[ \t]*</text>}, text('no newline').to_s)
  end
  
  def test_text_is_never_empty
    assert_match(%r{\A<text[^>]*>\s*</text>\Z}, text('').to_s)
  end

  private
  
  def text(*args)
    SVG::Text.new(*args)
  end
end
