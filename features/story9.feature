Feature: Story 9: "generate problem statement"
	Scenario: Manual check cmap portion
		Given key "big_key.cxl"
		When cmap-eval is executed
		Then the problem statement cmap file should look like "big_key_problem_statement.cxl"