require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML
  class MissingEdgeTest < Test::Unit::TestCase
    def test_nodeless_map
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
         xml.parent.namespace = xml.parent.namespace_definitions.first
        
          xml.map {
           xml.send(:"concept-list")
         }
      }
      end
      c_map = CMap::CMap.new(test.doc)
      key = CMap::CMap.new(test.doc)
    
      c_map.mark_missing_edges(key)
      #There should be no changes to the map, so these should be the same
      assert_equal(key, c_map)
    end

    def test_good_pair_nodes
     test = Builder.new do |xml|
      xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
        xml.parent.namespace = xml.parent.namespace_definitions.first
        
          xml.map {
            xml.send(:"concept-list") {
            xml.concept("label" => "Names:\nname1")
            xml.concept("id")
          }
            
        }
       }
     end
    end
  # class end  
  end