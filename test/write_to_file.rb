require "test/unit"
require "src/c_map"
require "rubygems"
require "nokogiri"
require "pp"

include Nokogiri::XML

#Just going to test this once and assume it works
  class WriteToFileTest < Test::Unit::TestCase
    def test_write_integ
      test = Builder.new do |xml|
        xml.cmap("xmlns" => "http://cmap.ihmc.us/xml/cmap/")
      end
      
      cmap = CMap::CMap.new(test.doc)
      cmap.write_to_file "write_test_output.cxl"
      
      readin = Nokogiri::XML(File.read("write_test_output.cxl"))
      
      assert_equal(readin.xpath("//map"), cmap.instance_variable_get(:@xml).xpath("//map"))
    end
  end