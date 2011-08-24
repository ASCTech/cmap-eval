# Methods that make it easy to display standard debug messages to the console.
module Debug
	# Make it globally known that debug is enabled. This has to be true to display the debug messages.
	def Debug.enable_debug
		@enabled = true
	end

	def Debug.no_misspelled_edges
		debug "There are no misspelled edges."
	end

	def Debug.no_missing_edges
		debug "There are no missing edges."
	end

	def Debug.misspelled_edge_between node1, node2, edge
		debug %{Misspelled edge "#{edge}" between: "#{node1}" and "#{node2}"}
	end

	def Debug.missing_edge_between node1, node2
		debug %{Missing edge between: "#{node1}" and "#{node2}"}
	end

	def Debug.misplaced_edge_between node1, node2, edge
		debug %{Misplaced edge "#{edge}" between: "#{node1}" and "#{node2}"}
	end

	def Debug.extra_edge_between node1, node2, edge
		debug %{Extra edge "#{edge}" between: "#{node1}" and "#{node2}"}
	end

	def Debug.no_misplaced_edges
		debug "There are no misplaced edges."
	end

	def Debug.no_extra_edges
		debug "There are no extra edges."
	end

	private

	# Output the debug message to the console.
	def Debug.debug message
		if @enabled
			puts message
		end
	end
end
