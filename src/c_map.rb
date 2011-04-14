class CMap
  XPATH_TO_CONCEPT = "cmap/map/concept-list/concept"
  LABEL_ATTRIBUTE = "label"
  NAME_BLOCK_PREFIX = "Names:"
  
  def initialize(raw_xml)
    @internal_xml = raw_xml
  end
  
  def name_block
    @internal_xml.elements.each(XPATH_TO_CONCEPT) do |concept|
      label = concept.attributes[LABEL_ATTRIBUTE]
      
      # If the concept resembles a name block, we're home-free.
      if label.start_with? NAME_BLOCK_PREFIX
        # If the label only contains the name block prefix, return error
        if label.strip == NAME_BLOCK_PREFIX
          raise Error, "ERROR: There are no names in the name block."
        end
        return label
      end
    end
  end
end