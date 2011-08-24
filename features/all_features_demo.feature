Feature: All features Demo
	Scenario: Manual check moving and grading
		Given key "large_scale_key.cxl" and input "large_scale_full_demo_input.cxl"
		When cmap-eval is executed
		Then the notification should contain:
			| Grade: 94% |
	Scenario: Manual check problem statement
		Given key "large_scale_key.cxl" and problem statement path "problem_statement"
		When cmap-eval is executed in problem statement mode
	Scenario: Generate acceptance test problem statement
		Given key "acceptance_test_key.cxl" and problem statement path "acceptance_statement"
		When cmap-eval is executed in problem statement mode
