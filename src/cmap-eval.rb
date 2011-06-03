# This is where execution begins in cmap-eval.  cmap-eval expects to be called from the command line, and uses several
# helper files, notably c_map.rb, to grade and mark cmaps.  Execution begins with a call to execute, which might call
# any of several local methods depending on the execution mode.

# Fix the search path so that all of our relative includes work.
$: << File.expand_path(File.dirname(__FILE__) + "/..")

require "src/Arguments_Helper"
# Set the batch boolean to true so some normal mode operations don't happen in batch mode.
def is_batch_mode
  @batch = true
end

# Grade and mark up one student input given the input and the key. 
def normal_mode key_file_name, input_file_name
  # Check that the key and input are both readable and that the input is writable. 
  Arguments_Helper.validate_readable key_file_name
  Arguments_Helper.validate_readable input_file_name
  Arguments_Helper.validate_writable input_file_name
  
  # Parse the XML of the key and the input.
  key_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
  input_map = CMap::CMap.new Nokogiri::XML File.read input_file_name
  
  # Output the names if we are only running on one map.
  if !@batch
    begin
      Output.names_block input_map.name_block
    rescue CMap::Error => error
      Output.exception error
    end
  end
  
  # Move the nodes to the key locations.
  input_map.move_nodes key_map
  grade = input_map.grade_using key_map
  # Write the changes back to the input file
  input_map.write_to_file input_file_name
  # Output the grade to the console if we are only running on one map.
  if !@batch
    Output.grade grade.to_s
  end
end

# Grade and mark up a batch of files at batch_path using key_file_name as the key. 
def batch_mode key_file_name, batch_path
  Arguments_Helper.validate_readable key_file_name
  d = Dir.new(batch_path)
  
  d.entries.each do |file_name|
    next if file_name.eql?(".") or file_name.eql?("..")
    if file_name.end_with? ".cxl"
      # If it is a cxl file then run the normal execution on it
      normal_mode key_file_name, batch_path + "/" + file_name
    elsif File.directory? batch_path + "/" + file_name
      # If it is a directory traverse through it recursively.
      batch_mode key_file_name, batch_path + "/" + file_name
    else
    end
  end
end

# Perform the main behaviors of cmap-eval; execute in :debug_mode, :problem_statement_mode, :batch_mode, or :normal_mode
# as needed.
def execute
  # Validate the arguments and get the mode the program should run in.
  Arguments_Helper.validate_arguments ARGV
  mode = Arguments_Helper.get_mode ARGV
  
  if mode == :debug_mode
    Debug.enable_debug
  end
  
  # Check the mode and react accordingly.
  if mode == :problem_statement_mode
    key_file_name, output_path = Arguments_Helper.get_problem_statement_names ARGV
    Arguments_Helper.validate_readable key_file_name
    
    problem_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
    
    # create the problem statement CMap with nodes
    problem_map.transform_into_problem_statement_map
    problem_map.write_to_file output_path + "/problem_statement.cxl"
  elsif mode == :batch_mode
    is_batch_mode
    key_file_name, batch_path = Arguments_Helper.get_batch_file_names ARGV
    batch_mode key_file_name, batch_path
  else
    key_file_name, input_file_name = Arguments_Helper.get_normal_file_names ARGV
    normal_mode key_file_name, input_file_name
  end
end

execute