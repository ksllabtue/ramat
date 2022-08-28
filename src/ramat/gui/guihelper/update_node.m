function update_node(node, action)
    %UPDATE_NODE Update node
    
    arguments
        node;
        action string;
    end

    % Find parent tree
    tree = node;
    lim = 20; i = 0;
    while ~(class(tree) == "matlab.ui.container.CheckBoxTree" || class(tree) == "matlab.ui.container.Tree")
        tree = tree.Parent;
        i = i + 1;
        if i>lim, break; end
    end

    switch action
        case "moveup"
            % Cannot move up from 1st place
            idx = get_idx();
            if idx == 1, return; end

            % Move by swapping with previous sibling
            swapidx = [idx - 1, idx];
            node.Parent.Children(swapidx) = node.Parent.Children(fliplr(swapidx));

            tree.SelectedNodes = node;

        case "movedown"
            % Cannot move down from last place
            idx = get_idx();
            if idx == numel(node.Parent.Children), return; end

            % Move by swapping with previous sibling
            swapidx = [idx + 1, idx];
            node.Parent.Children(swapidx) = node.Parent.Children(fliplr(swapidx));

            tree.SelectedNodes = node;

        case "remove"
            delete(node);

    end

    function idx = get_idx()
        idx = find(node == node.Parent.Children);
    end
end

