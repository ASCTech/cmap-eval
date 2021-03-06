require File.expand_path('../../test_helper', __FILE__)

class NameBlockTest < Test::Unit::TestCase
	def test_missing_name_block_in_empty_map
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list")
				end
			end
		end

		cmap = CMap::CMap.new(test.doc)

		assert_raise(CMap::Error) {
			puts cmap.name_block.class
		}

		begin
			cmap.name_block
		rescue CMap::Error => error
			assert_equal "Provided file is missing a name block.", error.message
		end
	end

	def test_missing_name_block_in_normal_map
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				# Fix the namespace.  Necessary because the root is in the namespace.
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "Node1", "id" => "idnode1")
					end
				end
			end
		end

		c_map = CMap::CMap.new(test.doc)

		assert_raise(CMap::Error) {
			puts c_map.name_block.class
		}

		begin
			c_map.name_block
		rescue CMap::Error => error
			assert_equal "Provided file is missing a name block.", error.message
		end
	end

	def test_empty_name_block
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				# Fix the namespace.  Necessary because the root is in the namespace.
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "Names:\n", "id" => "idname")
					end
				end
			end
		end

		c_map = CMap::CMap.new(test.doc)

		begin
			c_map.name_block
		rescue CMap::Error => error
			assert_equal "There are no names in the name block.", error.message
		end

		assert_raise(CMap::Error) {
			c_map.name_block
		}
	end

	def test_1_name_block
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				# Fix the namespace.  Necessary because the root is in the namespace.
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "Names:\nname1", "id" => "idname")
					end
				end
			end
		end

		c_map = CMap::CMap.new(test.doc)

		assert_equal(["name1"], c_map.name_block)
	end

	def test_2_name_block
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				# Fix the namespace.  Necessary because the root is in the namespace.
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "Names:\nname1\nname2", "id" => "idname")
					end
				end
			end
		end

		c_map = CMap::CMap.new test.doc

		assert_equal(["name1", "name2"], c_map.name_block)
	end

	def test_name_block_with_other_node
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				# Fix the namespace.  Necessary because the root is in the namespace.
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "Node1")
						xml.concept("label" => "Names:\nname1", "id" => "idname")
					end
				end
			end
		end

		c_map = CMap::CMap.new(test.doc)

		assert_equal(["name1"], c_map.name_block)
	end
end
