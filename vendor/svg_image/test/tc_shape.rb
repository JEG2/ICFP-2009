#!/usr/bin/env ruby -wKU

require 'test/unit'

require 'svg'

class TestShape < Test::Unit::TestCase
  def test_shape_name_becomes_tag_name
    assert_match(/\A<rect\b/,   shape(:rect).to_s)
    assert_match(/\A<circle\b/, shape(:circle).to_s)
  end
  
  def test_attributes_become_tag_attributes
    l = shape(:line, :x1 => 5, :y1 => 10)
    assert_match(/\A<line[^>]+\bx1="5"/,  l.to_s)
    assert_match(/\A<line[^>]+\by1="10"/, l.to_s)
  end
  
  def test_points_attribute_is_rendered_as_a_flattened_list_of_points
    assert_match( /\A<polyline[^>]+\bpoints="1,2 3,4"/,
                  shape(:polyline, :points => [1, 2, 3, 4]).to_s )

    assert_match( /\A<polygon[^>]+\bpoints="1,2 3,4"/,
                  shape(:polygon, :points => [[1, 2], [3, 4]]).to_s )
  end
  
  def test_elements_without_title_or_desc_are_empty
    assert_match(%r{\A<ellipse[^>]*/>\Z}, shape(:ellipse).to_s)
  end
  
  def test_elements_with_title_or_desc_include_subelements
    e = shape(:ellipse, :title => 'Test Ellipse')
    assert_match( %r{ \A<ellipse(?![^>]+\btitle=)[^>]*>\n
                      [\ \t]*<title>Test\ Ellipse</title>\n
                      </ellipse>\Z }x,
                  e.to_s )

    e = shape(:ellipse, :desc => 'Elliptical')
    assert_match( %r{ \A<ellipse(?![^>]+\bdesc=)[^>]*>\n
                      [\ \t]*<desc>Elliptical</desc>\n
                      </ellipse>\Z }x,
                  e.to_s )

    e = shape(:ellipse, :title => 'Test Ellipse', :desc => 'Elliptical')
    assert_match( %r{ \A<ellipse(?![^>]+\btitle=)(?![^>]+\bdesc=)[^>]*>\n
                      [\ \t]*<title>Test\ Ellipse</title>\n
                      [\ \t]*<desc>Elliptical</desc>\n
                      </ellipse>\Z }x,
                  e.to_s )
  end
  
  def test_title_and_desc_are_xml_escaped
    %w[title desc].each do |f|
      assert_send( [ shape(:rect, f => '"Non-friendly" &<XML>').to_s,
                     :include?,
                     %Q{<#{f}>"Non-friendly" &amp;&lt;XML&gt;</#{f}>} ] )
    end
  end
  
  def test_can_edit_name_for_animation
    s = shape(:rect)
    assert_match(/\A<rect\b/, s.to_s)
    s.name = 'line'  # String required when editing
    assert_match(/\A<line\b/, s.to_s)
  end
  
  def test_can_edit_attrs_for_animation
    s = shape(:rect, :x => 1)
    assert_match(/\A<rect[^>]+\bx="1"/, s.to_s)
    s.attrs['x'] = 2  # String key required when editing
    assert_match(/\A<rect[^>]+\bx="2"/, s.to_s)
  end
  
  def test_underscores_are_replaced_with_dashed_in_attribute_names
    assert_match( /\A<rect[^>]+\bstroke-width="1"/,
                  shape(:rect, :stroke_width => 1).to_s )
  end
  
  private
  
  def shape(*args)
    SVG::Shape.new(*args)
  end
end
