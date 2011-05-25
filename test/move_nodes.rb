require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML

class MoveNodesTest < Test::Unit::TestCase
  def test_no_nodes
    test = Builder.new do |xml|
      xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
    end
    
    correct = Builder.new do |xml|
      xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
    end
    cmap = CMap::CMap.new(test.doc)
    key = CMap::CMap.new(correct.doc)
    cmap.move_nodes key
    
    xml = correct.doc
    assert_equal(xml.xpath("//concept-appearance-list/concept-appearance"), cmap.instance_variable_get(:@xml).xpath("//concept-appearance-list/concept-appearance"))
  end
  
  def test_1_node
    test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "21", "y" => "45", "width" => "4", "height" => "4")
            }
          }
        }
    end
    
    correct = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "99", "y" => "99", "width" => "53", "height" => "25")
            }
          }
        }
     end
    
    cmap = CMap::CMap.new(test.doc)
    key = CMap::CMap.new(correct.doc)
    cmap.move_nodes key
    
    xml = correct.doc
    assert_equal(xml.xpath("//concept-appearance-list/concept-appearance"), cmap.instance_variable_get(:@xml).xpath("//concept-appearance-list/concept-appearance"))
    
  end
  
  def test_mult_node
    test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "21", "y" => "45", "width" => "4", "height" => "4")
              xml.send(:"concept-appearance", "id" => "idnode2", "x" => "225600", "y" => "225600", "width" => "4", "height" => "4")
            }
          }
        }
    end
    
    correct = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "99", "y" => "99", "width" => "53", "height" => "25")
              xml.send(:"concept-appearance", "id" => "idnode2", "x" => "1234", "y" => "1234", "width" => "53", "height" => "25")
            }
          }
        }
    end
    
    cmap = CMap::CMap.new(test.doc)
    key = CMap::CMap.new(correct.doc)
    cmap.move_nodes key
    
    xml = correct.doc
    assert_equal(xml.xpath("//concept-appearance-list/concept-appearance"), cmap.instance_variable_get(:@xml).xpath("//concept-appearance-list/concept-appearance"))
  end
  
  #This trys to move test nodes with no defined location into the key location
  def test_missing_appear_mult_node
    test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
            }
            xml.send(:"concept-appearance-list") {
            }
          }
        }
    end
    
    correct = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "idnode1")
              xml.concept("label" => "node2", "id" => "idnode2")
            }
            xml.send(:"concept-appearance-list") {
              xml.send(:"concept-appearance", "id" => "idnode1", "x" => "99", "y" => "99", "width" => "53", "height" => "25")
              xml.send(:"concept-appearance", "id" => "idnode2", "x" => "1234", "y" => "1234", "width" => "53", "height" => "25")
            }
          }
        }
    end
    
    cmap = CMap::CMap.new(test.doc)
    key = CMap::CMap.new(correct.doc)
    cmap.move_nodes key
    
    xml = correct.doc
    assert_equal(xml.xpath("//concept-appearance-list/concept-appearance"), cmap.instance_variable_get(:@xml).xpath("//concept-appearance-list/concept-appearance"))
  end
end