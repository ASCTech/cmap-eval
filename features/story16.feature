Feature: Story 16: Mark misspelled edges.
	Scenario: No misspellings, some misplaced.
		Given key "misspellings_key.cxl" and input "no_misspellings_input.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| There are no misspelled edges. |
	Scenario: One misspelling.
		Given key "misspellings_key.cxl" and input "one_misspelling_input.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Misspelled edge "egde1" between: "node1" and "node2" |
			| There are no missing edges. |
	Scenario: Super-misspelling.
		Given key "misspellings_key.cxl" and input "super_misspelling_input.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| There are no misspelled edges. |
			| Extra edge "this edge is super-terrible!" between: "node1" and "node2" |
	Scenario: Manual check
		Given key "misspellings_key.cxl" and input "one_misspelling_input.cxl"
		When cmap-eval is executed
		Then the marked up file should look like "correct_misspellings.cxl"
