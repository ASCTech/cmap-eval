Feature: Story 5: "assign a naive grade"
	Scenario: all connections present
		Given key "naive_grading_key.cxl" and input "correct_naive_grading.cxl"
		When cmap-eval is executed
		Then the notification should contain:
			| Grade: 100% |
	Scenario: one missing edge
		Given key "naive_grading_key.cxl" and input "naive_one_missing.cxl"
		When cmap-eval is executed
		Then the notification should contain:
			| Grade: 86% |
	Scenario: two missing
		Given key "naive_grading_key.cxl" and input "naive_two_missing.cxl"
		When cmap-eval is executed
		Then the notification should contain:
			| Grade: 71% |
	Scenario: three missing
		Given key "naive_grading_key.cxl" and input "naive_three_missing.cxl"
		When cmap-eval is executed
		Then the notification should contain:
			| Grade: 57% |
	Scenario: all edges missing
		Given key "naive_grading_key.cxl" and input "naive_all_missing.cxl"
		When cmap-eval is executed
		Then the notification should contain:
			| Grade: 0% |
