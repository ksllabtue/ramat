function selection = getguiselection()

    global app;
    
    selectednodes = app.DataMgrTree.SelectedNodes;
    
    selection = vertcat(selectednodes.NodeData);

end

