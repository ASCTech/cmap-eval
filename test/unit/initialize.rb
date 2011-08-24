require File.expand_path('../../test_helper', __FILE__)

#I could probably test this a thousand ways, but that would take forever
class InitializeTest < Test::Unit::TestCase
	def test_empty_map
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
		end

		cmap = CMap::CMap.new(test.doc)

		assert_equal(test.doc, cmap.instance_variable_get(:@xml))
	end

	def test_full_map
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
						xml.connection("id" => "idconnection3", "from-id" => "idnode3", "to-id" => "idedge2")
						xml.connection("id" => "idconnection4", "from-id" => "idedge2", "to-id" => "idnode4")
					end
					xml.send(:"concept-appearance-list") do
						xml.send(:"concept-appearance", "id" => "idnode1", "x" => "45", "y" => "70")
						xml.send(:"concept-appearance", "id" => "idnode2", "x" => "21", "y" => "42")
						xml.send(:"concept-appearance", "id" => "idnode3", "x" => "225600", "y" => "225600")
						xml.send(:"concept-appearance", "id" => "idnode4", "x" => "9000", "y" => "8991")
					end
					xml.send(:"linking-phrase-appearance-list") do
						xml.send(:"linking-phrase-appearance", "id" => "idedge1", "x" => "1", "y" => "1", "width" => "10", "hight" => "10")
						xml.send(:"linking-phrase-appearance", "id" => "idedge2", "x" => "20", "y" => "20", "width" => "10", "hight" => "10")
					end
					xml.send(:"connection-appearance-list") do
						xml.send(:"connection-appearance", "id" => "idconnection1")
						xml.send(:"connection-appearance", "id" => "idconnection2")
						xml.send(:"connection-appearance", "id" => "idconnection3")
						xml.send(:"connection-appearance", "id" => "idconnection4")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		assert_equal(test.doc, cmap.instance_variable_get(:@xml))
	end
end
