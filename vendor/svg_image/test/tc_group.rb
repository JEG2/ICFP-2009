#!/usr/bin/env ruby -wKU

require 'test/unit'
require 'enumerator'

require 'svg'

class TestGroup < Test::Unit::TestCase
  def setup
    @g = SVG::Group.new
  end
  
  def test_empty_g_is_skipped
    assert_equal('', @g.to_s)
  end
  
  def test_rect_with_attributes
    assert_tags_built(:rect, :x, 5, :y, 10, :width, 50, :height, 100)
  end
  
  def test_adding_radii_to_rect_for_rounded_rect(name = :rect)
    @g.send(name, 1, 1, 1, 1, 2, 3)
    assert_match(/<rect[^>]+\brx="2"/, @g.to_s)
    assert_match(/<rect[^>]+\bry="3"/, @g.to_s)
  end
  
  def test_rounded_rect_is_an_alias_for_rect
    test_adding_radii_to_rect_for_rounded_rect(:rounded_rect)
  end
  
  def test_circle_with_attributes
    assert_tags_built(:circle, :cx, 1, :cy, 2, :r, 3)
  end
  
  def test_ellipse_with_attributes
    assert_tags_built(:ellipse, :cx, 1, :cy, 2, :rx, 3, :ry, 4)
  end
  
  def test_line_with_attributes
    assert_tags_built(:line, :x1, 1, :y1, 2, :x2, 3, :y2, 4)
  end
  
  def test_point_with_attributes
    @g.point(1, 2, :color => :red)
    assert_match(/<line[^>]+\bx1="1"/,      @g.to_s)
    assert_match(/<line[^>]+\by1="2"/,      @g.to_s)
    assert_match(/<line[^>]+\bx2="1"/,      @g.to_s)
    assert_match(/<line[^>]+\by2="2"/,      @g.to_s)
    assert_match(/<line[^>]+\bcolor="red"/, @g.to_s)
  end
  
  def test_polyline_with_attributes(poly = :polyline)
    assert_tags_built(poly, :points, [[1, 2], [3, 4]]) do |v|
      v.flatten.enum_slice(2).map { |a| a.join(',') }.join(' ')
    end
  end
  
  def test_polygon_with_attributes
    test_polyline_with_attributes(:polygon)
  end
  
  def test_text_with_attributes
    @g.text('test', 1, 2, :font_family => 'Georgia')
    assert_match(/<text[^>]+\bx="1"/,                 @g.to_s)
    assert_match(/<text[^>]+\by="2"/,                 @g.to_s)
    assert_match(/<text[^>]+\bfont-family="Georgia"/, @g.to_s)
  end
  
  def test_ordered_shape_additions
    @g.rect(1, 2, 3, 4)
    @g.circle(10, 20, 30)
    @g.line(100, 200, 300, 400)
    assert_match( %r{ \A<g[^>]*>\n
                     [ \t]*<rect[^>]*>\n
                     [ \t]*<circle[^>]*>\n
                     [ \t]*<line[^>]*>\n
                     </g>\Z }x,
                  @g.to_s )
  end
  
  def test_building_a_group_with_an_explicit_reference
    @g.build { |g| g.line(1, 2, 3, 4) }
    assert_match(%r{\A<g[^>]*>\n[ \t]*<line[^>]*>\n</g>\Z}, @g.to_s)
  end
  
  def test_building_a_group_without_an_explicit_reference
    @g.build { line(1, 2, 3, 4) }
    assert_match(%r{\A<g[^>]*>\n[ \t]*<line[^>]*>\n</g>\Z}, @g.to_s)
  end
  
  def test_building_with_nested_groups(name = :g)
    @g.build do
      line(1, 2, 3, 4)
      send(name, :stroke => :green) do
        circle(5, 6, 7)
      end
    end
    assert_match( %r{ \A<g[^>]*>\n
                      [\ \t]*<line[^>]*>\n
                      [\ \t]*<g\ stroke="green">\n
                      [\ \t]*<circle[^>]*>\n
                      [\ \t]*</g>\n
                      </g>\Z }x,
                  @g.to_s )
  end
  
  def test_group_is_an_alias_for_g
    test_building_with_nested_groups(:group)
  end
  
  def test_delegates_some_array_methods_to_contents_for_editing
    @g.rect(1, 2, 3, 4)
    @g.circle(10, 20, 30)
    @g.line(100, 200, 300, 400)
    
    assert_equal('circle', @g[1].name)
    @g[1] = SVG::Group.new
    assert_equal('g',      @g[1].name)

    assert_equal(3, @g.size)
    @g.delete_at(2)
    assert_equal(2, @g.size)
    
    @g.clear
    assert(@g.empty?, 'Group expected to be empty.')
  end
  
  def test_can_iterate_over_nested_contents
    build_nested_group
    expected = %w[line g circle rect]
    @g.each do |shape|
      assert_equal(expected.shift, shape.name)
    end
  end
  
  def test_can_iterate_over_contents_without_nesting
    build_nested_group
    expected = %w[line g rect]
    @g.each(false) do |shape|
      assert_equal(expected.shift, shape.name)
    end
  end
  
  def test_can_pull_enum_without_passing_a_block
    build_nested_group
    e = @g.each
    assert_instance_of(Enumerable::Enumerator, e)
    assert_equal(%w[line g circle rect], e.map { |s| s.name })

    assert_equal(%w[line g rect], @g.each(false).map { |s| s.name })
  end
  
  def test_mixes_in_enumerable
    build_nested_group
    assert(@g.is_a?(Enumerable), 'Mixin not found.')
    assert_equal( %w[line circle rect],
                  @g.select { |s| s.name != 'g' }.map { |s| s.name } )
    @g.zip(%w[line g circle rect]) do |shape, name|
      assert_equal(name, shape.name)
    end
  end
  
  private
  
  def assert_tags_built(name, *args, &stringify_args)
    @g.send(name, *args.enum_slice(2).map { |a| a.last } << {:color => :red})
    assert_match(%r{\A<g[^>]*>\n[ \t]*<#{name}[^>]*>\n</g>\Z},   @g.to_s)
    stringify_args ||= lambda { |arg| String(arg) }
    args.each_slice(2) do |k, v|
      assert_match(/<#{name}[^>]+\b#{k}="#{stringify_args[v]}"/, @g.to_s)
    end
    assert_match(/<#{name}[^>]+\bcolor="red"/,                   @g.to_s)
  end
  
  def build_nested_group
    @g.build do
      line 1, 2, 3, 4
      g do
        circle 1, 2, 3
      end
      rect 1, 2, 3, 4
    end
  end
end
