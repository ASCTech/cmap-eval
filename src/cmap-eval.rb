#TODO: figure out a sane build mechanism.
require "src/arguments_helper"

# TODO: this needs significant cleanup.
arg_helper = Arguments::Arguments_Helper.new
arg_helper.validate_arguments ARGV
mode = arg_helper.get_mode ARGV

if mode == :problem_statement_mode
  key_file_name, output_path = arg_helper.get_problem_statement_names ARGV
  arg_helper.validate_readable key_file_name
  
  problem_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
  
  # create the problem statement CMap with nodes
  problem_map.transform_into_problem_statement_map
  problem_map.write_to_file output_path + "/problem_statement.cxl"
  
else
  if mode == :debug_mode
    Debug.enable_debug
  end
  
  key_file_name, input_file_name = arg_helper.get_normal_file_names ARGV
  arg_helper.validate_readable key_file_name
  arg_helper.validate_readable input_file_name
  arg_helper.validate_writable input_file_name
  
  key_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
  input_map = CMap::CMap.new Nokogiri::XML File.read input_file_name
  
  begin
    Output.names_block input_map.name_block
  rescue CMap::Error => error
    Output.exception error
  end
  
  
  input_map.move_nodes key_map
  grade = input_map.grade_using key_map
  input_map.write_to_file input_file_name
  # Output the grade to the console
  puts "Grade: " + grade.to_s + "%"
end