module Debug
  def Debug.enable_debug
    @enabled = true
  end

  def Debug.no_missing_edges
    debug "There are no missing edges."
  end
  
  def Debug.missing_edge_between node1, node2
    debug %{Missing edge between: "#{node1}" and "#{node2}"}
  end

  private

  def Debug.debug message
    if @enabled
      puts message
    end
  end
end