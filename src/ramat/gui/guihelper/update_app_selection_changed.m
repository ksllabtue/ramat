function update_app_selection_changed(app, event)
    %UPDATE_APP_SELECTION_CHANGED Update app, after selection in
    %the data manager has changed
    %
    %   Input arguments:
    %       app     app handle
    %       event   matlab.ui.eventdata.SelectedNodesChangedData
    %

    arguments
        app ramatguiapp;
        event matlab.ui.eventdata.SelectedNodesChangedData;
    end

    % Get selected nodes    
    selectedNodes = event.SelectedNodes;

    % Check for homogeneity: classes of selection should be homogeneous,
    % e.g. only DataContainers or only Groups
    classes = cellfun(@(x) string(class(x)), {selectedNodes.NodeData}');
    if ~all(classes(1) == classes)
        % Inhomogeneous selection, revert selection
        event.Source.SelectedNodes = event.PreviousSelectedNodes;
        return;
    end

    % Only one analysis can analysed at a time
    if (classes(1) == "AnalysisResultContainer" && numel(selectedNodes) > 1)
        % Multiple analyses selected, revert selection
        event.Source.SelectedNodes = event.PreviousSelectedNodes;
        return;
    end
     
    % Get associated data containers
    node_data = vertcat( selectedNodes.NodeData );

    % Check if selection contains deleted data containers
    if ~all(isvalid(node_data))
        % Remove nonvalid nodes
        update_node(selectedNodes(~isvalid(node_data)), "remove");
        return;
    end

    % Check if non-data-containing things have been selected
    if classes(1) == "Group"
        return;
    end

    % Update data items tree
    update_data_items_tree(app, node_data);

    % Update title
    app.DataContainerNameLabel.Text = node_data.display_name;

    % Prepare for plot preview

    % Ignore text data and empty data
    node_data(vertcat(node_data.dataType) == "TextData") = [];
    node_data(vertcat(node_data.dataType) == "empty") = [];
    if isempty(node_data), return; end
    
    % Check if non-homogeneous data types have been selected, e.g. spectral
    % data and image data.
    if ~node_data.is_homogeneous_array(), return; end

    node_data_type = node_data(1).dataType;

    % Check if multiple LA scans have been selected
%     data_items = node_data.get_data();
%     if (numel(node_data) > 1 && any([data_items.DataSize] > 1))
%         return;
%     end

    % Update plot preview
    
    % Determine plot type
    if app.StackedPlotCheckBox.Value, plot_type = "Stacked";
    else, plot_type = "Overlaid"; end

    ax = app.UIPreviewAxes;

    % Invoke plot method of selected data containers 
    node_data.plot(Axes=ax, plot_type=plot_type, preview=true, PCs=app.get_selected_pcs);

%     if (node_data_type == "SpecData" && node_data(1).Data.DataSize > 1)
%         % Open dialogs for specdata large area scans
%         % Area Spectra Data Opened -> open filter window
%         if isempty(app.OpenedDialogs.SpectralAreaDataViewer) || ~isvalid(app.OpenedDialogs.SpectralAreaDataViewer)
%             % Open new data viewer
%             app.OpenedDialogs.SpectralAreaDataViewer = SpecAreaDataViewer(app, node_data);
%             
%         else
%             % Update data viewer
%             app.OpenedDialogs.SpectralAreaDataViewer.DataCon = node_data;
%             app.OpenedDialogs.SpectralAreaDataViewer.update();
%             
%         end
%     end
 
    if node_data_type == "PCA"
        % If node is an analysis result, set this to the current active
        % analysis result
        % PCA Result is selected
        pcares = node_data;
        if isempty(pcares.data), return; end
        
        % Set Active Analysis Result and prepare for analysis
        app.prj.ActiveAnalysisResult = pcares;
        app.TabGroup.SelectedTab = app.PCATab;

        app.PCADescription.Value = pcares.data.description;
        
    end
            
end

