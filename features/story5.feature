Feature: Story 5: "assign a naive grade"
	Scenario: no missing or misplaced edges
		Given key "naive_grading_key.cxl" and input "correct_naive_grading.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 100% |
	Scenario: one misplaced edge
		Given key "naive_grading_key.cxl" and input "naive_one_misplaced.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is TODO: Figure out what the grade should be |
	Scenario: one missing edge
        Given key "naive_grading_key.cxl" and input "naive_one_missing.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is TODO: Figure out what the grade should be |
	Scenario: one missing, one misplaced
		Given key "naive_grading_key.cxl" and input "naive_missing_and_misplaced.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is TODO: Figure out what the grade should be |
	Scenario: multiple missing and misplaced
		Given key "naive_grading_key.cxl" and input "naive_multiple_missing_and_misplaced.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is TODO: Figure out what the grade should be |
	Scenario: all edges missing
		Given key "naive_grading_key.cxl" and input "naive_all_missing.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 0% |
	Scenario: all edges misplaced
		Given key "naive_grading_key.cxl" and input "naive_all_misplaced.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 0% |