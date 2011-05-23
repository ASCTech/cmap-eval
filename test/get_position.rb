require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML
  class GetPositionTest < Test::Unit::TestCase
    def test_1_edge_between
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
            }
            xml.send(:"linking-phrase-appearance-list") {
              xml.send(:"linking-phrase-appearance", "id" => "1JCK0VTLG-1FT6YS1-FV", "x" => "45", "y" => "70")
            }
          }
        }
      end   
      cmap = CMap::CMap.new(test.doc)
      
      assert_equal(["45", "70"], cmap.get_position("1JCK0VTLG-1FT6YS1-FV"))
    end
    
    def test_mult_edge_between
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FC")
            }
            xml.send(:"linking-phrase-appearance-list") {
              xml.send(:"linking-phrase-appearance", "id" => "1JCK0VTLG-1FT6YS1-FV", "x" => "45", "y" => "70")
              xml.send(:"linking-phrase-appearance", "id" => "1JCK0VTLG-1FT6YS1-FC", "x" => "21", "y" => "42")
            }
          }
        }
      end   
      cmap = CMap::CMap.new(test.doc)
      
      assert_equal(["45", "70"], cmap.get_position("1JCK0VTLG-1FT6YS1-FV"))
      assert_equal(["21", "42"], cmap.get_position("1JCK0VTLG-1FT6YS1-FC"))
    end
  end