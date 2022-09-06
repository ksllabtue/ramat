function update_data_items_tree(app, container)
    %UPDATE_DATA_ITEMS_TREE Update the data items tree, displaying all
    %children contained in a Container.
    %   Input:
    %       app:        handle to GUI
    %       container:  handle to container, whose contents should be
    %       explored

    arguments
        app ramatguiapp;    % app
        container;          % selected container
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
    display_text = "[" + class(container) + ": " + container.dataType + "] " + container.display_name;
    dc_node = uitreenode(tree, ...
        Text=display_text, ...
        NodeData=container);

    % Show every data item in container
    for item = container.children
        item_display_text = "[" + item.Type + "] " + item.name;
        item_node = uitreenode(dc_node, ...
            Text=item_display_text, ...
            NodeData=item);

        % Assign context menu
        item_node.ContextMenu = cm;

        % Is this the main data item?
        if item == container.get_data()
            v = ver('MATLAB');
            if str2num(v.Version) > 9.12
                boldstyle = uistyle(FontWeight="bold");
                tree.addStyle(boldstyle, node=item_node)
            end
            tree.SelectedNodes = item_node;
        end
    end

    % Expand tree
    expand(tree, 'all');

end

