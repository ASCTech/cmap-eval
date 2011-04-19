Feature: Story 2: "identical map" checker.
	Scenario: two empty maps, same name block.
		Given key "empty_map.cxl" and input "empty_map.cxl"
		When cmap-eval is executed
		Then the notification should contain:
		| COMPARISON: Identical. |
	Scenario: two empty maps, different name block.
		Given key "empty_map_2.cxl" and input "empty_map.cxl"
		When cmap-eval is executed
		Then the notification should contain:
		| COMPARISON: Identical. |
	Scenario: maps differ by nodes.
		Given key "map_with_2_nodes.cxl" and input "map_with_2_nodes_2.cxl"
		When cmap-eval is executed
		Then the notification should contain:
		| COMPARISON: Not identical. |
	Scenario: maps differ by edges.
		Given key "map_with_two_edges.cxl" and input "map_with_two_edges_2.cxl"
		When cmap-eval is executed
		Then the notification should contain:
		| COMPARISON: Not identical. |
	Scenario: two large identical maps.
		Given key "large_map.cxl" and input "large_map_2.cxl"
		When cmap-eval is executed
		Then the notification should contain:
		| COMPARISON: Identical. |