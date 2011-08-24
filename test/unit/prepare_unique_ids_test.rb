require File.expand_path('../../test_helper', __FILE__)

class UniqueIdsTest < Test::Unit::TestCase
	def test_no_id
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
					end
				end
			end
		end
		c_map = CMap::CMap.new(test.doc)

		assert_equal("0", c_map.instance_variable_get(:@previous_safe_id))
	end

	def test_single_id
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("id" => "1JCK0VTLG-1FT6YS1-FV")
					end
				end
			end
		end
		c_map = CMap::CMap.new(test.doc)

		assert_equal("1JCK0VTLG-1FT6YS1-FV", c_map.instance_variable_get(:@previous_safe_id))
	end

	def test_mult_id
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first

				xml.map do
					xml.send(:"concept-list") do
						xml.concept("id" => "1JCK0VTLG-1FT6YS1-FV")
						xml.concept("id" => "1JCK12PWV-103W7MZ-H2")
					end
				end
			end
		end
		c_map = CMap::CMap.new(test.doc)

		assert_equal "1JCK12PWV-103W7MZ-H2", c_map.instance_variable_get(:@previous_safe_id)
	end
end
