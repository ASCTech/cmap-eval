require "fileutils"

INPUT_PATH = "features/input_files/"
SANDBOX_PATH = "sandbox/"

def input_check file_name
  relative_file_name = INPUT_PATH + file_name
  
  file_check relative_file_name
end

def file_check full_file_name
  if !File.readable? full_file_name
    pending "File #{full_file_name} does not exist!"
  end
end
  
def prep_sandbox_for input_file_name
  relative_input_file_name = INPUT_PATH + input_file_name
  sandbox_name = SANDBOX_PATH + input_file_name
  
  # Copy out the input file so we don't do any damage.
  begin
    FileUtils.cp relative_input_file_name, sandbox_name
  rescue Exception => error
    pending "Could not copy file #{sandbox_name} to sandbox!"
  end
end

def output_from_execution options, key, input
  return `ruby src/cmap-eval.rb #{options} #{key} #{input}`
end