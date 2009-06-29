#!/usr/bin/env ruby -wKU

require 'test/unit'

require 'svg'

class TestImage < Test::Unit::TestCase
  def setup
    @svg = SVG::Image.new(640, 480)
  end
  
  def test_svg_element_is_not_skipped_when_empty
    assert_match(%r{<svg[^>]*>\n}, @svg.to_s)
  end
  
  def test_svg_element_is_always_opened_and_closed
    assert_match(%r{<svg[^>]*>\s*</svg>\Z}, @svg.to_s)
  end
  
  def test_stand_alone_document_includes_xml_declaration_and_doctype
    assert_match(
      %r{ \A<\?xml\ version="1.0"\?>\n
          <!DOCTYPE\ svg\ PUBLIC\ "-//W3C//DTD\ SVG\ 1\.1//EN"\n
          [\ \t]*"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">\n
          <svg[^>]*>\n
          </svg>\Z }x,
      @svg.to_s
    )
  end
  
  def test_non_stand_alone_includes_svg_only
    assert_match(%r{\A<svg[^>]*>\s*</svg>\Z}, @svg.to_s(false))
  end
  
  def test_width_and_height_attributes
    assert_match(/<svg[^>]*\bwidth="640"/,  @svg.to_s)
    assert_match(/<svg[^>]*\bheight="480"/, @svg.to_s)
  end
  
  def test_default_attributes
    assert_match(/<svg[^>]*\bversion="1\.1"/,                         @svg.to_s)
    assert_match(%r{<svg[^>]*\bxmlns="http://www\.w3\.org/2000/svg"}, @svg.to_s)
  end
  
  def test_constructor_forwards_blocks_to_build
    assert_equal('rect', SVG::Image.new(10, 10) { rect(1, 2, 3, 4) }[0].name)
  end
  
  def test_xml_is_pretty_printed
    build_nested_image
    assert_match( %r{ \A<\?.+\n
                      <!.+\n
                      \ \ ".+\n
                      <svg.+\n
                      \ \ <rect.+\n
                      \ \ <g.+\n
                      \ \ \ \ <circle.+\n
                      \ \ \ \ \ \ <title.+\n
                      \ \ \ \ </circle.+\n
                      \ \ \ \ <g.+\n
                      \ \ \ \ \ \ <line.+\n
                      \ \ \ \ \ \ <text.+\n
                      \ \ \ \ \ \ \ \ Test.+\n
                      \ \ \ \ \ \ </text.+\n
                      \ \ \ \ </g.+\n
                      \ \ </g.+\n
                      </svg>\Z }x,
                  @svg.to_s )
  end
  
  def test_index_shape_by_title
    build_nested_image
    assert_nil(@svg['Missing'])
    assert_equal('circle', @svg['Test Circle'].name)
  end
  
  private
  
  def build_nested_image
    @svg.build do
      rect 1, 2, 3, 4
      g do
        circle 1, 2, 3, :title => 'Test Circle'
        g do
          line 1, 2, 3, 4
          text 'Test Text', 1, 2
        end
      end
    end
  end
end
