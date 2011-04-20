#TODO: figure out a sane build mechanism.
require "src/c_map"

require "rubygems"
require "nokogiri"

KEY_FILE_INDEX = 0
INPUT_FILE_INDEX = 1

# Handle our hello world case.
if ARGV.size == 0
  puts "hello world"
elsif ARGV.size == 1
  # Find the name block in the CXL.
  begin
    if !File.readable? ARGV[KEY_FILE_INDEX]
      puts "Error: The provided file does not exist."
    else
      infile = File.read ARGV[KEY_FILE_INDEX]
      
      cmap = CMap::CMap.new Nokogiri::XML infile
      names = cmap.name_block
      
      puts "Names:\n" + names.join("\n")
    end
  rescue CMap::Error=> error
    puts error.message
  end
end