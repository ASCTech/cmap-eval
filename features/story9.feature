Feature: Story 9: "generate problem statement"
	Scenario: Manual check cmap portion
		Given key "big_key.cxl" and problem statement path "problem_statement"
		When cmap-eval is executed in problem statement mode
		Then the problem statement cmap file should exist
		And the problem statement cmap file should look like "big_key_problem_statement.cxl"