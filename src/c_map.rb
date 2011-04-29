module CMap
  CONCEPT_XPATH = "/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept"
  CONNECTION_XPATH = "/xmlns:cmap/xmlns:map/xmlns:connection-list/xmlns:connection"
  LINKING_PHRASE_XPATH = "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list/xmlns:linking-phrase"
  
  NAME_BLOCK_PREFIX = "Names:"
  
  class CMap
    def initialize(raw_xml)
      @xml = raw_xml
    end
    
    def name_block
      concepts = @xml.xpath(CONCEPT_XPATH)
      
      concepts.each do |concept|
        label = concept["label"]
        
        if label.start_with? "NAME_BLOCK_PREFIX"
          names = label.gsub(/^#{NAME_BLOCK_PREFIX}/, "").strip.split "\n"
          
          return names unless names.size == 0
          
          raise Error, "There are no names in the name block."
        end
      end
      
      raise Error, "Provided file is missing a name block."
    end
    
    def concepts_in_map
      concepts = []
      
      # Parse out the labels, ignoring the Names block.
      @xml.xpath(CONCEPT_XPATH).each do |concept|
        label = concept["label"]
        concepts << label unless label.start_with? NAME_BLOCK_PREFIX
      end
      
      return concepts
    end
    
    def edges_between node1, node2
      # Find the unique ids associated with node1 and node2.
      node1_id = id_of_concept node1
      node2_id = id_of_concept node2
      
      # Find the connections that start with node1.
      beginnings = @xml.xpath(CONNECTION_XPATH + %{[@from-id='#{node1_id}']/@to-id})
      beginnings = beginnings.to_a.map! {|elem| elem.to_s}
      
      # Find the connections that end with node2.
      endings = @xml.xpath(CONNECTION_XPATH + %{[@to-id='#{node2_id}']/@from-id})
      endings = endings.to_a.map! {|elem| elem.to_s}
      
      # Their intersections are the ids of the nodes that we want.
      edge_ids = beginnings & endings
      
      # Look up their names.
      edges = edge_ids.map { |id|
        label_of id
      }
      
      return edges
    end
    
    def has_edges_between node1, node2
      edges = edges_between node1, node2
      
      return edges.size > 0
    end
    
    def grade_using key
      missing_found = false
      
      key.each_unique_pair do |concept1, concept2|
        if key.has_edges_between concept1, concept2 and !self.has_edges_between concept1, concept2
          Debug.missing_edge_between concept1, concept2
          missing_found = true
        end
      end
      
      Debug.no_missing_edges unless missing_found
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
    
    private
    
    def id_of_concept node
      @xml.xpath(CONCEPT_XPATH).each do |concept|
        if concept["label"] == node
          return concept["id"]
        end
      end
    end
    
    def label_of id
      return @xml.xpath(%{//*[@id='#{id}']})[0]["label"]
    end
  end
  
  class Error < Exception
  end
end