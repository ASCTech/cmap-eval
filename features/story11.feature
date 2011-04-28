Feature: Story 11: "mark missing edges"
	Scenario: One edge no missing edges
		Given key "simple_key.cxl" and input "simple_key.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| There are no missing edges. |
	Scenario: One edge one missing edge
		Given key "simple_key.cxl" and input "simple_wrong_input.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Missing edge between: "node1" and "node2" |
	Scenario: Big input file
		Given key "big_key.cxl" and input "big_missing_edges.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Missing edge between: "node1" and "node2" |
			| Missing edge between: "node3" and "node4" |
	Scenario: Multiple acceptable edges between two nodes
		Given key "complex_edge_key.cxl" and input "correct_edge_subset_input.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| There are no missing edges. |
	Scenario: Manual check
		Given key "big_key.cxl" and input "big_missing_edges.cxl"
		When cmap-eval is executed
		Then the marked up file should look like "correct_big_missing_edges.cxl"