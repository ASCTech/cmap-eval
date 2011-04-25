Given /^no command-line arguments$/ do
  # Do nothing; there are no command-line arguments!
end

Given /^key "([^"]*)" and input "([^"]*)"$/ do |key, input|
  @key_file_name = INPUT_PATH + key
  @input_file_name = SANDBOX_PATH + input
  
  # Sanity-check the test files, so we're not mistakenly testing with invalid input.
  input_check key
  input_check input
  
  prep_sandbox_for input
end

Given /^the input file is "([^"]*)"$/ do |input|
  @input_file_name = SANDBOX_PATH + input
  
  input_check input
  
  prep_sandbox_for input
end

Given /^an input file that does not exist$/ do
  @input_file_name = INPUT_PATH + "does_not_exist.cxl"
  
  # Make sure the file DOESN'T exist.
  if File.readable? @input_file_name
    pending "File #{@input_file_name} does exist, but should not!"
  end
end

When /^cmap-eval is executed$/ do
  # Get a string containing the output of cmap-eval, separated by new-lines.
  @output = `ruby src/cmap-eval.rb #{@key_file_name} #{@input_file_name}`
  @output = output_from_execution "", @key_file_name, @input_file_name
end

When /^cmap-eval is executed in debug mode$/ do
  # Get a string containing the output of cmap-eval
  @output = output_from_execution "", @key_file_name, @input_file_name
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

Then /^the marked up file should look like "([^"]*)"$/ do |correct_file_name|
  if !File.readable? correct_file_name
    raise "File #{correct_file_name} does not exist!"
  else
    pending "Check file #{correct_file_name}."
  end
end