Feature: Story 13: "generate legend"
	Scenario: Manual check
		Given key "big_key.cxl" and input "big_missing_edges.cxl"
		When cmap-eval is executed
		Then the marked up file should look like "correct_big_missing_edges_with_legend.cxl"
