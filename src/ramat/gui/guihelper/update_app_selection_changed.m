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

    % Check for homogeneity: selection should be homogeneous
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

    % Ignore text data
    node_data(vertcat(node_data.dataType) == "TextData") = [];

    if isempty(node_data)
        return;
    end
    
    % Check if non-homogeneous data types have been selected, e.g. spectral
    % data and image data.
    if ~all(node_data(1).dataType == vertcat(node_data.dataType))
        return;
    end

    node_data_type = node_data(1).dataType;

    % Check if multiple images have been selected
    if (numel(node_data) > 1 && node_data_type == "ImageData")
        return;
    end

    % Update plot preview
    % Invoke plot method of selected data containers
    if app.StackedPlotCheckBox.Value
        plot_type = "Stacked";
    else
        plot_type = "Overlaid";
    end

    % Start updating

    % Update title
    app.DataContainerNameLabel.Text = node_data.display_name;
    
    % Update data items tree
    update_data_items_tree(app, node_data);

    ax = app.UIPreviewAxes;
    node_data.plot(Axes=ax, PlotType=plot_type, Preview=true);

    if (node_data_type == "SpecData" && node_data(1).Data.DataSize > 1)
        % Open dialogs for specdata large area scans
        % Area Spectra Data Opened -> open filter window
        if isempty(app.OpenedDialogs.SpectralAreaDataViewer) || ~isvalid(app.OpenedDialogs.SpectralAreaDataViewer)
            % Open new data viewer
            app.OpenedDialogs.SpectralAreaDataViewer = SpecAreaDataViewer(app, node_data);
            
        else
            % Update data viewer
            app.OpenedDialogs.SpectralAreaDataViewer.DataCon = node_data;
            app.OpenedDialogs.SpectralAreaDataViewer.update();
            
        end
    end
 
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

