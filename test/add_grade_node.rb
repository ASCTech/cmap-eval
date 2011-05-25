require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML
  class AddGradeNodeTest < Test::Unit::TestCase
    def test_add_grade_node
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
            }
          }
        }
      end 
      cmap = CMap::CMap.new(test.doc)
      
      correct = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
              xml.concept("label" => "Grade: 50%", "id" => cmap.instance_variable_get(:@previous_safe_id))
            }
          }
        }
      end
        
        cmap.add_grade_node "50"
        xml = correct.doc
        assert_equal(xml.xpath("//concept-list/concept"), cmap.instance_variable_get(:@xml).xpath("//concept-list/concept"))
    end
 end