require File.expand_path('../../test_helper', __FILE__)

class GradeUsingTest < Test::Unit::TestCase
	def test_perfect
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
					xml.send(:"linking-phrase-list") do
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
						xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
						xml.connection("id" => "node2toedge2", "from-id" => "idnode2", "to-id" => "idedge2")
						xml.connection("id" => "edge2tonode3", "from-id" => "idedge2", "to-id" => "idnode3")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		key = CMap::CMap.new(test.doc)

		assert_equal(100,cmap.grade_using(key))
	end

	def test_1_missing
		map = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
					xml.send(:"linking-phrase-list") do
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
					end
				end
			end
		end

		good_map = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "idnode1")
						xml.concept("label" => "node2", "id" => "idnode2")
						xml.concept("label" => "node3", "id" => "idnode3")
					end
					xml.send(:"linking-phrase-list") do
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
						xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
						xml.connection("id" => "node2toedge2", "from-id" => "idnode2", "to-id" => "idedge2")
						xml.connection("id" => "edge2tonode3", "from-id" => "idedge2", "to-id" => "idnode3")
					end
				end
			end
		end
		cmap = CMap::CMap.new(map.doc)
		key = CMap::CMap.new(good_map.doc)

		assert_equal(50,cmap.grade_using(key))
	end

end
