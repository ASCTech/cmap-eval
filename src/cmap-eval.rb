# TODO: We need to figure out a more sane build mechanism.
require "./src/parsing_helper.rb"

include ParseHelper

# Handle our hello world case.
if ARGV.size == 0
  puts "hello world"
else
  # Find the name block in the CXL.
  name_block = name_block_of document_at ARGV[0]
  
  if name_block.nil?
    puts "ERROR!"
  else
    puts name_block
  end
end