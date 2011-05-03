Feature: Story 10: "mark misplaced edges"
	Scenario: no misplaced edges
		Given key "misplaced_key.cxl" and input "misplaced_key.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| There are no extra edges. |
	Scenario: one misplaced edge
		Given key "misplaced_key.cxl" and input "misplaced_edge_one.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Misplaced edge "edge2" between: "node1" and "node3" |
	Scenario: multiple extra edges
		Given key "misplaced_key.cxl" and input "misplaced_edge_multiple.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Misplaced edge "edge2" between: "node4" and "node2" |
			| Misplaced edge "edge1" between: "node3" and "node4" |
	Scenario: Manual check
		Given key "misplaced_key.cxl" and input "misplaced_edge_multiple.cxl"
		When cmap-eval is executed
		Then the marked up file should look like "correct_misplaced_edge_multiple.cxl"