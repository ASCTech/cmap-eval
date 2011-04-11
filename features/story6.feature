Feature: Story 6: "Parse name blocks"
	Scenario: No name block.
		Given the input file is "missing_name_block.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| ERROR! |
	Scenario: 0 names in the name block.
		Given the input file is "0_names_in_block.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| Names: |
	Scenario: 1 name in the name block.
		Given the input file is "1_name_in_block.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| Names: |
			| name1  |
	Scenario: 2 names in the name block.
		Given the input file is "2_names_in_block.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| Names: |
			| name1	 |
			| name2  |