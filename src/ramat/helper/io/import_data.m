function [data, groups] = import_data(path, opts)
    %IMPORT_DATA Import and parse spectroscopical data
    %   Loops through all files in a folder and performs import
    %
    %   FILE TYPE MODES:
    %       "wip" = WIP     (default)
    %       "mat" = MATLAB
    %       "txt" = ASCII / PLAIN TEXT
    %       "xls" = MICROSOFT EXCEL
    %
    %   Input Arguments:
    %   - path:         (string)input path, can be folder or list of files.
    %                           If not provided: asks for user input
    %   - opts.type:    (int)   import type mode (*0 = WIP, 1 = MATLAB,
    %                           2 = ASCII)
    %   - opts.folder:  (bool)  When true, import from entire folder.
    %   - opts.gui:     (handle)gui app handle. If not provided: will
    %                           output to command window.
    %                   
    %   - opts.conversion:      Struct with conversion settings.
    %
    %   Output Arguments:
    %   - data          Imported and parsed data
    %
    %   Example:
    %
    %   data = import_raman();
    %   data = import_raman([], type=1);

    arguments
        path string = string.empty();
        opts.?ImportOptions;
        opts.type string = "wip";
        opts.folder logical = false;
        opts.gui = [];
        opts.processing = get_processing_options;
        opts.start_path = pwd;
        opts.convert_widata logical = true;
        opts.spec_col int32 = [];   % --- processing options for xls and ascii files
        opts.group_col int32 = [];
        opts.sample_col int32 = [];
        opts.data_col int32 = [];
        opts.group_by_group logical = true;
        opts.group_by_sample logical = true;
        opts.combine_spectra logical = true;
        opts.dimensions int32 = [];
    end

    % Default output
    data = [];

    % Get input path and validate input
    [files, base_dir, opts] = get_path(path, opts);

    % Get list of all files
    if opts.folder
        files = get_folder_contents(base_dir);
    end

    % Check extension
    try
        opts.type = determine_file_type_mode(files);
    catch ME
        switch ME.identifier
            case 'Ramat:IO'
                warning(ME.message);
                return;
            otherwise
                rethrow(ME);
        end
    end

    out("File type mode: " + opts.type);

    % Force column vector
    files = files(:);
    number_of_files = numel(files);
    out("Importing " + string(number_of_files) + " file(s).");

    % Start import
    if number_of_files > 0
        data = [];

	    % Go through all those files.
	    for f = 1 : number_of_files
		    
            file = files{f};
            [fpath, fname, fext] = fileparts(file);
		                
            out(sprintf('Processing file %d of %d\n', f, number_of_files), gui=opts.gui);
            out(sprintf('%s%s\n', fname, fext), gui=opts.gui);
            out(sprintf('Importing Data\n'), gui=opts.gui);
                        
            switch opts.type
                case "wip"
                    % WIP Files
                    newdata = import_single_wip(file, gui=opts.gui, processing=opts.processing, convert_widata=opts.convert_widata);
                    data = [data newdata];
                    
                case "mat"
                    % .MAT FILES
                    data(f) = importSingleRamanGraph(file, gui=opts.gui);

                case "xls"
                    options = unpack(opts);
                    [data, groups] = parse_excel(file, options{:});
                    
            end
        	
	    end
        
        
    else
	    fprintf('     Folder %s has no data files in it.\n', thisPath);
    end
    
    % Fource output to column
    data = data(:);


    %% Nested functions

    function [files, base_dir, opts] = get_path(path, opts)
        %GET_PATH Retrieve and/or pars path

        % Check if we have a path provided
        if (isempty(path) || path == "")
            % No path provided. Ask for user input
            try
                [files, base_dir] = get_path_user_input(opts.folder, start_path=opts.start_path);
            catch MEx
                switch MEx.identifier
                    case 'Ramat:User'
                        fprintf("No input path was provided.\n");
                        return;
                    otherwise
                        rethrow(MEx);
                end
            end

            return;
        end

        % Validate given path and override opts.folder
        try
            opts.folder = validate_path(path);
        catch MEx
            switch MEx.identifier
                case 'Ramat:IO'
                    fprintf("Invalid path. File or folder not found.")
                    return;
                otherwise
                    rethrow(MEx);
            end
        end

        % Take given path
        if opts.folder
            base_dir = path;
        else
            [base_dir , ~, ~] = fileparts(path);
            files = path;
        end

    end

    function folder = validate_path(path)
        %VALIDATE_PATH

        switch exist(path)
            case 2
                folder = false;
            case 7
                folder = true;
            otherwise
                throw(MException('Ramat:IO', "Path invalid"));
        end
    end
  
    
end