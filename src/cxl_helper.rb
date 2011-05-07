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
    return xml.xpath("//*[#{attr}]/@#{attr}").to_a.map{|elem| elem.to_s}
  end
  
  def CxlHelper.fill_paths xml
    fill_doc_path xml, "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list"
    fill_doc_path xml, "/xmlns:cmap/xmlns:map/xmlns:connection-list"
    fill_doc_path xml, "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-appearance-list"
    fill_doc_path xml, "/xmlns:cmap/xmlns:map/xmlns:connection-appearance-list"
    fill_doc_path xml, "/xmlns:cmap/xmlns:map/xmlns:concept-appearance-list"
    fill_doc_path xml, "/xmlns:cmap/xmlns:map/xmlns:concept-list"
  end
  
  def CxlHelper.fill_doc_path doc, path
      if doc.xpath(path).size == 0
        CxlHelper.fill_doc_path doc, path[/.*(?=\/.*)/]
        fill_node = Nokogiri::XML::Node.new((path[/(?!.*:.*).*/]), doc)
        doc.at_xpath(path[/.*(?=\/.*)/]).add_child fill_node
      end
    end
end