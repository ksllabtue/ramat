function data = convert_widata(wid, opts)
    %CONVERT_WIDATA 

    arguments
        wid
        opts.gui;
        opts.processing = get_processing_options;
        opts.from_table = false;
    end

    out("Converting WITec data to RaMAT data objects...\n", gui=opts.gui);

    % Number of WITec data objects
    num_wids = numel(wid);
    if class(wid) == "table"
        opts.from_table = true;

        % Remove unselected
        wid(~wid.selection,:) = [];
        num_wids = height(wid);
    end

    data = DataContainer.empty(num_wids,0);

    for i = 1:num_wids
        
        % Select wid
        if opts.from_table
            widata = wid.wid(i);
        else
            widata = wid(i);
        end

        data(i) = import_single_widata(widata, processing=opts.processing, gui=opts.gui);
    end

    % Force column vector
    data = data(:);

end