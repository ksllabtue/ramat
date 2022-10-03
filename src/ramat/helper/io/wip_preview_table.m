function tbl = wip_preview_table(wid, options)
    %WIP_PREVIEW_TABLE Generate a preview of the imported wip data.
    
    arguments
        wid
        options.preview_vars = ["Name", "Type"]
        options.selection_column logical = false;
        options.select_text logical = true;
        options.output_to_gui logical = false;
        options.gui_table matlab.ui.control.Table;
    end

    % Pre-allocation
    num_vars = numel(options.preview_vars);
    num_wids = numel(wid);
    arr = strings(num_wids, num_vars);
    
    % Go through preview variables
    for i = 1:num_vars
        var = options.preview_vars(i);
        arr(:,i) = string({wid.(var)}');
    end

    % Convert to table
    tbl = array2table(arr, VariableNames=options.preview_vars);

    % Add selection column
    if options.selection_column
        selection = table(true(num_wids,1), VariableNames="selection");

        % Unselect text
        if ~options.select_text
            selection.selection = transpose({wid.Type} ~= "TDText");
        end

        tbl = [selection, tbl];
    end

   
    % Update GUI Table
    if options.output_to_gui
        options.gui_table.Data = tbl;
    end

    % Add links to actual widata
    wid_links = array2table(wid, VariableNames="wid");
    tbl = [tbl, wid_links];
        
end