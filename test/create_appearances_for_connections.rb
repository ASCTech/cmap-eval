require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML

  class CreateAppearancesConnectionTest < Test::Unit::TestCase
    def test_no_connections
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
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
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_connections()
      
      connect_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(connect_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
    end
    
    def test_1_existing_edge
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "node1toedge1")
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
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "node1toedge1")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_connections()
      
      connect_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(connect_appear.xpath("//connection-appearance"), xml.xpath("//connection-appearance"))
    end
    
    def test_1_edge
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          #xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
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
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "node1toedge1")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_connections()
      
      connect_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(connect_appear.xpath("//connection-appearance"), xml.xpath("//connection-appearance"))
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
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
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
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "node1toedge1")
              xml.send(:"connection-appearance", "id" => "edge1tonode2")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.create_appearances_for_connections()
      
      connect_appear = expected.doc
      xml = cmap.instance_variable_get(:@xml)
      
      assert_equal(connect_appear.xpath("//connection-appearance"), xml.xpath("//connection-appearance"))
    end
  end