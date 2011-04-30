module CMap
  CONCEPT_XPATH = "/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept"
  CONNECTION_XPATH = "/xmlns:cmap/xmlns:map/xmlns:connection-list/xmlns:connection"
  LINKING_PHRASE_XPATH = "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list/xmlns:linking-phrase"
  
  NAME_BLOCK_PREFIX = "Names:"
  
  class CMap
    def initialize(raw_xml)
      @xml = raw_xml
      
      # Find the first free id.
      ids = @xml.xpath("//xmlns:concept | //xmlns:linking-phrase").xpath("@id").to_a.map {|elem| elem.to_s}
      if ids.empty?
        @previous_safe_id = "0"
      else
        @previous_safe_id = ids.max
      end
    end
    
    def name_block
      concepts = @xml.xpath(CONCEPT_XPATH)
      
      concepts.each do |concept|
        label = concept["label"]
        
        if label.start_with? NAME_BLOCK_PREFIX
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
      edges = edge_ids.map { |id| label_of id}
      
      return edges
    end
    
    def grade_using key
      mark_missing_edges key
    end
    
    def write_to_file file_name
      File.open file_name, "w" do |file|
        file.print @xml.to_xml
      end
    end
    
    protected
    
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
    
    def mark_missing_edges key
      missing_found = false
      
      key.each_unique_pair do |concept1, concept2|
        good_edges = key.edges_between(concept1, concept2)
        local_edges = self.edges_between(concept1, concept2)
        
        if !good_edges.empty? and (good_edges & local_edges).empty?
          make_missing_edge concept1, concept2
          Debug.missing_edge_between concept1, concept2
          missing_found = true
        end
      end
      
      Debug.no_missing_edges unless missing_found      
    end
    
    def create_unique_id
      return @previous_safe_id.succ!
    end
    
    def make_missing_edge concept1, concept2
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:connection-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-appearance-list"
      
      start_id = id_of_concept concept1
      middle = create_unique_id
      end_id = id_of_concept concept2
      
      # Add the linking-phrase.
      phrase_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with phrase_fragment do |doc|
        doc.send :"linking-phrase", "id" => middle, "label" => "*missing*"
      end
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list").add_child phrase_fragment
      
      # Find the positions of the phrases, so we can center the "missing" between them.
      start = @xml.at_xpath(%{/xmlns:cmap/xmlns:map/xmlns:concept-appearance-list/xmlns:concept-appearance[@id='#{start_id}']})
      startx = start.at_xpath(%{@x}).to_s.to_i
      starty = start.at_xpath(%{@y}).to_s.to_i
      finish = @xml.at_xpath(%{/xmlns:cmap/xmlns:map/xmlns:concept-appearance-list/xmlns:concept-appearance[@id='#{end_id}']})
      finishx = finish.at_xpath(%{@x}).to_s.to_i
      finishy = finish.at_xpath(%{@y}).to_s.to_i
      
      # Add its appearance.
      phrase_appearance_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with phrase_appearance_fragment do |doc|
        doc.send :"linking-phrase-appearance", 
          "id" => middle, 
          "font-color" => "0,0,255,255",
          "x" => "#{(startx + finishx) / 2}", 
          "y" => "#{(starty + finishy) / 2}"
      end
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:linking-phrase-appearance-list").add_child phrase_appearance_fragment
      
      # Add the connections.
      connection_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with connection_fragment do |doc|
        doc.connection "from-id" => start_id, "to-id" => middle
        doc.connection "from-id" => middle, "to-id" => end_id
      end
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:connection-list").add_child connection_fragment
    end
    
    def fill_doc_path doc, path
      if doc.xpath(path).size == 0
        fill_doc_path doc, path[/.*(?=\/.*)/]
        fill_node = Nokogiri::XML::Node.new((path[/(?!.*:.*).*/]), doc)
        doc.at_xpath(path[/.*(?=\/.*)/]).add_child fill_node
      end
    end
    
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