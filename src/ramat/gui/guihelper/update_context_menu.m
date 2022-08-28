function update_context_menu(cm, ~, selected_node, app)
    %UPDATE_CONTEXT_MENU his callback is called when the context menu of a
    % tree node is opened.
    %   It fills the Context Menu according to the available context menu
    %   actions for the selected items.

    arguments
        cm matlab.ui.container.ContextMenu;
        ~;
        selected_node matlab.ui.container.TreeNode;
        app ramatguiapp;
    end

    % Clear tree
    cm.Children.delete();

    % Make sure the node actually points to data
    if isempty(selected_node.NodeData), return; end

    % Get available context menu actions
    data = selected_node.NodeData;
    data.add_context_actions(cm, selected_node, app);
    
end