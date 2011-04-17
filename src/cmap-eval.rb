#TODO: figure out a sane build mechanism.
require "src/c_map"

require "rubygems"
require "nokogiri"

# Handle our hello world case.
if ARGV.size == 0
  puts "hello world"
else
  # Find the name block in the CXL.
  begin
    if !File.readable? ARGV[0]
      puts "Error: The provided file does not exist."
    else
      infile = File.read ARGV[0]
      
      cmap = CMap::CMap.new Nokogiri::XML infile
      names = cmap.name_block
      
      puts "Names:\n" + names.join("\n")
    end
  rescue CMap::Error=> error
    puts error.message
  end
end