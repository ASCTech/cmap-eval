When /^cmap-eval is executed$/ do
  @output = `ruby src/cmap-eval.rb`.chomp
end

Then /^it will display "([^"]*)"$/ do |expected_output|
  @output.should == expected_output
end