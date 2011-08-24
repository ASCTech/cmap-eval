require File.expand_path('../../test_helper', __FILE__)

class CreateAppearancesConceptsTest < Test::Unit::TestCase
	def test_no_concepts
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.map do
				end
			end
		end

		expected = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.map do
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		cmap.create_appearances_for_concepts()

		concept_appear = expected.doc
		xml = cmap.instance_variable_get(:@xml)

		assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
	end

	def test_1_existing_concept_appearance
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				#xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1")
					end
				end
			end
		end

		expected = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				#xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		cmap.create_appearances_for_concepts()

		concept_appear = expected.doc
		xml = cmap.instance_variable_get(:@xml)

		assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
	end

	def test_1_concept
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				#xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
					end
				end
			end
		end

		expected = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				#xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		cmap.create_appearances_for_concepts()

		concept_appear = expected.doc
		xml = cmap.instance_variable_get(:@xml)

		assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
	end

	def test_mult_edges
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				#xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
				end
			end
		end

		expected = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				#xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1")
						xml.send(:"concept-appearance", "id" => "idnode2")
						xml.send(:"concept-appearance", "id" => "idnode3")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		cmap.create_appearances_for_concepts()

		concept_appear = expected.doc
		xml = cmap.instance_variable_get(:@xml)

		assert_equal(concept_appear.xpath("//concept-appearance"), xml.xpath("//concept-appearance"))
	end
end
