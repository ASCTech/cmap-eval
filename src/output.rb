module Output
  def Output.wrong_args_error
    puts "ERROR: malformed arguments."
  end
  
  def Output.help_message
    puts "Command format:"
    puts "cmap-eval [-options] key-file input-file"
    puts
    puts "Options:"
    puts "-h : Display this help message."
    puts "-d : Enable debug mode."
  end
  
  def Output.unreadable_file_error file_name
    puts %{ERROR: File "#{file_name}" could not be read.}
  end
  
  def Output.exit
    Process.exit
  end
end