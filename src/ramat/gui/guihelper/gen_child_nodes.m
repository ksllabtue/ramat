function gen_child_nodes(parent_node, group, app)
    %GEN_CHILD_NODES Recursive function to generate child nodes in the data
    %manager tree
    %   This function recursively generates child nodes in the data manager
    %   tree, since every node can have multiple levels of child nodes.
    
    arguments
        parent_node {mustBeA(parent_node,["matlab.ui.container.TreeNode", "matlab.ui.container.Tree"])};
        group Group;
        app ramatguiapp;
    end

    % Generate node for current group
    group_node = uitreenode(parent_node, ...
                "Text", group.name, ...
                "NodeData", group, ...
                "Icon", group.icon);

    % Call recursively for all child groups
    for i = 1:numel(group.child_groups)
        gen_child_nodes(group_node, group.child_groups(i), app);
    end

    % Generate data container nodes
    num_children = numel(group.children);

    for j = 1:num_children
        data = group.children(j);
        datanode = uitreenode(group_node, ...
            "Text", data.display_name, ...              % Set Tree Text Label
            "NodeData", data, ...                       % Set Handle to DataContainer
            ContextMenu=app.DataMgrTree.UserData);
            %"ContextMenu", app.contxtDataMgrTreeNode);

        datanode.Icon = data.icon;

    end


end