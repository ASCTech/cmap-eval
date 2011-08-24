require File.expand_path('../../test_helper', __FILE__)

  class GetMaxNodeHightTest < Test::Unit::TestCase
    def test_concept_max
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
              xml.concept("label" => "node4", "id" => "idnode4")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
              xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "idconnection1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "idconnection2", "from-id" => "idedge1", "to-id" => "idnode2")
              xml.connection("id" => "idconnection3", "from-id" => "idnode3", "to-id" => "idedge2")
              xml.connection("id" => "idconnection4", "from-id" => "idedge2", "to-id" => "idnode4")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
              xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
              xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
              xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
            }
            xml.send(:"linking-phrase-appearance-list") {
              xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "93", "height" => "27")
              xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "42", "height" => "33")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "idconnection1", "width" => "1", "height" => "10")
              xml.send(:"connection-appearance", "id" => "idconnection2", "width" => "15", "height" => "30")
              xml.send(:"connection-appearance", "id" => "idconnection3", "width" => "97", "height" => "70")
              xml.send(:"connection-appearance", "id" => "idconnection4", "width" => "225600", "height" => "90")
            }
          }
        }
      end

      cmap = CMap::CMap.new(test.doc)
      assert_equal(104, cmap.send(:get_max_node_height))
    end

    def test_edge_max
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
              xml.concept("label" => "node4", "id" => "idnode4")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
              xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "idconnection1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "idconnection2", "from-id" => "idedge1", "to-id" => "idnode2")
              xml.connection("id" => "idconnection3", "from-id" => "idnode3", "to-id" => "idedge2")
              xml.connection("id" => "idconnection4", "from-id" => "idedge2", "to-id" => "idnode4")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
              xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
              xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
              xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
            }
            xml.send(:"linking-phrase-appearance-list") {
              xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "93", "height" => "27")
              xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "42", "height" => "165")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "idconnection1", "width" => "1", "height" => "10")
              xml.send(:"connection-appearance", "id" => "idconnection2", "width" => "15", "height" => "30")
              xml.send(:"connection-appearance", "id" => "idconnection3", "width" => "97", "height" => "70")
              xml.send(:"connection-appearance", "id" => "idconnection4", "width" => "225600", "height" => "90")
            }
          }
        }
      end

      cmap = CMap::CMap.new(test.doc)
      assert_equal(165, cmap.send(:get_max_node_height))
    end

    def test_blank_input
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
          }
        }
      end

      cmap = CMap::CMap.new(test.doc)
      assert_equal(0, cmap.send(:get_max_node_height))
    end
  end
