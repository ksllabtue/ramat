function update_data_mgr_tree(app)
    %UPDATE_DATA_MGR_TREE Update the data manager tree.
    %   Input:
    %       app:        handle to GUI

    arguments
        app ramatguiapp;
    end
    
    tree = app.DataMgrTree;

    % Make sure tree has a single persisting context menu
    % And assign callback for dynamic updating of the context menu
    if isempty(tree.UserData)
        tree.UserData = uicontextmenu(app.get_figure_root());
        tree.UserData.ContextMenuOpeningFcn = @(source, action) update_context_menu(source, action, source.Parent.CurrentObject, app);
    end
    
    % Reset context menu
    cm = tree.UserData;
    cm.Children.delete();

    % Clear Tree
    a = tree.Children;
    a.delete;

    % Create Data Nodes
    data_root = app.prj.data_root();
    gen_child_nodes(tree, data_root, app);
        
    % Create Analysis Result Nodes
    analysis_result_root = app.prj.analysis_result_root();
    gen_child_nodes(tree, analysis_result_root, app);

end