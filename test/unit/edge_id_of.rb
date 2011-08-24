require File.expand_path('../../test_helper', __FILE__)

# If you're looking at this test, I think this could be a bug.
# I was under the impression that edges were one way (ie from and then to)
# Which would make this an error in the code, not a broken test
# if not then text me and I'll fix it.

  class EdgeIDOfTest < Test::Unit::TestCase
    def test_1_edge_between
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
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
      cmap = CMap::CMap.new(test.doc)
      assert_equal("idedge1",cmap.edge_id_of("edge1","node1", "node2"))
    end

    def test_mult_edge_between
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
              xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
              xml.connection("id" => "node1toedge2", "from-id" => "idnode1", "to-id" => "idedge2")
              xml.connection("id" => "edge2tonode2", "from-id" => "idedge2", "to-id" => "idnode2")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      assert_equal("idedge1",cmap.edge_id_of("edge1","node1", "node2"))
      assert_equal("idedge2",cmap.edge_id_of("edge2","node1", "node2"))
    end

    def test_circular_nodes
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
            }
            xml.send(:"linking-phrase-list") {
              xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
              xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
            }
            xml.send(:"connection-list") {
              xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
              xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
              xml.connection("id" => "node2toedge2", "from-id" => "idnode2", "to-id" => "idedge2")
              xml.connection("id" => "edge2tonode1", "from-id" => "idedge2", "to-id" => "idnode1")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      assert_equal("idedge1",cmap.edge_id_of("edge1","node1", "node2"))
      assert_equal("idedge2",cmap.edge_id_of("edge2","node2", "node1"))
    end
  end
