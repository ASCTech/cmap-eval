Feature: Story 14: Argument error messages.
	Scenario: No arguments.
		Given no command-line arguments
		When cmap-eval is executed
		Then the notification should show the command-line arguments error message
	Scenario: Help argument specified.
		Given options of "-h"
		When cmap-eval is executed
		Then the notification should show the help message
	Scenario: Unknown command option.
		Given options of "-z"
		When cmap-eval is executed
		Then the notification should show the command-line arguments error message
