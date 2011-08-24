Feature: Story 15: Better additional edge placement.
	Scenario: Vertical concept orientation.
		Given key "vertical_key.cxl" and input "vertical_input.cxl"
		When cmap-eval is executed
		Then there should be no overlapping nodes
	Scenario: Horizontal concept orientation.
		Given key "horizontal_key.cxl" and input "horizontal_input.cxl"
		When cmap-eval is executed
		Then there should be no overlapping nodes
