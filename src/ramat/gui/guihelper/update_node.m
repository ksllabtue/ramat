function update_node(node, action)
    %UPDATE_NODE Update node
    
    arguments
        node;
        action string;
    end

    % Find parent tree
    tree = node(1);
    lim = 20; i = 0;
    while ~(class(tree) == "matlab.ui.container.CheckBoxTree" || class(tree) == "matlab.ui.container.Tree")
        tree = tree.Parent;
        i = i + 1;
        if i>lim, break; end
    end

    switch action
        case "moveup"
            % Cannot move up from 1st place
            idx = get_idx(node);
            if idx == 1, return; end

            % Move by swapping with previous sibling
            swapidx = [idx - 1, idx];
            node.Parent.Children(swapidx) = node.Parent.Children(fliplr(swapidx));

            tree.SelectedNodes = node;

        case "movedown"
            % Cannot move down from last place
            idx = get_idx(node);
            if idx == numel(node.Parent.Children), return; end

            % Move by swapping with previous sibling
            swapidx = [idx + 1, idx];
            node.Parent.Children(swapidx) = node.Parent.Children(fliplr(swapidx));

            tree.SelectedNodes = node;

        case "create"
            

        case "remove"
            delete(node);

        case "icon"
            for n = node(:)'
                n.Icon = n.NodeData.icon;
            end

        case "descriptive_name"
            for n = node(:)'
                n.Text = n.NodeData.get_descriptive_name();
            end

    end

    function idx = get_idx(node)
        idx = find(node == node.Parent.Children);
    end
end

