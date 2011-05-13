#TODO: figure out a sane build mechanism.
require "src/c_map"
require "src/debug"
require "src/output"

require "rubygems"
require "nokogiri"

# TODO: this needs significant cleanup.

def validate_arguments args
  # Check that there are arguments.
  if args.size == 0
    Output.bad_args_exit
  end
  
  # Check the help flag.
  if args[0] == "-h"
    Output.help_message
    Output.exit
  end
  
  # Check that there is at most 1 option, and it is at the start.
  args[1..-1].each do |arg|
    if arg.start_with? "-"
      Output.bad_args_exit
    end
  end
  
  # Check that, if we have an option, it is valid.
  if args[0].start_with? "-"
    if !["-h", "-d", "-p"].index args[0]
      Output.bad_args_exit
    end
  end
  
  # Check that we have exactly enough arguments.
  if args.size != 2 and args.size != 3
    Output.bad_args_exit
  end
  
  # Check that we don't have that anything that is expected to be an option is an option.
  if args.size == 3 and !args[0].start_with? "-"
    Output.bad_args_exit
  end
end

def get_mode args
  if args.size == 2
    return :normal_mode
  elsif args[0] == "-p"
    return :problem_statement_mode
  else
    return :debug_mode
  end
end

def validate_readable file_name
  if !File.readable? file_name
    Output.unreadable_file_error file_name
    Output.exit
  end
end

def validate_writable file_name
  if !File.writable? file_name
    Output.unwritable_file_error file_name
    Output.exit
  end
end

def get_normal_file_names args
  return args[-2], args[-1]
end

def get_problem_statement_names args
  return args[-2], args[-1]
end

def write_text_to_text_file file_name, text
  # Create the directory, if it doesn't already exist.
  
  if file_name.include? "\\" or file_name.include? "/"
    directory_part = file_name[/.*(?=[\/\\][^\/\\]*)/]
    
    if !File.exist? directory_part
      Dir.mkdir directory_part
    end
  end
  
  File.open file_name, "w" do |file|
    file.print text
  end
end

validate_arguments ARGV
mode = get_mode ARGV

if mode == :problem_statement_mode
  key_file_name, output_path = get_problem_statement_names ARGV
  validate_readable key_file_name
  
  problem_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
  # generate problem statement edge list in text file
  text = problem_map.generate_problem_statement_text
  write_text_to_text_file output_path + "/problem_statement.txt", text
  
  # create the problem statement CMap with nodes
  problem_map.transform_into_problem_statement_map
  problem_map.write_to_file output_path + "/problem_statement.cxl"
  
else
  if mode == :debug_mode
    Debug.enable_debug
  end
  
  key_file_name, input_file_name = get_normal_file_names ARGV
  validate_readable key_file_name
  validate_readable input_file_name
  validate_writable input_file_name
  
  key_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
  input_map = CMap::CMap.new Nokogiri::XML File.read input_file_name
  
  begin
    Output.names_block input_map.name_block
  rescue CMap::Error => error
    Output.exception error
  end
  
  
  grade = input_map.grade_using key_map
  input_map.write_to_file input_file_name
  # Output the grade to the console
  puts "Grade: " + grade.to_s + "%"
end