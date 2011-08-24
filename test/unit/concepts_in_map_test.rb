require File.expand_path('../../test_helper', __FILE__)

  class ConceptsInMapTest < Test::Unit::TestCase

    def test_no_concepts
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list")
          }
        }
      end

      cmap = CMap::CMap.new(test.doc)
      assert_equal([], cmap.concepts_in_map)
    end

    def test_one_concept
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
            }
          }
        }
      end

      cmap = CMap::CMap.new(test.doc)
      assert_equal(["node1"], cmap.concepts_in_map)
    end

    def test_multiple_concepts
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/") {
          xml.parent.namespace = xml.parent.namespace_definitions.first
          xml.map {
            xml.send(:"concept-list") {
              xml.concept("label" => "node1", "id" => "1JCK0VTLG-1FT6YS1-FV")
              xml.concept("label" => "node2", "id" => "1JCK0VTLG-1FT6YS2-FV")
              xml.concept("label" => "node3", "id" => "1JCK0VTLG-1FT6YS3-FV")
            }
          }
        }
      end

      cmap = CMap::CMap.new(test.doc)
      assert_equal(["node1", "node2", "node3"], cmap.concepts_in_map)
    end
  end
