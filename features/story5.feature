Feature: Story 5: "assign a naive grade"
	Scenario: all connections present
		Given key "naive_grading_key.cxl" and input "correct_naive_grading.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 100% |
	Scenario: one missing edge
        Given key "naive_grading_key.cxl" and input "naive_one_missing.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 86% |
	Scenario: two missing
		Given key "naive_grading_key.cxl" and input "naive_two_missing.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 71% |
	Scenario: four missing
		Given key "naive_grading_key.cxl" and input "naive__missing.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 43% |
	Scenario: all edges missing
		Given key "naive_grading_key.cxl" and input "naive_all_missing.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| The grade is 0% |