INPUT_PATH = "features/input_files/"

Given /^key "([^"]*)" and input "([^"]*)"$/ do |key, input|
  @key_file_name = INPUT_PATH + key
  @input_file_name = INPUT_PATH + input
  
  if !File.readable? @key_file_name
    pending "File #{@key_file_name} does not exist!"
  elsif !File.readable? @input_file_name
    pending "File #{@input_file_name} does not exist!"
  end
end

Given /^the input file is "([^"]*)"$/ do |file_name|
  @input_file_name = INPUT_PATH + file_name
  
  if !File.readable? @input_file_name
    pending "File #{@input_file_name} does not exist!"
  end
end

Given /^an input file that does not exist$/ do
  @input_file_name = INPUT_PATH + "does_not_exist.cxl"
  if File.readable? @input_file_name
    pending "File #{@input_file_name} does exist, but should not!"
  end
end

When /^cmap-eval is executed$/ do
  # Get a string containing the output of cmap-eval, separated by new-lines.
  @output = `ruby src/cmap-eval.rb #{@key_file_name} #{@input_file_name}`
end

Then /^it will display "([^"]*)"$/ do |expected_output|
  @output.should == expected_output + "\n"
end

Then /^the notification should read:$/ do |notification_table|
  #Construct an array of arrays of strings to compare to our actual table.
  actual_table = [@output.split("\n")].transpose
  
  notification_table.diff!(actual_table)
end

Then /^the notification should contain:$/ do |notification_table|
  #Construct an array of arrays of strings to compare to our actual table.
  actual_table = [@output.split("\n")].transpose
  
  notification_table.raw.each do |expected|
    if !actual_table.include? expected
      raise %{Notification \n "#{actual_table}"\n did not contain \n"#{expected}".}
    end
  end
end