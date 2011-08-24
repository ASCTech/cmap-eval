require File.expand_path('../../test_helper', __FILE__)

class ConceptsInMapTest < Test::Unit::TestCase
	def test_no_edges
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
				end
			end
		end

		cmap = CMap::CMap.new(test.doc)
		cmap.remove_edges

		assert_equal(test.doc, cmap.instance_variable_get(:@xml))
	end

	def test_1_edge
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
					end
					xml.send(:"linking-phrase-list") do
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
					end
					xml.send(:"connection-list") do
						xml.connection("label" => "fromnode1toedge1", "id" => "idfromedge1toedge1")
						xml.connection("label" => "fromedge1tonode2", "id" => "idfromedge1tonode2")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idfromedge1toedge1")
						xml.send(:"connection-appearance", "id" => "idfromedge1tonode2")
					end
				end
			end
		end

		correct = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
					end
					xml.send(:"linking-phrase-list") do
					end
					xml.send(:"connection-list") do
					end
					xml.send(:"linking-phrase-appearance-list") do
					end
					xml.send(:"connection-appearance-list") do
					end
				end
			end
		end

		xml = correct.doc
		cmap = CMap::CMap.new(test.doc)
		cmap.remove_edges

		#Make sure the nodes are still there
		assert_equal(xml.xpath("//concept-list/concept"), cmap.instance_variable_get(:@xml).xpath("//concept-list/concept"))

		assert_equal(xml.xpath("//linking-phrase-list/linking-phrase"), cmap.instance_variable_get(:@xml).xpath("//linking-phrase-list/linking-phrase"))
		assert_equal(xml.xpath("//connection-list/connection"), cmap.instance_variable_get(:@xml).xpath("//connection-list/connection"))
		assert_equal(xml.xpath("//linking-phrase-appearance-list/linking-phrase-appearance"), cmap.instance_variable_get(:@xml).xpath("//linking-phrase-appearance-list/linking-phrase-appearance"))
		assert_equal(xml.xpath("//connection-appearance-list/connection-appearance"), cmap.instance_variable_get(:@xml).xpath("//connection-appearance-list/connection-appearance"))
	end

	def test_mult_edge
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
						xml.concept("label" => "node4", "id" => "idnode4")
					end
					xml.send(:"linking-phrase-list") do
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
						xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
					end
					xml.send(:"connection-list") do
						xml.connection("label" => "fromnode1toedge1", "id" => "idfromedge1toedge1")
						xml.connection("label" => "fromedge1tonode2", "id" => "idfromedge1tonode2")
						xml.connection("label" => "fromnode3toedge2", "id" => "idfromedge3toedge2")
						xml.connection("label" => "fromedge2tonode4", "id" => "idfromedge2tonode4")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1")
						xml.send(:"linking-phrase-appearance", "id" => "idedge2")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idfromedge1toedge1")
						xml.send(:"connection-appearance", "id" => "idfromedge1tonode2")
						xml.send(:"connection-appearance", "id" => "idfromedge3toedge2")
						xml.send(:"connection-appearance", "id" => "idfromedge2tonode4")
					end
				end
			end
		end

		correct = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
						xml.concept("label" => "node4", "id" => "idnode4")
					end
					xml.send(:"linking-phrase-list") do
					end
					xml.send(:"connection-list") do
					end
					xml.send(:"linking-phrase-appearance-list") do
					end
					xml.send(:"connection-appearance-list") do
					end
				end
			end
		end

		xml = correct.doc
		cmap = CMap::CMap.new(test.doc)
		cmap.remove_edges

		#Make sure the nodes are still there
		assert_equal(xml.xpath("//concept-list/concept"), cmap.instance_variable_get(:@xml).xpath("//concept-list/concept"))

		assert_equal(xml.xpath("//linking-phrase-list/linking-phrase"), cmap.instance_variable_get(:@xml).xpath("//linking-phrase-list/linking-phrase"))
		assert_equal(xml.xpath("//connection-list/connection"), cmap.instance_variable_get(:@xml).xpath("//connection-list/connection"))
		assert_equal(xml.xpath("//linking-phrase-appearance-list/linking-phrase-appearance"), cmap.instance_variable_get(:@xml).xpath("//linking-phrase-appearance-list/linking-phrase-appearance"))
		assert_equal(xml.xpath("//connection-appearance-list/connection-appearance"), cmap.instance_variable_get(:@xml).xpath("//connection-appearance-list/connection-appearance"))
	end
end
