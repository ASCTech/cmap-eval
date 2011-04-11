require "rexml/document"

module ParseHelper
  # Important constants within a CXL file.
  XPATH_TO_CONCEPT = "cmap/map/concept-list/concept"
  LABEL_ATTRIBUTE = "label"
  NAME_BLOCK_PREFIX = "Names:"

  # Return the document with the given file name.
  def document_at(file_name)
    return REXML::Document.new(File.read(file_name))
  end
  
  # Return the name block, if there is a valid one, or nil.
  def name_block_of(document)
    name_block = nil
    
    # Find the concept that resembles a name block.
    document.elements.each(XPATH_TO_CONCEPT) do |concept|
      label = concept.attributes[LABEL_ATTRIBUTE]
      if label.start_with? NAME_BLOCK_PREFIX
        name_block = label
      end
    end
    
    return name_block
  end
end