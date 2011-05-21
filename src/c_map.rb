require "src/cxl_helper"

include CxlHelper

module CMap
  LEGEND_NODE_WIDTH = 60
  LEGEND_NODE_HEIGHT = 28
  LEGEND_LABEL_WIDTH = 46
  LEGEND_LABEL_HEIGHT = 13
  
  MISSING_EDGE_COLOR = "0,0,255,255"
  MISPLACED_EDGE_COLOR = "255,0,0,255"
  EXTRA_EDGE_COLOR = "128,0,128,255"
  
  NAME_BLOCK_PREFIX = "Names:"
  class CMap
    def prepare_unique_ids
      # Find the first free id.
      ids = CxlHelper.value CxlHelper.builder.anything.with("id").value("id").apply(@xml)
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
        # TODO: proposition prefix
        concepts << label unless label.start_with? NAME_BLOCK_PREFIX
      end
      
      return concepts
    end
    
    def edges_between node1, node2
      # Find the unique ids associated with node1 and node2.
      node1_id = id_of_concept node1
      node2_id = id_of_concept node2
      
      edge_ids = edge_ids_between node1_id, node2_id
      
      # Look up their names.
      return edge_ids.map { |id| label_of id}
    end
    
    def edge_ids_between node1_id, node2_id
      # Find the connections that start with node1.
      beginnings = CONNECTION_PATH.with_values("from-id" => node1_id).value("to-id").apply(@xml)
      beginnings = CxlHelper.normalize beginnings
      
      # Find the connections that end with node2.
      endings = CONNECTION_PATH.with_values("to-id" => node2_id).value("from-id").apply(@xml)
      endings = CxlHelper.normalize endings
      
      # Their intersections are the ids of the nodes that we want.
      return beginnings & endings
    end
    
    def move_nodes key
      # Move the concepts.
      concepts_in_map.each do |concept|
        set_concept_position concept, *key.concept_position(concept)
      end
      
      # Move linking phrases.
      each_unique_pair do |start, finish|
        local_edges = edges_between start, finish
        key_edges = key.edges_between start, finish
        
        correct_edges = local_edges & key_edges
        incorrect_edges = local_edges - key_edges
        
        # Move the correct edges first.
        correct_edges.each do |edge|
          id_to_move = edge_id_of edge, start, finish
          place_to_move = key.get_position key.edge_id_of edge, start, finish
          set_position id_to_move, *place_to_move
        end
        
        # Move the incorrect edges into the remaining space.
        incorrect_edges.each do |edge|
          id_to_move = edge_id_of edge, start, finish
          move_position = new_edge_position(id_of_concept(start), id_of_concept(finish))
          move_position = move_position.map { |elem|
            elem.to_s
          }
          set_position id_to_move, *move_position
        end
      end
    end
    
    def set_position id, x, y
      node = CxlHelper.builder.anything.with("x", "y").with_values("id" => id).apply(@xml)[0]
      node["x"] = x
      node["y"] = y
    end
    
    def get_position id
      node = CxlHelper.builder.anything.with("x", "y").with_values("id" => id).apply(@xml)[0]
      return node["x"], node["y"]
    end
    
    def edge_id_of edge, start, finish
      start_id = id_of_concept start
      finish_id = id_of_concept finish
      
      # Find all edges with that id.
      candidates = PHRASE_PATH.with_values("label" => edge).apply(@xml).to_a
      
      candidates = candidates.select do |candidate|
        does_begin = CONNECTION_PATH.with_values("from-id" => start_id, "to-id" => candidate["id"]).apply(@xml)
        does_end = CONNECTION_PATH.with_values("from-id" => candidate["id"], "to-id" => finish_id).apply(@xml)
        !does_begin.nil? and !does_end.nil?
      end
      
      return candidates[0]["id"]
    end
    
    def set_concept_position concept, x, y
      id = id_of_concept concept
      node = CONCEPT_APPEARANCE_PATH.with_values("id" => id).apply(@xml)[0]
      node["x"] = x
      node["y"] = y
    end
    
    def concept_position concept
      id = id_of_concept concept
      
      node = CONCEPT_APPEARANCE_PATH.with_values("id" => id).apply(@xml)[0]
      x = node["x"]
      y = node["y"]
      
      return x, y
    end
    
    def grade_using key
      distinct_connections = key.number_of_distinct_connections
      
      mark_misplaced_and_extra_edges key
      missing_edges = mark_missing_edges key
      generate_legend
      
      correct = distinct_connections - missing_edges
      # TODO: This should be changed. Choppy fix.
      if !(distinct_connections == 0)
        grade = (correct.to_f/distinct_connections.to_f) * 100
      else
        if correct < 0
          grade = 0
        else
          grade = 100
        end
      end
      return grade.round.to_i
    end
    
    def write_to_file file_name
      # Create the directory, if it doesn't already exist.
      
      if file_name.include? "\\" or file_name.include? "/"
        directory_part = file_name[/.*(?=[\/\\][^\/\\]*)/]
        
        if !File.exist? directory_part
          Dir.mkdir directory_part
        end
      end
      
      File.open file_name, "w" do |file|
        file.print @xml.to_xml
      end
    end
    
    def remove_edges
      # Clear connections, connection appearances, linking_phrases, linking phrase appearance
      CONNECTION_LIST_PATH.apply(@xml)[0].remove
      PHRASE_LIST_PATH.apply(@xml)[0].remove
      CONNECTION_APPEARANCE_LIST_PATH.apply(@xml)[0].remove
      PHRASE_APPEARANCE_LIST_PATH.apply(@xml)[0].remove
    end
    
    #TODO: Keys should not have name blocks, inputs need fixed, and this needs refactored.
    #TODO: This is ugly, fix it.
    def transform_into_problem_statement_map
      # Get an array which holds [edge_list, proposistion_height] before the edges are removed.
      propositions = self.proposition_list      
      # Get the maximum width and height in key.
      # TODO: Fix this so it only checks edges not both edges and nodes. See proposition block at end of method.       
      max_width = self.get_max_node_width
      
      self.remove_edges
      
      # Get max height of the nodes.
      max_height = self.get_max_node_height
      
      # Set initial x and y.
      x = max_width/2 + 5
      y = max_height/2 + 5
      
      # Change the x and y positions of each node.
      concepts_in_map.sort.each do |concept|
        set_concept_position concept, x.to_s, y.to_s
        # Move the y position to reflect the added nodes.
        y = y + max_height + 10
      end
      
      # Add the sample name block
      name_id = create_unique_id
      add_concept name_id, "Names:\nname1\nname2"
      y = y - max_height/2 + 27
      add_concept_appearance name_id, 37, y 
      
      # Add the propositions block
      proposition_id = create_unique_id
      add_concept proposition_id, propositions[0]
      # The phrase "Propositions:" creates a node with width 95
      proposition_x = 52
      # if one of the propositions is potentially wider than "Propositions:" take that width
      if x > proposition_x
        proposition_x = x
      end
      add_concept_appearance proposition_id, proposition_x, y + 10 + propositions[1]/2
    end
    
    def proposition_list
      vocab = self.vocabulary
      vocab = vocab.uniq.sort
      height = proposition_list_height vocab
      vocab_string = "Propositions:\n"
      vocab_string << vocab.join("\n")
      return vocab_string, height
    end
    
    protected
    
    def get_max_node_width
      max_width = 0
      CxlHelper.builder.anything.with("x", "width").apply(@xml).each do |node|
        width = node["width"].to_i
        if width > max_width
          max_width = width
        end
      end
      
      return max_width
    end
    
    def get_max_node_height
      max_height = 0
      CxlHelper.builder.anything.with("y", "height").apply(@xml).each do |node|
        height = node["height"].to_i
        if height > max_height
          max_height = height
        end
      end
      return max_height
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
    
    # This will return the number of connections in a map with distinct end points
    # TODO: Will this break if there is an edge concept1->concept2 and an edge concept2->concept1?
    def number_of_distinct_connections
      unique_pairs = 0
      each_unique_pair do |concept1, concept2|
        edges = edges_between concept1, concept2
        if edges.size > 0
          unique_pairs = unique_pairs + 1
        end
      end
      return unique_pairs
    end
    
    def mark_missing_edges key
      missing_found = false
      number_missing = 0
      
      key.each_unique_pair do |concept1, concept2|
        good_edges = key.edges_between(concept1, concept2)
        local_edges = self.edges_between(concept1, concept2)
        
        if !good_edges.empty? and (good_edges & local_edges).empty?
          make_missing_edge concept1, concept2
          number_missing = number_missing + 1
          Debug.missing_edge_between concept1, concept2
          missing_found = true
        end
      end
      
      Debug.no_missing_edges unless missing_found
      return number_missing
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
      "y" => y.to_s
      #"width" => LEGEND_NODE_WIDTH.to_s,
      #"height" => LEGEND_NODE_HEIGHT.to_s
      
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
      beginnings = CxlHelper.normalize CONNECTION_PATH.with_values("from-id" => start_id).value("to-id").apply @xml
      
      # Find the connections that end with node2.
      endings = CxlHelper.normalize CONNECTION_PATH.with_values("to-id" => end_id).value("from-id").apply @xml
      
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
      return CxlHelper.normalize PHRASE_PATH.value("label").apply(@xml)
    end
    
    def proposition_list_height vocab
      return (vocab.size + 1) * LEGEND_NODE_HEIGHT
    end
    
    def node_vocabulary
      # Find all of the node labels
      return CxlHelper.normalize CONCEPT_PATH.value("label").apply(@xml)
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
      
      return furthest
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
      
      posx, posy = new_edge_position start_id, end_id
      
      # Add its appearance.
      phrase_appearance = CxlHelper.create_node @xml,
      "linking-phrase-appearance",
      "id" => middle,
      "font-color" => MISSING_EDGE_COLOR,
      "x" => posx.to_s,
      "y" => posy.to_s,
      "width" => LEGEND_LABEL_WIDTH.to_s,
      "height" => LEGEND_LABEL_HEIGHT.to_s
      
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
    
    # Find a good position for a new node between the two ids.
    def new_edge_position concept1_id, concept2_id
      startx = CxlHelper.value(CONCEPT_APPEARANCE_PATH.with_values("id" => concept1_id).value("x").apply(@xml)).to_i
      starty = CxlHelper.value(CONCEPT_APPEARANCE_PATH.with_values("id" => concept1_id).value("y").apply(@xml)).to_i
      endx = CxlHelper.value(CONCEPT_APPEARANCE_PATH.with_values("id" => concept2_id).value("x").apply(@xml)).to_i
      endy = CxlHelper.value(CONCEPT_APPEARANCE_PATH.with_values("id" => concept2_id).value("y").apply(@xml)).to_i
      
      # Find the edges between the two, ignoring direction.
      edge_ids = edge_ids_between(concept1_id, concept2_id)
      edge_ids << edge_ids_between(concept2_id, concept1_id)
      
      # Determine which direction we should be adding nodes.
      concepts_horizontal = false
      if ((endx - startx).abs > (endy-starty).abs)
        # The nodes are oriented "mostly" horizontally.
        concepts_horizontal = true
      end
      
      # Find the safe position for the top-left of the new edge.
      # If there are no edges, we'll place the top-left such that the missing will be centered.
      left = (startx + endx - LEGEND_NODE_WIDTH) / 2
      bottom = (starty + endy - LEGEND_NODE_WIDTH) / 2
      
      edge_ids.each do |edge_id|
        x, y, width, height = location_info edge_id
        new_left = x + width/2
        new_bottom = y + height/2
        
        if (new_left > left and !concepts_horizontal)
          left = new_left
        end
        
        if (new_bottom > bottom and concepts_horizontal)
          bottom = new_bottom
        end
      end
      
      return left + LEGEND_NODE_WIDTH/2, bottom + LEGEND_NODE_HEIGHT/2
    end
    
    def location_info id
      x = CxlHelper.value(CxlHelper.builder.anything.with("id", "x").with_values("id" => id).value("x").apply(@xml)).to_i
      y = CxlHelper.value(CxlHelper.builder.anything.with("id", "y").with_values("id" => id).value("y").apply(@xml)).to_i
      width = CxlHelper.value(CxlHelper.builder.anything.with("id", "width").with_values("id" => id).value("width").apply(@xml)).to_i
      height = CxlHelper.value(CxlHelper.builder.anything.with("id", "height").with_values("id" => id).value("height").apply(@xml)).to_i
      
      return x, y, width, height
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