Feature: Story 14: Argument error messages.
	Scenario: No arguments.
		Given no command-line arguments
		When cmap-eval is executed
		Then the notification should show the command-line arguments error message.
	Scenario: Help argument specified.
		Given command-line arguments of "-h"
		When cmap-eval is executed
		Then the notification should show the help message
	Scenario: Unknown command option.
		Given command-line arguments of "-z"
		When cmap-eval is executed
		Then the notification should show the command-line arguments error message.