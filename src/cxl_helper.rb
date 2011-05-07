# CxlHelper maintains a collection of facilities for dealing with the complexity of the cxl format.
module CxlHelper
  NAMESPACE = "xmlns"
  NODE_PREFIX = "/#{NAMESPACE}:"
  
  # Manufacture the full xpath from the nodes.  Any arguments that are not already a valid xpath are correctly-prefixed.
  def CxlHelper.create_path *arguments
    path = ""
    
    arguments.each do |item|
      if item.start_with? "/"
        path = path + item
      else
        path = path + NODE_PREFIX + item
      end
    end
    
    return path
  end
  
  # Append the nodes to the already-created xpath.
  def CxlHelper.append_xpath xpath, nodes
    return xpath + CxlHelper.create_path(nodes)
  end
  
  # Find all of the nodes with the given attributes.
  def CxlHelper.any_node_with_attrs xml, *attrs
    predicate = "@" + attrs.join(" and @")
    
    return xml.xpath "//*[#{predicate}]"
  end
  
  # Return an array of the attribute values for all nodes with the given attribute.
  def CxlHelper.attribute_from_any_node xml, attr
    return CxlHelper.array_of_string xml.xpath("//*[#{attr}]/@#{attr}")
  end
  
  # Return an array of the attribute values for the nodes along the path with the given attribute.
  def CxlHelper.attribute_from xml, path, attr
    predicate = "[@#{attr}]/@{#{attr}}"
    
    return CxlHelper.array_of_string xml.xpath path + predicate
  end
  
  def CxlHelper.fill_paths xml
    fill_doc_path xml, CONCEPT_LIST_XPATH
    fill_doc_path xml, CONNECTION_LIST_XPATH
    fill_doc_path xml, LINKING_PHRASE_LIST_XPATH
    
    fill_doc_path xml, CONCEPT_APPEARANCE_LIST_XPATH
    fill_doc_path xml, CONNECTION_APPEARANCE_LIST_XPATH
    fill_doc_path xml, LINKING_PHRASE_APPEARANCE_LIST_XPATH
  end
  
  def CxlHelper.fill_doc_path doc, path
    if doc.xpath(path).size == 0
      CxlHelper.fill_doc_path doc, path[/.*(?=\/.*)/]
      fill_node = Nokogiri::XML::Node.new((path[/(?!.*:.*).*/]), doc)
      doc.at_xpath(path[/.*(?=\/.*)/]).add_child fill_node
    end
  end
  
  def CxlHelper.array_of_string nodes
    return nodes.to_a.map{|elem| elem.to_s}
  end
  
  ROOT_XPATH = CxlHelper.create_path "cmap", "map"
  CONCEPT_LIST_XPATH = CxlHelper.create_path ROOT_XPATH, "concept-list"
  CONNECTION_LIST_XPATH = CxlHelper.create_path  ROOT_XPATH, "connection-list"
  LINKING_PHRASE_LIST_XPATH = CxlHelper.create_path ROOT_XPATH, "linking-phrase-list"
  
  CONCEPT_XPATH = CxlHelper.append_xpath CONCEPT_LIST_XPATH, "concept"
  CONNECTION_XPATH = CxlHelper.create_path CONNECTION_LIST_XPATH, "connection"
  LINKING_PHRASE_XPATH = CxlHelper.create_path LINKING_PHRASE_LIST_XPATH, "linking-phrase"
  
  CONCEPT_APPEARANCE_LIST_XPATH = CxlHelper.create_path ROOT_XPATH, "concept-appearance-list"
  CONNECTION_APPEARANCE_LIST_XPATH = CxlHelper.create_path ROOT_XPATH, "connection-appearance-list"
  LINKING_PHRASE_APPEARANCE_LIST_XPATH = CxlHelper.create_path ROOT_XPATH, "linking-phrase-appearance-list"
  
  CONNECTION_APPEARANCE_XPATH = CxlHelper.create_path CONNECTION_APPEARANCE_LIST_XPATH, "connection-appearance"
end