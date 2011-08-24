require File.expand_path('../../test_helper', __FILE__)

class MarkMissingEdgeTest < Test::Unit::TestCase
	def test_blank_input
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		key = CMap::CMap.new(test.doc)
		correct = test.doc

		#This is not tested here, it's required to seed the @misspellings_list in the cmap.
		cmap.send(:mark_misplaced_and_extra_edges, key)

		cmap.send(:mark_missing_edges, key)
		#There should be no changes to the map, so these should be the same
		assert_equal(correct.xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@font-color]"), cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@font-color]"))
	end

	def test_identical_map_and_key
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
						xml.connection("id" => "idconnection1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "idconnection2", "from-id" => "idedge1", "to-id" => "idnode2")
						xml.connection("id" => "idconnection3", "from-id" => "idnode2", "to-id" => "idedge2")
						xml.connection("id" => "idconnection4", "from-id" => "idedge2", "to-id" => "idnode1")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
						xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
						xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
						xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "93", "hight" => "27")
						xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "42", "hight" => "33")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idconnection1", "width" => "1", "height" => "10")
						xml.send(:"connection-appearance", "id" => "idconnection2", "width" => "15", "height" => "30")
						xml.send(:"connection-appearance", "id" => "idconnection3", "width" => "97", "height" => "70")
						xml.send(:"connection-appearance", "id" => "idconnection4", "width" => "225600", "height" => "90")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		key = CMap::CMap.new(test.doc)
		correct = test.doc
		#This is not tested here, it's required to seed the @misspellings_list in the cmap.
		cmap.send(:mark_misplaced_and_extra_edges, key)

		cmap.send(:mark_missing_edges, key)

		#if there were no changes made, there should be no linking phrases with font color tags
		assert_equal(correct.xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@font-color]"), cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@font-color]"))

	end

	def test_missing_edge
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
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "idconnection1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "idconnection2", "from-id" => "idedge1", "to-id" => "idnode2")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
						xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
						xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
						xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "93", "hight" => "27")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idconnection1", "width" => "1", "height" => "10")
						xml.send(:"connection-appearance", "id" => "idconnection2", "width" => "15", "height" => "30")
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
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
						xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "idconnection1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "idconnection2", "from-id" => "idedge1", "to-id" => "idnode2")
						xml.connection("id" => "idconnection3", "from-id" => "idnode2", "to-id" => "idedge2")
						xml.connection("id" => "idconnection4", "from-id" => "idedge2", "to-id" => "idnode1")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
						xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
						xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
						xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "93", "hight" => "27")
						xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "42", "hight" => "33")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idconnection1", "width" => "1", "height" => "10")
						xml.send(:"connection-appearance", "id" => "idconnection2", "width" => "15", "height" => "30")
						xml.send(:"connection-appearance", "id" => "idconnection3", "width" => "97", "height" => "70")
						xml.send(:"connection-appearance", "id" => "idconnection4", "width" => "225600", "height" => "90")
					end
				end
			end
		end

		cmap = CMap::CMap.new(test.doc)
		key = CMap::CMap.new(correct.doc)
		xml = test.doc
		#This is not tested here, it's required to seed the @misspellings_list in the cmap.
		cmap.send(:mark_misplaced_and_extra_edges, key)

		cmap.send(:mark_missing_edges, key)

		#Missing edges should have been added
		correct_phrases = xml.xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance")
		test_phrases = cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance")
		assert_equal(correct_phrases.size, test_phrases.size)

		test_phrases = cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@font-color]")
		#only one phrase should have been added
		assert_equal(1, test_phrases.size)

		#they all should have a blue color
		test_phrases.each do |atrib|
			assert_equal("0,0,255,255", atrib.attr("font-color"))
		end
	end

	def test_mult_missing_edge
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
					end
					xml.send(:"connection-list") do
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
						xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
						xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
						xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
					end
					xml.send(:"linking-phrase-appearance-list") do
					end
					xml.send(:"connection-appearance-list") do
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
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
						xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "idconnection1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "idconnection2", "from-id" => "idedge1", "to-id" => "idnode2")
						xml.connection("id" => "idconnection3", "from-id" => "idnode2", "to-id" => "idedge2")
						xml.connection("id" => "idconnection4", "from-id" => "idedge2", "to-id" => "idnode1")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70", "width" => "2", "height" => "101")
						xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "900", "width" => "3", "height" => "102")
						xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "50", "width" => "4", "height" => "103")
						xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991", "width" => "5", "height" => "104")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "93", "hight" => "27")
						xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "42", "hight" => "33")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idconnection1", "width" => "1", "height" => "10")
						xml.send(:"connection-appearance", "id" => "idconnection2", "width" => "15", "height" => "30")
						xml.send(:"connection-appearance", "id" => "idconnection3", "width" => "97", "height" => "70")
						xml.send(:"connection-appearance", "id" => "idconnection4", "width" => "225600", "height" => "90")
					end
				end
			end
		end

		cmap = CMap::CMap.new(test.doc)
		key = CMap::CMap.new(correct.doc)
		xml = test.doc
		#This is not tested here, it's required to seed the @misspellings_list in the cmap.
		cmap.send(:mark_misplaced_and_extra_edges, key)

		cmap.send(:mark_missing_edges, key)

		#Missing edges should have been added
		correct_phrases = xml.xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance")
		test_phrases = cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance")
		assert_equal(correct_phrases.size, test_phrases.size)

		test_phrases = cmap.instance_variable_get(:@xml).xpath("//xmlns:linking-phrase-appearance-list/xmlns:linking-phrase-appearance[@font-color]")
		#only one phrase should have been added
		assert_equal(2, test_phrases.size)

		#they all should have a blue color
		test_phrases.each do |atrib|
			assert_equal("0,0,255,255", atrib.attr("font-color"))
		end
	end
end
