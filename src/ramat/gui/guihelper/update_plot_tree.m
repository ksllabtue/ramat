function update_plot_tree(tree, specplot, app)

    arguments
        tree;
        specplot SpecPlot;
        app;
    end

    tree.Children.delete();
    checkednodes = [];

    if isempty(specplot.data.children), return; end

    % Make sure tree has a single persisting context menu
    % And assign callback for dynamic updating of the context menu
    if isempty(tree.UserData)
        tree.UserData = uicontextmenu(app.UIFigure);
        tree.UserData.ContextMenuOpeningFcn = @(source, action) update_context_menu(source, action, source.Parent.CurrentObject, app);
    end

    % Reset context menu
    cm = tree.UserData;
    cm.Children.delete();

    % Group has links
    for link = specplot.data.children(:)'

        datanode = uitreenode(tree, ...
            "Text", link.display_name, ...
            "NodeData", link, ...
            "ContextMenu", cm);         
            
        % Evaluate whether the node should be checked and
        % add to list of checked nodes
        if any(specplot.selection == link)
            checkednodes = [checkednodes; datanode];
        end

    end

    % Set Checked nodes based on Analysis.Selection
    tree.CheckedNodes = checkednodes;
end