module CMap
  CONCEPT_XPATH = "/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept"
  CONNECTION_XPATH = "/xmlns:cmap/xmlns:map/xmlns:connection-list/xmlns:connection"
  LINKING_PHRASE_XPATH = "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list/xmlns:linking-phrase"
  
  class CMap
    def initialize(raw_xml)
      @xml = raw_xml
    end
    
    def name_block
      concepts = @xml.xpath(CONCEPT_XPATH)
      
      concepts.each do |concept|
        if concept["label"].start_with? "Names:"
          names = concept["label"].gsub(/^Names:/, "").strip.split("\n")
          
          raise Error, "There are no names in the name block." unless names.size > 0
          
          return names        
        end
      end
      
      raise Error, "Provided file is missing a name block."
    end
    
    def concepts_in_map
      concepts = []
      
      # Parse out the labels, ignoring the Names block.
      @xml.xpath(CONCEPT_XPATH).each do |concept|
        concepts << concept["label"] unless concept["label"].start_with? "Names:"
      end
      
      return concepts
    end
    
    def edges_between node1, node2
      connections = @xml.xpath(CONNECTION_XPATH)
      
      # Find the unique ids associated with node1 and node2.
      node1_id = unique_id_of_node node1
      node2_id = unique_id_of_node node2
      
      # Find the connections that start with node1.
      beginnings = @xml.xpath(CONNECTION_XPATH + %{[@from-id='#{node1_id}']})
      beginnings = beginnings.xpath(%{@to-id})
      beginnings = beginnings.to_a.map! {|elem| elem.to_s}
      
      # Find the connections that end with node2.
      endings = @xml.xpath(CONNECTION_XPATH + %{[@to-id='#{node2_id}']})
      endings = endings.xpath(%{@from-id})
      endings = endings.to_a.map! {|elem| elem.to_s}
      
      # Their intersections are the ids of the nodes that we want.
      edges = beginnings & endings
      
      return edges
    end
    
    def unique_id_of_node node
      @xml.xpath(CONCEPT_XPATH).each do |concept|
        if concept["label"] == node
          return concept["id"]
        end
      end
    end
    
    def each_unique_pair
      concepts = concepts_in_map
      
      concepts.each do |concept1|
        concepts.each do |concept2|
          if concept1 != concept2
            yield concept1, concept2
          end
        end
      end
    end
  end
  
  class Error < Exception
  end
end