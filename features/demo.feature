Feature: Midterm Demo
	Scenario: Overview Graphics
		Given key "overview_key.cxl" and input "overview_input.cxl"
		When cmap-eval is executed
	Scenario: Manual check
		Given key "large_scale_key.cxl" and input "large_scale_input.cxl"
		When cmap-eval is executed