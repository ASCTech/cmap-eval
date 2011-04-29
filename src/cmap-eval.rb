#TODO: figure out a sane build mechanism.
require "src/c_map"
require "src/debug"
require "src/output"

require "rubygems"
require "nokogiri"

# TODO: this needs significant cleanup.

def check_inputs args
  key_file_name = nil
  input_file_name = nil
  
  if args.size == 0 or args.size > 3
    Output.wrong_args_error
    Output.help_message
    Output.exit
  elsif args.size == 1
    if args[0] != "-h"
      Output.wrong_args_error
    end
    
    Output.help_message
    Output.exit
  else
    key_file_name = args[-2]
    input_file_name = args[-1]
  end
  
  # Check the debug parameter.
  if args.size == 3 and args[0] == "-d"
    Debug.enable_debug
  end
  
  # Check our file names.
  if !File.readable? key_file_name
    Output.unreadable_file_error key_file_name
    Output.exit
  elsif !File.readable? input_file_name
    Output.unreadable_file_error input_file_name
    Output.exit
  end
  
  return key_file_name, input_file_name
end

key_file_name, input_file_name = check_inputs ARGV

key_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
input_map = CMap::CMap.new Nokogiri::XML File.read input_file_name

begin
  Output.names_block input_map.name_block
rescue CMap::Error => error
  Output.exception error
end

input_map.grade_using key_map
