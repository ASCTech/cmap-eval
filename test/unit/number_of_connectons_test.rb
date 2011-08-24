require File.expand_path('../../test_helper', __FILE__)

class NumberOfConnectionsTest < Test::Unit::TestCase
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
		assert_equal(0, cmap.send(:number_of_distinct_connections))
	end

	def test_1_edge
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
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		assert_equal(1, cmap.send(:number_of_distinct_connections))
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
					end
					xml.send(:"linking-phrase-list") do
						xml.send(:"linking-phrase", "label" => "edge1", "id" => "idedge1")
						xml.send(:"linking-phrase", "label" => "edge2", "id" => "idedge2")
					end
					xml.send(:"connection-list") do
						xml.connection("id" => "node1toedge1", "from-id" => "idnode1", "to-id" => "idedge1")
						xml.connection("id" => "edge1tonode2", "from-id" => "idedge1", "to-id" => "idnode2")
						xml.connection("id" => "node1toedge2", "from-id" => "idnode1", "to-id" => "idedge2")
						xml.connection("id" => "edge2tonode2", "from-id" => "idedge2", "to-id" => "idnode2")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		assert_equal(2, cmap.send(:number_of_distinct_connections))
	end

	def test_circular_edges
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
						xml.connection("id" => "edge2tonode1", "from-id" => "idedge2", "to-id" => "idnode1")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		#This tests that 2 edges going between a set of nodes is counted
		#as a single unique connection.
		assert_equal(1,cmap.send(:number_of_distinct_connections))
	end
end
