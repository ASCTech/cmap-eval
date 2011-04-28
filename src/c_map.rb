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
          
          if names.size > 0
            return names
          else
            raise Error, "There are no names in the name block."
          end
          
        end
      end
      
      raise Error, "Provided file is missing a name block."
    end
    
    def concepts_in_map
      raw_concepts = @xml.xpath(CONCEPT_XPATH)
      
      concepts = []
      
      # Parse out the labels, ignoring the Names block.
      raw_concepts.each do |concept|
        if !concept["label"].start_with? "Names:"
          concepts << concept["label"]
        end
      end
      
      return concepts
    end
    
    def edges_between node1, node2
      concepts = @xml.xpath(CONCEPT_XPATH)
      connections = @xml.xpath(CONNECTION_XPATH)
      
      # Find the unique ids associated with node1 and node2.
      node1_id = unique_id_of node1, concepts
      node2_id = unique_id_of node2, concepts
      
      # Find the connections that start with node1.
      beginnings = Nokogiri::XML::NodeSet.new @xml
      connections.each do |connection|
        if connection["from-id"] == node1_id
          beginnings << connection
        end
      end
      
      # Find the edge label that we're going to.
      edge_ids_pointed_to = []
      beginnings.each do |beginning|
        edge_ids_pointed_to << beginning["to-id"]
      end
      
      correct_edge_ids = []
      
      connections.each do |connection|
        if edge_ids_pointed_to.include? connection["from-id"]
          if connection["to-id"] == node2_id
            correct_edge_ids << connection["from-id"]
          end
        end
      end
      
      edges = []
      
      linking_phrases = @xml.xpath(LINKING_PHRASE_XPATH)
      
      linking_phrases.each do |phrase|
        if correct_edge_ids.include? phrase["id"]
          edges << phrase["label"]
        end
      end
      
      return edges
    end
    
    def unique_id_of node, concepts
      concepts.each do |concept|
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