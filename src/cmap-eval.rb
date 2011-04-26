#TODO: figure out a sane build mechanism.
require "src/c_map"
require "src/debug"
require "src/output"
require "rubygems"
require "nokogiri"

key_file_name = nil
input_file_name = nil

if ARGV.size == 0 or ARGV.size > 3
  Output.wrong_args_error
  Output.help_message
  Output.exit
elsif ARGV.size == 1
  if ARGV[0] != "-h"
    Output.wrong_args_error
  end
  
  Output.help_message
  Output.exit
else
  key_file_name = ARGV[-2]
  input_file_name = ARGV[-1]
end

# Check our file names.
if !File.readable? key_file_name
  Output.unreadable_file_error key_file_name
  Output.exit
elsif !File.readable? input_file_name
  Output.unreadable_file_error input_file_name
  Output.exit
end

key_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
input_map = CMap::CMap.new Nokogiri::XML File.read input_file_name

begin
  # Output the name block on the input map.
  puts "Names:\n" + input_map.name_block.join("\n")
rescue CMap::Error => error
  puts error.message
end

