require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML
#I could probably test this a thousand ways, but that would take forever
  class InitializeTest < Test::Unit::TestCase
    def test_empty_map
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
      end
      
      cmap = CMap::CMap.new(test.doc)
      
      assert_equal(test.doc, cmap.instance_variable_get(:@xml))
    end
    
    #I can't get this to run for the life of me, if you can figure it out go for it.
    def test_full_map
      test = Nokogiri::XML(File.read("../features/input_files/complex_edge_key.cxl"))
      
      cmap = CMap::CMap.new(test.doc)
      assert_equal(test.doc, cmap.instance_variable_get(:@xml))
    end
  end