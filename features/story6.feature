Feature: Story 6: "Parse name blocks"
	Scenario: No name block.
		Given the input file is "missing_name_block.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| ERROR: Provided file is missing a name block. |
	Scenario: 0 names in the name block.
		Given the input file is "0_names_in_block.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| ERROR: There are no names in the name block. |
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
	Scenario: Names with non-name concepts.
		Given the input file is "names_with_non_names.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| Names:    |
			| Bob Dylan |
			| Bono      |
	Scenario: File does not exist.
		Given an input file that does not exist
		When cmap-eval is executed
		Then the notification should read:
			| Error: The provided file does not exist. |
	Scenario: CXL file is malformed.
		Given the input file is "malformed_file.cxl"
		When cmap-eval is executed
		Then the notification should read:
			| ERROR: Provided file is missing a name block. |