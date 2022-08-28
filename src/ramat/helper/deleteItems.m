function deleteItems(items, options)
%DELETEITEMS Deletes items and updates gui managers
    arguments
        items
        options.nodes = [];
        options.app = [];
    end

    % Call destructor
    for item = items
        item.remove();
    end

    % Update nodes
    if ~isempty(options.nodes)
        for node = options.nodes
            update_node(node, "remove");
        end
    end
    
    % Update manager
    if ~isempty(options.app), app.updatemgr(); end
    
end

