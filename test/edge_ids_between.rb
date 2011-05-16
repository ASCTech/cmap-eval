require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML
  class EdgeIDsBetweenTest < Test::Unit::TestCase
    def test_no_edges_between
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
              xml.concept("label" => "node2", "id" => "1JCK0VTLG-1FT6YS2-FV")
              xml.concept("label" => "node3", "id" => "1JCK0VTLG-1FT6YS3-FV")
            }
          }
        }
      end   
        cmap = CMap::CMap.new(test.doc)
        assert_equal([],cmap.edge_ids_between("1JCK0VTLG-1FT6YS1-FV","1JCK0VTLG-1FT6YS3-FV"))
    end
    
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
      assert_equal(["idedge1"],cmap.edge_ids_between("idnode1","idnode2"))
      
      #test to make sure they don't work in reverse (edges are one way)
      assert_not_equal(["idedge1"],cmap.edge_ids_between("idnode2","idnode1"))
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
      assert_equal(["idedge1", "idedge2"],cmap.edge_ids_between("idnode1","idnode2"))
      
      #test to make sure they don't work in reverse (edges are one way)
      assert_not_equal(["idedge1", "idedge2"],cmap.edge_ids_between("idnode2","idnode1"))
    end
    
    def test_several_nodes
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
              xml.connection("id" => "edge2tonode3", "from-id" => "idedge2", "to-id" => "idnode3")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      assert_equal(["idedge1"],cmap.edge_ids_between("idnode1","idnode2"))
      assert_equal(["idedge2"],cmap.edge_ids_between("idnode2","idnode3"))
      
      #test to make sure they don't work in reverse (edges are one way)
      
      assert_not_equal(["idedge1"],cmap.edge_ids_between("idnode2","idnode1"))
      assert_not_equal(["idedge2"],cmap.edge_ids_between("idnode3","idnode2"))
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
      assert_equal(["idedge1"],cmap.edge_ids_between("idnode1","idnode2"))
      assert_equal(["idedge2"],cmap.edge_ids_between("idnode2","idnode1"))
      
      #test to make sure they don't work in reverse (edges are one way)
      
      assert_not_equal(["idedge1"],cmap.edge_ids_between("idnode2","idnode1"))
      assert_not_equal(["idedge2"],cmap.edge_ids_between("idnode1","idnode2"))
    end
  end