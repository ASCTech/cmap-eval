require File.expand_path('../../test_helper', __FILE__)

class EdgeLabelBetweenTest < Test::Unit::TestCase
	def test_no_edges_between
		test = Builder.new do |xml|
			xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") do
				xml.parent.namespace = xml.parent.namespace_definitions.first
				xml.map do
					xml.send(:"concept-list") do
						xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
						xml.concept("label" => "node2", "id" => "1JCK0VTLG-1FT6YS2-FV")
						xml.concept("label" => "node3", "id" => "1JCK0VTLG-1FT6YS3-FV")
					end
				end
			end
		end
		cmap = CMap::CMap.new(test.doc)
		assert_equal([],cmap.edges_between("node1","node2"))
	end

	def test_1_edge_between
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
		assert_equal(["edge1"],cmap.edges_between("node1","node2"))

		#test to make sure they don't work in reverse (edges are one way)
		assert_not_equal(["edge1"],cmap.edges_between("node2","node1"))
	end

	def test_mult_edge_between
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
		assert_equal(["edge1", "edge2"],cmap.edges_between("node1","node2"))

		#test to make sure they don't work in reverse (edges are one way)
		assert_not_equal(["edge1", "edge2"],cmap.edges_between("node2","node1"))
	end

	def test_several_nodes
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
		assert_equal(["edge1"],cmap.edges_between("node1","node2"))
		assert_equal(["edge2"],cmap.edges_between("node2","node3"))

		#test to make sure they don't work in reverse (edges are one way)

		assert_not_equal(["edge1"],cmap.edges_between("node2","node1"))
		assert_not_equal(["edge2"],cmap.edges_between("node3","node2"))
	end

	def test_circular_nodes
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
		assert_equal(["edge1"],cmap.edges_between("node1","node2"))
		assert_equal(["edge2"],cmap.edges_between("node2","node1"))

		#test to make sure they don't work in reverse (edges are one way)

		assert_not_equal(["edge1"],cmap.edges_between("node2","node1"))
		assert_not_equal(["edge2"],cmap.edges_between("node1","node2"))
	end
end
