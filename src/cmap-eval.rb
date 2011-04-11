require "rexml/document"

# Handle our hello world case.
if ARGV.size == 0
  puts "hello world"
else
  # Find the name block in the CXL.
  name_block_text = nil
  REXML::Document.new(File.read(ARGV[0])).elements.each("cmap/map/concept-list/concept") do |concept|
    if concept.attributes["label"].start_with?("Names:")
      name_block_text = concept.attributes["label"]
    end
  end
  
  if name_block_text.nil?
    puts "ERROR!"
  else
    puts name_block_text
  end
end