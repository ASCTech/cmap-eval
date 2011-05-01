@Kyle
Feature: Story 10: "mark extraneous edges"
	Scenario: no extra edges
		Given key "extra_key.cxl" and input "extra_key.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| There are no extra edges. |
	Scenario: one extra edge
		Given key "extra_key.cxl" and input "extra_edge_one.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Extra edge between: "node1" and "node2" |
	Scenario: multiple extra edges
		Given key "extra_key.cxl" and input "extra_edge_multiple.cxl"
		When cmap-eval is executed in debug mode
		Then the notification should contain:
			| Extra edge between: "node1" and "node2" |
			| Extra edge between: "node3" and "node4" |
	Scenario: Manual check
		Given key "extra_key.cxl" and input "extra_edge_multiple.cxl"
		When cmap-eval is executed
		Then the marked up file should look like "correct_extra_multiple.cxl"