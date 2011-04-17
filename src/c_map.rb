module CMap
  class CMap
    def initialize(raw_xml)
      @xml = raw_xml
    end
    
    def name_block
      concepts = @xml.xpath("/xmlns:cmap/xmlns:map/xmlns:concept-list/xmlns:concept")
      
      concepts.each do |concept|
        if concept["label"].start_with? "Names:"
          names = concept["label"].gsub(/^Names:/, "").strip.split("\n")
          
          if names.size > 0
            return names
          else
            raise Error, "ERROR: There are no names in the name block."
          end
          
        end
      end
      
      raise Error, "ERROR: Provided file is missing a name block."
    end
  end
  
  class Error < Exception
  end
end