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
else
  # Parse the maps.
  begin
    if !File.readable? ARGV[KEY_FILE_INDEX]
      puts %{Error: The provided file #{ARGV[KEY_FILE_INDEX]} does not exist.}
    elsif !File.readable? ARGV[INPUT_FILE_INDEX]
      puts %{Error: The provided file #{ARGV[INPUT_FILE_INDEX]} does not exist.}
    else
      # Parse the supplied files.
      key_cmap = CMap::CMap.new Nokogiri::XML File.read ARGV[KEY_FILE_INDEX]
      input_cmap = CMap::CMap.new Nokogiri::XML File.read ARGV[INPUT_FILE_INDEX]
      
      if key_cmap.equal? input_cmap
        puts %{COMPARISON: Identical.}
      else
        puts %{COMPARISON: Not identical.}
      end
    end
  end
end