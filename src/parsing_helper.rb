require "rexml/document"

module ParsingHelper
  # Important constants within a CXL file.
  XPATH_TO_CONCEPT = "cmap/map/concept-list/concept"
  LABEL_ATTRIBUTE = "label"
  NAME_BLOCK_PREFIX = "Names:"

  # Return the document with the given file name.
  def ParsingHelper.document_at(file_name)
    if File.readable? file_name      
      return REXML::Document.new(File.read(file_name))
    else
      raise Error, "Error: The provided file does not exist."
    end
  end
  
  # Return the name block, if there is a valid one, or raise an exception.
  def ParsingHelper.name_block_of(document)
    # Find the concept that resembles a name block.
    document.elements.each(XPATH_TO_CONCEPT) do |concept|
      label = concept.attributes[LABEL_ATTRIBUTE]
      
      # If the concept resembles a name block, we're home-free.
      if label.start_with? NAME_BLOCK_PREFIX
        # If the label only contains the name block prefix, return error
        if label.strip == NAME_BLOCK_PREFIX
          raise Error, "ERROR: There are no names in the name block."
        else
          return label
        end
      end
    end
    
    #We couldn't find a name block in the file.
    raise Error, "ERROR: Provided file is missing a name block."
  end
  
  class Error < Exception;
  end
end