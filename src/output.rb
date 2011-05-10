module Output
  def Output.bad_args_exit
    Output.wrong_args_error
    Output.help_message
    Output.exit
  end
  
  def Output.wrong_args_error
    Output.error "malformed arguments."
  end
  
  def Output.help_message
    puts "Command format:"
    puts "cmap-eval [-options] key-file input-file"
    puts
    puts "Options:"
    puts "-h : Display this help message."
    puts "-d : Enable debug mode."
  end
  
  def Output.names_block names
    puts "Names:"
    puts names.join("\n")
  end
  
  def Output.unreadable_file_error file_name
    Output.error %{File "#{file_name}" could not be read.}
  end
  
  def Output.unwritable_file_error file_name
    Output.error %{File "#{file_name}" could not be written."}
  end
  
  def Output.unwriteable_folder_error folder_name
    Output.error %{Folder "#{folder_name}" could not be written."}
  end

  def Output.exception except
    Output.error except.message
  end
  
  def Output.exit
    Process.exit
  end
  
  
  private
  
  def Output.error message
    puts "ERROR: " + message
  end
end