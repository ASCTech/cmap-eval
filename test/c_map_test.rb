require "test/unit"
require "rexml/document"
require "src/c_map"

require "rexml/attribute"

class CMapTest < Test::Unit::TestCase
  XML_NEW_LINE = "&#xa;"
  
  # Generate the XML document of a map with nothing in it.
  def get_empty_map
    raw_xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
    
    raw_xml << "<cmap xmlns:dcterms=\"http://purl.org/dc/terms/\" "
    raw_xml << "xmlns=\"http://cmap.ihmc.us/xml/cmap/\" "
    raw_xml << "xmlns:dc=\"http://purl.org/dc/elements/1.1/\" "
    raw_xml << "xmlns:vcard=\"http://www.w3.org/2001/vcard-rdf/3.0#\">\n"
    
    raw_xml << "<map>\n"
    
    raw_xml << "</map>\n"
    raw_xml << "</cmap>\n"
    
    return REXML::Document.new raw_xml
  end
  
  def test_1_name_block
    raw_map = get_empty_map
    raw_map.elements["cmap/map"].add_element "concept-list"
    raw_map.elements["cmap/map/concept-list"].add_element "concept", {"label" => %{Names:#{XML_NEW_LINE}name1}}
    
    c_map = CMap.new raw_map
    
    assert_equal "Names:\nname1", c_map.name_block
  end
  
  def test_2_name_block
    raw_map = get_empty_map
    raw_map.elements["cmap/map"].add_element "concept-list"
    raw_map.elements["cmap/map/concept-list"].add_element "concept", {"label" => %{Names:#{XML_NEW_LINE}name1#{XML_NEW_LINE}name2}}
    
    c_map = CMap.new raw_map
    
    assert_equal "Names:\nname1\nname2", c_map.name_block
  end
end