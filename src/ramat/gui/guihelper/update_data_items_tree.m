function update_data_items_tree(app, container)
    %UPDATE_DATA_ITEMS_TREE Update the data items tree, displaying all
    %children contained in a Container.
    %   Input:
    %       app:        handle to GUI
    %       container:  handle to container, whose contents should be
    %       explored

    arguments
        app ramatguiapp;
        container;
    end
    
    tree = app.DataItemsTree;

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

    % Can only show info for one datacontainer
    if numel(container) > 1
        dc_node = uitreenode(tree,Text="Multiple Data Containers");
        return
    end

    % Cannot show info for non-datacontainers
    if ~isa(container, "Container")
        dc_node = uitreenode(tree,Text="No Data Container selected");
        return
    end

    % Show data container node
    dc_node = uitreenode(tree, ...
        Text=container.display_name, ...
        NodeData=container);

    % Show every data item in container
    for item = container.children
        item_display_text = "[" + item.Type + "] " + item.name;
        item_node = uitreenode(dc_node, ...
            Text=item_display_text, ...
            NodeData=item);

        % Assign context menu
        item_node.ContextMenu = cm;
    end

    % Expand tree
    expand(tree, 'all');

end

