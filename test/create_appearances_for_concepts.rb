require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML

  class CreateAppearancesConceptsTest < Test::Unit::TestCase
    def test_no_concepts
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
          }
        }
      end
      
      expected = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_concepts()
      
      concept_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
    end
    
    def test_1_existing_concept_appearance
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1")
            }
          }
        }
      end
      
      expected = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_concepts()
      
      concept_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
    end
    
    def test_1_concept
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
            }
          }
        }
      end
      
      expected = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_concepts()
      
      concept_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
    end
    
    def test_mult_edges
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
          }
        }
      end
      
      expected = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1")
              xml.send(:"concept-appearance", "id" => "idnode2")
              xml.send(:"concept-appearance", "id" => "idnode3")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_concepts()
      
      concept_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
    end
  end