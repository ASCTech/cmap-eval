Given /^the input file is "([^"]*)"$/ do |file_name|
  @input_file_name = "features/input_files/" + file_name
  if !File.readable? @input_file_name
    pending "File #{@input_file_name} does not exist!"
  end
end

Given /^an input file that does not exist$/ do
  @input_file_name = "features/input_files/does_not_exist.cxl"
  if File.readable? @input_file_name
    pending "File #{@input_file_name} does exist, but should not!"
  end
end

When /^cmap-eval is executed$/ do
  # Get a string containing the output of cmap-eval, separated by new-lines.
  @output = `ruby src/cmap-eval.rb #{@input_file_name}`
end

Then /^it will display "([^"]*)"$/ do |expected_output|
  @output.should == expected_output + "\n"
end

Then /^the notification should read:$/ do |notification_table|
  #Construct an array of arrays of strings to compare to our actual table.
  actual_table = [@output.split("\n")].transpose
  
  notification_table.diff!(actual_table)
end