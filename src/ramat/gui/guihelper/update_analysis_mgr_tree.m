function update_analysis_mgr_tree(app, analysis)
    %UPDATE_ANALYSIS_MGR_TREE Update the analysis subset manager tree.
    %   Input:
    %       app:        handle to GUI
    %       analysis:   (optional) analysis to show. In case, no analysis
    %                   is provided, it will take the currently active
    %                   analysis from the project.

    arguments
        app ramatguiapp;
        analysis Analysis = Analysis.empty;
    end
    
    tree = app.SubsetItemsTree;

    % Make sure tree has a single persisting context menu
    % And assign callback for dynamic updating of the context menu
    if isempty(tree.UserData)
        tree.UserData = uicontextmenu(app.get_figure_root());
        tree.UserData.ContextMenuOpeningFcn = @(source, action) update_context_menu(source, action, source.Parent.CurrentObject, app);
    end
    
    % Reset context menu
    cm = tree.UserData;
    cm.Children.delete();

    % clear Tree
    a = tree.Children;
    a.delete;

    % Are there any subsets
    if isempty(analysis)
        if isempty(app.prj.analyses), return; end
        if isempty(app.prj.ActiveAnalysis), return; end

        analysis = app.prj.ActiveAnalysis;
    end

    checkednodes = [];

    % Add groups
    for group = analysis.GroupSet(:)'

        groupnode = uitreenode(tree, ...
            "Text", group.display_name, ...
            "NodeData", group);

        if isempty(group.children), continue; end
            % Group has DataContainer children

        for link = group.children(:)'

            datanode = uitreenode(groupnode, ...
                "Text", link.display_name, ...
                "NodeData", link, ...
                "ContextMenu", cm);

            % Assign icon to node
            datanode.Icon = link.icon;
            
            % Evaluate whether the node should be checked and
            % add to list of checked nodes
            if any(analysis.Selection == link)
                checkednodes = [checkednodes; datanode];
            end

        end

    end

    % Set Checked nodes based on Analysis.Selection
    tree.CheckedNodes = checkednodes;


end