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
  
  def CxlHelper.value nodeset
    return CxlHelper.normalize(nodeset)[0] 
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

  # Generate a node with the attributes as a hash.
  def CxlHelper.create_node xml, name, attributes
    node = Nokogiri::XML::Node.new name, xml
    
    attributes.each do |key, value|
      node[key] = value
    end

    return node
  end

  def CxlHelper.normalize nodes
    return nodes.to_a.map{|elem| elem.to_s}
  end
  
  def CxlHelper.create_if_missing xml, path, name, id, *values
    if !path.at(name).with_values("id" => id).apply(xml)[0]
      node = CxlHelper.create_node xml, name, "id" => id, *values
      path.apply(xml)[0].add_child node
    end
  end
  
  def CxlHelper.builder
    return PathBuilder.new
  end

  # PathBuilder is an immutable that aids in the construction of XPaths.
  class PathBuilder
    def initialize *args
      if args.empty?
        @path = ""
      else
      @path = args[0]
      end
    end
    
    def to_s
      return @path
    end
    
    def anywhere node
      return PathBuilder.new @path + "//#{node}"
    end
    
    def anything
      return PathBuilder.new @path + "//*"
    end

    def at node, *other_nodes
      result = @path + NODE_PREFIX + node
      other_nodes.each do |other_node|
        result << NODE_PREFIX + other_node
      end

      return PathBuilder.new result
    end

    def with *attributes
      return PathBuilder.new @path + "[@" + attributes.join(" and @") + "]"
    end

    def with_values attributes
      predicates = []
      attributes.each do |key, value|
        predicates << %{@#{key}='#{value}'}
      end

      return PathBuilder.new @path + "[" + predicates.join(" and ") + "]"
    end

    def value attribute
      return PathBuilder.new @path + "/@#{attribute}"
    end

    def apply xml
      return xml.xpath @path
    end
  end

  ROOT_PATH = PathBuilder.new().at "cmap", "map"
  CONCEPT_LIST_PATH = ROOT_PATH.at "concept-list"
  CONNECTION_LIST_PATH = ROOT_PATH.at "connection-list"
  PHRASE_LIST_PATH = ROOT_PATH.at "linking-phrase-list"
  
  CONCEPT_PATH = CONCEPT_LIST_PATH.at "concept"
  CONNECTION_PATH = CONNECTION_LIST_PATH.at "connection"
  PHRASE_PATH = PHRASE_LIST_PATH.at "linking-phrase"
  
  CONCEPT_APPEARANCE_LIST_PATH = ROOT_PATH.at "concept-appearance-list"
  CONNECTION_APPEARANCE_LIST_PATH = ROOT_PATH.at "connection-appearance-list"
  PHRASE_APPEARANCE_LIST_PATH = ROOT_PATH.at "linking-phrase-appearance-list"

  CONCEPT_APPEARANCE_PATH = CONCEPT_APPEARANCE_LIST_PATH.at "concept-appearance"
  CONNECTION_APPEARANCE_PATH = CONNECTION_APPEARANCE_LIST_PATH.at "connection-appearance"
  PHRASE_APPEARANCE_PATH = PHRASE_APPEARANCE_LIST_PATH.at "linking-phrase-appearance"

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