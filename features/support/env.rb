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

def prepare_batch_array batch
  if batch.include? "."
    batch.delete "."
  end
  if batch.include? ".."
    batch.delete ".."
  end
  if batch.include? ".svn"
    batch.delete ".svn"
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

# Copy all cxl files recursively.
def prep_sandbox_for_batch batch_path
  relative_input_file_name = INPUT_PATH + batch_path
  sandbox_name = SANDBOX_PATH + batch_path

  FileUtils.cp_r relative_input_file_name, sandbox_name
  #$stderr.puts sandbox_name + "/.svn"
  FileUtils.rm_r sandbox_name + "/.svn"
  
#  d = Dir.new(relative_input_file_name)
#  d.each do |f|
#    next if f.eql?(".") or f.eql?("..") or f.eql?(".svn")#
#
#    # If f is directory , call prep_sandbox on it
#    path = relative_input_file_name + "/" + "#{f}"
#    if File.stat(path).directory?
#      copy_batch path
#    else
#      sandbox_name = SANDBOX_PATH + batch_path + "/" + f
#      begin
#        $stderr.puts path
#        $stderr.puts sandbox_name
#        FileUtils.cp path, sandbox_name
#      rescue Exception => error
#        pending "Could not copy file #{path} to sandbox!"
#      end
#    end
#  end
end

def output_from_execution options, key, input
  return `ruby src/cmap-eval.rb #{options} #{key} #{input}`
end