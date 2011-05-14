# This is not working currently. I would need to make another class 
# in c_map to test it so I can get the prepare_unique_ids var

require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML

class UniqueIdsTest < Test::Unit::TestCase
  def test_no_id
    test = Builder.new do |xml|
      xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") { 
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
        xml.map {
          xml.send(:"concept-list") {
          }
        }
      }
    end
    c_map = CMap::CMap.new(test.doc)
    
    assert_equal([], c_map.previous_safe_id)
  end
  
  def test_single_id
    test = Builder.new do |xml|
      xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") { 
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
        xml.map {
          xml.send(:"concept-list") {
            xml.concept("id" => "1JCK0VTLG-1FT6YS1-FV")
          }
        }
      }
    end
    c_map = CMap::CMap.new(test.doc)
    
    assert_equal(["1JCK0VTLG-1FT6YS1-FV"], c_map.previous_safe_id)
  end
  
  def test_mult_id
    test = Builder.new do |xml|
      xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") { 
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
        xml.map {
          xml.send(:"concept-list") {
            xml.concept("id" => "1JCK0VTLG-1FT6YS1-FV")
          }
          xml.send(:"concept-list") {
            xml.concept("id" => "1JCK12PWV-103W7MZ-H2")
          }
        }
      }
    end
    c_map = CMap::CMap.new(test.doc)
    
    assert_equal "1JCK12PWV-103W7MZ-H2", c_map::previous_safe_id
  end
end