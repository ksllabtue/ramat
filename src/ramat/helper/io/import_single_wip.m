function out = import_single_wip(file, opts)
    %IMPORT_SINGLE_WIP

    arguments
        file string = string.empty();
        opts.gui = [];
        opts.processing = get_processing_options;
    end
    
    %% Check whether WITIO reader is activated
    if ~witio_isenabled()
        %enableWITIO();
    end
    
    % Make sure all helper files of the WITIO module are in the MATLAB path.
    enableWITIOhelper();
    
    %% Import .wip file
    [O_wid, O_wip, ~] = wip.read(file, '-all');
    
    % Output to out=[]
    f = 1;
    
    % Default: import everything, including text data objects
    for i = 1:size(O_wid,1)
        out(i, 1) = import_single_widata(O_wid(i, 1), processing=opts.processing, gui=opts.gui);
    end

end

