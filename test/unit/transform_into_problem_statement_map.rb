require File.expand_path('../../test_helper', __FILE__)

  class TransformProbStateTest < Test::Unit::TestCase
    def test_stardard_input
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
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70")
              xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "42")
              xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "225600")
              xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991")
            }
            xml.send(:"linking-phrase-appearance-list") {
              xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "10", "hight" => "10")
              xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "10", "hight" => "10")
            }
            xml.send(:"connection-appearance-list") {
              xml.send(:"connection-appearance", "id" => "idconnection1")
              xml.send(:"connection-appearance", "id" => "idconnection2")
              xml.send(:"connection-appearance", "id" => "idconnection3")
              xml.send(:"connection-appearance", "id" => "idconnection4")
            }
          }
        }
      end
      cmap = CMap::CMap.new(test.doc)
      cmap.transform_into_problem_statement_map

      correct = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
              xml.concept("label" => "node3", "id" => "idnode3")
              xml.concept("label" => "node4", "id" => "idnode4")
              xml.concept("label" => "Names:\nname1\nname2")
              xml.concept("label" => "Propositions:\nedge1\nedge2")
            }
          }
        }
      end

      #all nodes remain, plus two added nodes
      xml = correct.doc
      correct_label = []
      test_label = []

      xml.xpath("//xmlns:concept-list/xmlns:concept").sort.each do |label|
        correct_label = correct_label + [label.attr('label')]
      end

      xml.xpath("//xmlns:concept-list/xmlns:concept").sort.each do |atrib|
        test_label = test_label + [atrib.attr('label')]
      end
      assert_equal(correct_label, test_label)

      #edges removed
      assert_equal(xml.xpath("//xmlns:linking-phrase-list/xmlns:linking-phrase"), cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-list/xmlns:linking-phrase"))
      assert_equal(xml.xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance"), cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance"))
      assert_equal(xml.xpath("//xmlns:connection-appearance-list/xmlns:connection-appearance"), cmap.instance_variable_get(:@xml).xpath("//xmlns:connection-appearance-list/xmlns:connection-appearance"))
    end
  end
