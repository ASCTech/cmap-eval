require "src/cxl_helper"

include CxlHelper

module CMap
  LEGEND_NODE_WIDTH = 60
  LEGEND_NODE_HEIGHT = 28
  LEGEND_LABEL_WIDTH = 46
  LEDGEND_LABEL_HEIGHT = 13
  
  MISSING_EDGE_COLOR = "0,0,255,255"
  MISPLACED_EDGE_COLOR = "255,0,0,255"
  EXTRA_EDGE_COLOR = "128,0,128,255"
  
  NAME_BLOCK_PREFIX = "Names:"
  class CMap
    def prepare_unique_ids
      # Find the first free id.
      ids = CxlHelper.attribute_from_any_node @xml, "id"
      if ids.empty?
        @previous_safe_id = "0"
      else
        @previous_safe_id = ids.max
      end
    end
    
    def create_appearances_for_connections
      CONNECTION_PATH.apply(@xml).each do |connection|
        CxlHelper.create_if_missing @xml,
        CONNECTION_APPEARANCE_LIST_PATH,
        "connection-appearance",
        connection["id"]
      end
    end
    
    def create_appearances_for_concepts
      CONCEPT_PATH.apply(@xml).each do |concept|
        CxlHelper.create_if_missing @xml,
        CONCEPT_APPEARANCE_LIST_PATH,
        "concept-appearance",
        concept["id"]
      end
    end
    
    def initialize raw_xml
      @xml = raw_xml
      
      prepare_unique_ids
      
      CxlHelper.fill_paths @xml
      
      create_appearances_for_connections
      
      create_appearances_for_concepts
    end
    
    def name_block
      CONCEPT_PATH.apply(@xml).each do |concept|
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
      CONCEPT_PATH.apply(@xml).each do |concept|
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
      beginnings = CONNECTION_PATH.with_values("from-id" => node1_id).value("to-id").apply(@xml)
      beginnings = CxlHelper.normalize_attributes beginnings
      
      # Find the connections that end with node2.
      endings = CONNECTION_PATH.with_values("to-id" => node2_id).value("from-id").apply(@xml)
      endings = CxlHelper.normalize_attributes endings
      
      # Their intersections are the ids of the nodes that we want.
      edge_ids = beginnings & endings
      
      # Look up their names.
      edges = edge_ids.map { |id| label_of id}
      
      return edges
    end
    
    def grade_using key
      mark_misplaced_and_extra_edges key
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
    
    def add_concept id, label
      concept = CxlHelper.create_node @xml, "concept", "id" => id, "label" => label
      
      CONCEPT_LIST_PATH.apply(@xml)[0].add_child concept
    end
    
    def add_concept_appearance id, x, y
      concept_appearance = CxlHelper.create_node @xml,
      "concept-appearance",
      "id" => id,
      "x" => x.to_s,
      "y" => y.to_s,
      "width" => LEGEND_NODE_WIDTH.to_s,
      "height" => LEGEND_NODE_HEIGHT.to_s
      
      CONCEPT_APPEARANCE_LIST_PATH.apply(@xml)[0].add_child concept_appearance
    end
    
    def add_linking_phrase id, label
      phrase = CxlHelper.create_node @xml,
      "linking-phrase",
      "id" => id,
      "label" => label
      
      PHRASE_LIST_PATH.apply(@xml)[0].add_child phrase
    end
    
    def add_linking_phrase_appearance id, x, y, font_color
      phrase_appearance = CxlHelper.create_node @xml,
      "linking-phrase-appearance",
      "id" => id,
      "x" => x.to_s,
      "y" => y.to_s,
      "font-color" => font_color
      
      PHRASE_APPEARANCE_LIST_PATH.apply(@xml)[0].add_child phrase_appearance
    end
    
    def add_connection id, from_id, to_id
      connection = CxlHelper.create_node @xml,
      "connection",
      "id" => id,
      "from-id" => from_id,
      "to-id" => to_id
      
      CONNECTION_LIST_PATH.apply(@xml)[0].add_child connection
    end
    
    def add_connection_appearance id, color
      connection_appearance = CxlHelper.create_node @xml,
      "connection-appearance",
      "from-pos" => "center",
      "to_pos" => "center",
      "id" => id,
      "color" => color
      
      CONNECTION_APPEARANCE_LIST_PATH.apply(@xml)[0].add_child connection_appearance
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
      start_legend_x = max_x + LEGEND_NODE_WIDTH/2 + 50
      start_legend_y = max_y + LEGEND_NODE_HEIGHT/2 + 50
      
      #add legend node 1
      add_concept legend1_id, "Legend1"
      add_concept_appearance legend1_id, start_legend_x, start_legend_y
      
      #add legend node 2
      add_concept legend2_id, "Legend2"
      add_concept_appearance legend2_id, start_legend_x, start_legend_y + 100
      
      #add *missing* linking phrase and connections
      add_linking_phrase missing_id, "Missing"
      add_linking_phrase_appearance missing_id, start_legend_x, start_legend_y + 50, MISSING_EDGE_COLOR
      add_connection_edge legend1_id, missing_id, legend2_id, MISSING_EDGE_COLOR
      
      #add *extra* linking phrase and connections
      add_linking_phrase extra_id, "Extra"
      add_linking_phrase_appearance extra_id, start_legend_x + 55, start_legend_y + 50, EXTRA_EDGE_COLOR
      add_connection_edge legend1_id, extra_id, legend2_id, EXTRA_EDGE_COLOR
      
      #add wrong linking phrase
      add_linking_phrase misplaced_id, "Misplaced"
      add_linking_phrase_appearance misplaced_id, start_legend_x - 65, start_legend_y + 50, MISPLACED_EDGE_COLOR
      add_connection_edge legend1_id, misplaced_id, legend2_id, MISPLACED_EDGE_COLOR
    end
    
    def mark_misplaced_and_extra_edges key
      vocab = key.vocabulary
      
      misplaced_found = false
      extra_found = false
      
      each_unique_pair do |concept1, concept2|
        local_edges = edges_between(concept1, concept2)
        key_edges = key.edges_between(concept1, concept2)
        
        # Edges that are either misplaced or extraneous.
        extra_candidates = local_edges - key_edges
        
        extra_candidates.each do |candidate|
          #The edge is misplaced if it's in the vocab.
          if vocab.index candidate
            mark_edge_misplaced concept1, concept2, candidate
            Debug.misplaced_edge_between concept1, concept2, candidate
            misplaced_found = true
          else
            mark_edge_extra concept1, concept2, candidate
            Debug.extra_edge_between concept1, concept2, candidate
            extra_found = true
          end
        end
      end
      
      Debug.no_misplaced_edges unless misplaced_found
      Debug.no_extra_edges unless extra_found
    end
    
    def mark_edge_extra concept1, concept2, edge
      mark_edge concept1, concept2, edge, EXTRA_EDGE_COLOR
    end
    
    def mark_edge_misplaced concept1, concept2, edge
      mark_edge concept1, concept2, edge, MISPLACED_EDGE_COLOR
    end
    
    def mark_edge concept1, concept2, edge, color
      
      start_id = CxlHelper.value CONCEPT_PATH.with_values("label" => concept1).value("id").apply(@xml)
      end_id = CxlHelper.value CONCEPT_PATH.with_values("label" => concept2).value("id").apply(@xml)
      
      # Find the connections that start with node1.
      beginnings = CxlHelper.normalize_attributes CONNECTION_PATH.with_values("from-id" => start_id).value("to-id").apply @xml
      
      # Find the connections that end with node2.
      endings = CxlHelper.normalize_attributes CONNECTION_PATH.with_values("to-id" => end_id).value("from-id").apply @xml
      
      # Their intersections are the ids of the nodes that we want.
      possible_ids = beginnings & endings
      
      # Check the name to find the unique id of our candidate.
      edge_id = possible_ids.select { |id| edge == label_of(id)}
      
      # Mark the first connection.
      connection1_id = CxlHelper.value CONNECTION_PATH.with_values("from-id" => start_id, "to-id" => edge_id).value("id").apply(@xml)
      CONNECTION_APPEARANCE_PATH.with_values("id" => connection1_id).apply(@xml)[0]["color"] = color
      
      # Mark the second connection.
      connection2_id = CxlHelper.value CONNECTION_PATH.with_values("from-id" => edge_id, "to-id" => end_id).value("id").apply(@xml)
      CONNECTION_APPEARANCE_PATH.with_values("id" => connection2_id).apply(@xml)[0]["color"] = color
      
      # Mark the edge itself.
      PHRASE_APPEARANCE_PATH.with_values("id" => edge_id).apply(@xml)[0]["font-color"] = color
    end
    
    def vocabulary
      # Find all of the edge labels.
      return CxlHelper.normalize_attributes PHRASE_PATH.value("label").apply(@xml)
    end
    
    def node_vocabulary
      # Find all of the node labels
      return CxlHelper.normalize_attributes CONCEPT_PATH.value("label").apply(@xml)
    end
    
    def find_right_of_map
      find_max_of_map "x", "width"
    end
    
    def find_bottom_of_map
      find_max_of_map "y", "height"
    end
    
    def find_max_of_map loc_name, size_name
      furthest = 0
      CxlHelper.builder.anything.with(loc_name, size_name).apply(@xml).each do |node|
        loc = node[loc_name].to_i
        size = node[size_name].to_i
        
        displacement = loc + size/2
        
        if displacement > furthest
          furthest = displacement
        end
      end
    end
    
    
    def make_missing_edge concept1, concept2
      start_id = id_of_concept concept1
      connection1_id = create_unique_id
      middle = create_unique_id
      connection2_id = create_unique_id
      end_id = id_of_concept concept2
      
      # Add the linking-phrase.
      phrase = CxlHelper.create_node @xml,
      "linking-phrase",
      "id" => middle,
      "label" => "*missing*"
      
      PHRASE_LIST_PATH.apply(@xml)[0].add_child phrase
      
      # Find the positions of the phrases, so we can center the "missing" between them.
      start = CONCEPT_APPEARANCE_PATH.with_values("id" => start_id).apply(@xml)[0]
      startx = start["x"].to_i
      starty = start["y"].to_i
      finish = CONCEPT_APPEARANCE_PATH.with_values("id" => end_id).apply(@xml)[0]
      finishx = finish["x"].to_i
      finishy = finish["y"].to_i
      
      # Add its appearance.
      phrase_appearance = CxlHelper.create_node @xml,
      "linking-phrase-appearance",
      "id" => middle,
      "font-color" => MISSING_EDGE_COLOR,
      "x" => ((startx + finishx) / 2).to_s,
      "y" => ((starty + finishy) / 2).to_s
      
      PHRASE_APPEARANCE_LIST_PATH.apply(@xml)[0].add_child phrase_appearance
      
      # Add the connections.
      first_half = CxlHelper.create_node @xml,
      "connection",
      "id" => connection1_id,
      "from-id" => start_id,
      "to-id" => middle
      
      second_half = CxlHelper.create_node @xml,
      "connection",
      "id" => connection2_id,
      "from-id" => middle,
      "to-id" => end_id
      
      CONNECTION_LIST_PATH.apply(@xml)[0].add_child first_half
      CONNECTION_LIST_PATH.apply(@xml)[0].add_child second_half
      
      first_half_appearance = CxlHelper.create_node @xml,
      "connection-appearance",
      "id" => connection1_id,
      "color" => MISSING_EDGE_COLOR
      
      second_half_appearance = CxlHelper.create_node @xml,
      "connection-appearance",
      "id" => connection2_id,
      "color" => MISSING_EDGE_COLOR
      
      CONNECTION_APPEARANCE_LIST_PATH.apply(@xml)[0].add_child first_half_appearance
      CONNECTION_APPEARANCE_LIST_PATH.apply(@xml)[0].add_child second_half_appearance
    end
    
    #TODO: This probably needs fixed
    def generate_problem_statement
      vocab = self.node_vocabulary
      problem_map = CMap.new Nokogiri::XML::Document.new
      x = 5
      y = 0
      
      #add each node to the problem statement map
      vocab.each do |node_label|
        id = create_unique_id
        problem_map.add_concept id, node_label
        problem_map.add_concept_appearance id, x, y
        y = y + 10
      end
      # TODO: add a model name_block
      return problem_map
    end
    
    def id_of_concept node
      CONCEPT_PATH.with_values("label" => node).apply(@xml)[0]["id"]
    end
    
    def label_of id
      return CxlHelper.builder.anything.with_values("id" => id).apply(@xml)[0]["label"]
    end
  end
  
  class Error < Exception
  end
end