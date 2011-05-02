module CMap
  CONCEPT_XPATH = "/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept"
  CONNECTION_XPATH = "/xmlns:cmap/xmlns:map/xmlns:connection-list/xmlns:connection"
  LINKING_PHRASE_XPATH = "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list/xmlns:linking-phrase"
  
  LEGEND_NODE_WIDTH = 60
  LEGEND_NODE_HEIGHT = 28
  LEGEND_LABEL_WIDTH = 46
  LEDGEND_LABEL_HEIGHT = 13
  
  MISSING_EDGE_COLOR = "0,0,255,255"
  MISPLACED_EDGE_COLOR = "255,0,0,255"
  EXTRA_EDGE_COLOR = "128,0,128,255"
  
  
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
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:connection-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:linking-phrase-appearance-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:connection-appearance-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:concept-appearance-list"
      fill_doc_path @xml, "/xmlns:cmap/xmlns:map/xmlns:concept-list"
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
      mark_extra_edges key
      mark_missing_edges key
      generate_legend
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
      @previous_safe_id = @previous_safe_id.succ
      return @previous_safe_id
    end
    
    # TODO: This needs some major refactoring
    def add_concept id, label
      concept_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with concept_fragment do |doc|
        doc.send :"concept", "id" => id, "label" => label
      end
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:concept-list").add_child concept_fragment
    end
    
    def add_concept_appearance id, x, y
      concept_appearance_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with concept_appearance_fragment do |doc|
        doc.send :"concept-appearance", 
          "id" => id, 
          "x" => x, 
          "y" => y,
          "width" => LEGEND_NODE_WIDTH,
          "height" => LEGEND_NODE_HEIGHT
      end
      
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:concept-appearance-list").add_child concept_appearance_fragment
      
    end
    
    def add_linking_phrase id, label
      phrase_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with phrase_fragment do |doc|
        doc.send :"linking-phrase", "id" => id, "label" => label
      end
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:linking-phrase-list").add_child phrase_fragment
    end
    
    def add_linking_phrase_appearance id, x, y, font_color
      phrase_appearance_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with phrase_appearance_fragment do |doc|
        doc.send :"linking-phrase-appearance", 
          "id" => id, 
          "x" => x, 
          "y" => y,
          "width" => LEGEND_NODE_WIDTH,
          "height" => LEGEND_NODE_HEIGHT,
          "font-color" => font_color
      end
      
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:linking-phrase-appearance-list").add_child phrase_appearance_fragment
      
    end
    
    def add_connection id, from_id, to_id
      connection_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with connection_fragment do |doc|
        doc.send :"connection", 
          "id" => id, 
          "from-id" => from_id,
          "to-id" => to_id
      end
      
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:connection-list").add_child connection_fragment
    end
    
    def add_connection_appearance id, color
      connection_appearance_fragment = Nokogiri::XML::DocumentFragment.new @xml
      Nokogiri::XML::Builder.with connection_appearance_fragment do |doc|
        doc.send :"connection-appearance", 
          "id" => id, 
          "from-pos" => "center",
          "to_pos" => "center",
          "color" => color
      end
      
      @xml.at_xpath("/xmlns:cmap/xmlns:map/xmlns:connection-appearance-list").add_child connection_appearance_fragment
    end
    
    def add_connection_edge node1_id, edge_label_id, node2_id, color
      line1_id = create_unique_id
      line2_id = create_unique_id
      
      add_connection line1_id, node1_id, edge_label_id
      add_connection line2_id, edge_label_id, node2_id
      add_connection_appearance line1_id, color
      add_connection_appearance line2_id, color
    end
    
    def generate_legend
      max_x = find_right_of_map
      max_y = find_bottom_of_map
      
      legend1_id = create_unique_id
      legend2_id = create_unique_id
      missing_id = create_unique_id
      extra_id = create_unique_id
      misplaced_id = create_unique_id
      start_legend_x = max_x + LEGEND_NODE_WIDTH/2
      start_legend_y = max_y + LEGEND_NODE_HEIGHT/2
      
      #add legend node 1
      add_concept legend1_id, "Legend1"
      add_concept_appearance legend1_id, start_legend_x, start_legend_y    
      
      #add legend node 2
      add_concept legend2_id, "Legend2"
      add_concept_appearance legend2_id, start_legend_x, start_legend_y + 70   
      
      #add *missing* linking phrase and connections
      add_linking_phrase missing_id, "Missing"
      add_linking_phrase_appearance missing_id, start_legend_x, start_legend_y + 35, MISSING_EDGE_COLOR
      add_connection_edge legend1_id, missing_id, legend2_id, MISSING_EDGE_COLOR
      
      #add *extra* linking phrase and connections
      add_linking_phrase extra_id, "Extra"
      add_linking_phrase_appearance extra_id, start_legend_x + 45, start_legend_y + 35, EXTRA_EDGE_COLOR
      add_connection_edge legend1_id, extra_id, legend2_id, EXTRA_EDGE_COLOR
      
      #add wrong linking phrase
      add_linking_phrase misplaced_id, "Misplaced"
      add_linking_phrase_appearance misplaced_id, start_legend_x - 55, start_legend_y + 35, MISPLACED_EDGE_COLOR
      add_connection_edge legend1_id, misplaced_id, legend2_id, MISPLACED_EDGE_COLOR    
    end
    
    
    def mark_extra_edges key
      vocab = key.vocabulary
      
      extra_found = false
      
      each_unique_pair do |concept1, concept2|
        local_edges = edges_between(concept1, concept2)
        key_edges = key.edges_between(concept1, concept2)
        
        # Edges that may be extraneous.
        extra_candidates = local_edges - key_edges
        
        extra_candidates.each do |candidate|
          #The edge is extraneous if it's in the vocab.
          if vocab.index candidate
            mark_edge_extra concept1, concept2, candidate
            Debug.extra_edge_between concept1, concept2, candidate
            extra_found = true
          end
        end
      end
      
      if !extra_found
        Debug.no_extra_edges
      end
    end
    
    def mark_edge_extra concept1, concept2, edge
      # TODO: Finish
      
      start_id = @xml.at_xpath(%{/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept[@label='#{concept1}']})["id"]
      end_id = @xml.at_xpath(%{/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept[@label='#{concept2}']})["id"]
      
      # Find the connections that start with node1.
      beginnings = @xml.xpath(CONNECTION_XPATH + %{[@from-id='#{start_id}']/@to-id})
      beginnings = beginnings.to_a.map! {|elem| elem.to_s}
      
      # Find the connections that end with node2.
      endings = @xml.xpath(CONNECTION_XPATH + %{[@to-id='#{end_id}']/@from-id})
      endings = endings.to_a.map! {|elem| elem.to_s}
      
      # Their intersections are the ids of the nodes that we want.
      possible_ids = beginnings & endings
      
      # Check the name to find the unique id of our candidate.
      edge_id = possible_ids.select { |id| edge == label_of(id)}
      
      # Mark the appearance.
      appearance = @xml.at_xpath(%{/xmlns:cmap/xmlns:map/xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@id='#{edge_id}']})
      appearance["font-color"] = "255,0,0,255"
    end
    
    def vocabulary
      # Find all of the edge labels.
      phrase_nodes = @xml.xpath(LINKING_PHRASE_XPATH + "/@label")
      
      return phrase_nodes.to_a.map {|elem| elem.to_s}
    end
    
    #Get the max X value of all the nodes or edge labels on the input map
    def find_right_of_map
      max_x = 0
      @xml.xpath("//*[@x and @width]").each do |node|
        x = node["x"].to_s.to_i
        width = node["width"].to_s.to_i
        
        if x + width/2 > max_x
          max_x = x + width/2
        end
      end
      
      return max_x
    end
    
    #Get the max Y value of all the nodes or edge labels on the input map
    def find_bottom_of_map 
      max_y = 0
      @xml.xpath("//*[@y and @height]").each do |node|
        y = node["y"].to_s.to_i
        height = node["height"].to_s.to_i
        
        if y + height/2 > max_y
          max_y = y + height/2
        end
      end
      
      return max_y
    end
    
    def make_missing_edge concept1, concept2
      
      
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