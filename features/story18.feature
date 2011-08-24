Feature: Story 18: "batch execution"
	Scenario: Manual check cmap portion
		Given key "batch_key.cxl" and batch path "batch_input"
		When cmap-eval is executed in batch mode

