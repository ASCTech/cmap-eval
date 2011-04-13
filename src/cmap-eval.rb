# TODO: We need to figure out a more sane build mechanism.
require "./src/parsing_helper.rb"

# Handle our hello world case.
if ARGV.size == 0
  puts "hello world"
else
  # Find the name block in the CXL.
  begin
    puts ParsingHelper::name_block_of ParsingHelper::document_at ARGV[0]
  rescue ParsingHelper::Error => error
    puts error.message
  end
end