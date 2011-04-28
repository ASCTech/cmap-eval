#TODO: figure out a sane build mechanism.
require "src/c_map"
require "src/debug"
require "src/output"
require "rubygems"
require "nokogiri"

# TODO: this needs significant cleanup.
def mark_missing_edges key, input
  concepts = key.concepts
  
  missing_found = false
  
  # TODO: we should change this into some sort of enumerator.
  concepts.each do |elem1|
    concepts.each do |elem2|
      if elem1 != elem2
        if key.edges_between(elem1, elem2).size > 0
          missing_found = true
          Debug.missing_edge_between elem1, elem2
        end
      end
    end
  end
  
  if !missing_found
    Debug.no_missing_edges
  end
end

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

# Check the debug parameter.
if ARGV.size == 3 and ARGV[0] == "-d"
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

key_map = CMap::CMap.new Nokogiri::XML File.read key_file_name
input_map = CMap::CMap.new Nokogiri::XML File.read input_file_name

begin
# Output the name block on the input map.
  puts "Names:\n" + input_map.name_block.join("\n")
rescue CMap::Error => error
  puts error.message
end

mark_missing_edges key_map, input_map
