function data = import_single_wip(file, opts)
    %IMPORT_SINGLE_WIP
    %
    %   Input:
    %       file        path to WiTec prohct file
    %       .gui        gui handle
    %       .convert_widata convert WiT_IO objects to RaMAT objects. Set to
    %       false in case the data is supposed to be previewed before
    %       conversion.
    %       .processing processing options

    arguments
        file string = string.empty();
        opts.gui = [];
        opts.convert_widata logical = true
        opts.processing = get_processing_options;
    end
    
    %% Check whether WITIO reader is activated
    if ~witio_isenabled()
        %enableWITIO();
    end
    
    % Make sure all helper files of the WITIO module are in the MATLAB path.
    enableWITIOhelper();
    
    %% Import .wip file
    [O_wid, ~, ~] = wip.read(file, '-all');

    out("WIP file (WITec Data) with " + num2str(numel(O_wid)) + " WITec Data objects.", gui=opts.gui);
    
    % Default: import everything, including text data objects
    if opts.convert_widata

        data = DataContainer.empty();

        for i = 1:size(O_wid,1)
            data(i, 1) = convert_widata(O_wid(i, 1), processing=opts.processing, gui=opts.gui);
        end

        return;
    end

    data = O_wid;

    out("WITec data has been imported. Continue to convert the data into RaMAT data.", gui=opts.gui);

end

