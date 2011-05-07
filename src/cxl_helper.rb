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
end