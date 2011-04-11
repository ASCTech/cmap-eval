# TODO: We need to figure out a more sane build mechanism.
require "./src/parsing_helper.rb"

include ParsingHelper

# Handle our hello world case.
if ARGV.size == 0
  puts "hello world"
else
  # Find the name block in the CXL.
  begin
    name_block = name_block_of document_at ARGV[0]
    puts name_block
  rescue ParsingHelper::Error => error
    puts error.message
  end
end