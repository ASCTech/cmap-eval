require File.expand_path('../../test_helper', __FILE__)

class SetConceptPositionTest < Test::Unit::TestCase
	def test_1_edge_between
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "1JCK0VTLG-1FT6YS1-FV", "x" => "45", "y" => "70")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		cmap.set_concept_position("node1","0","0")

		assert_equal(["0", "0"],cmap.concept_position("node1"))
	end

	def test_mult_edge_between
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
						xml.concept("label" => "node2", "id" => "1JCK0VTLG-1FT6YS1-FC")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "1JCK0VTLG-1FT6YS1-FV", "x" => "45", "y" => "70")
						xml.send(:"concept-appearance", "id" => "1JCK0VTLG-1FT6YS1-FC", "x" => "21", "y" => "42")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		cmap.set_concept_position("node1","0","0")

		assert_equal(["0", "0"],cmap.concept_position("node1"))
		assert_equal(["21", "42"],cmap.concept_position("node2"))
	end
end
