require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML

  class IsSpecialNodeTest < Test::Unit::TestCase
    def test_special_label
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
      end
      cmap = CMap::CMap.new(test.doc)
      assert_equal(true, cmap.is_special_node("Names:"))
    end
    
    def test_nonspecial_label
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
      end
      cmap = CMap::CMap.new(test.doc)
      assert_equal(false, cmap.is_special_node("name"))
    end
    
  end