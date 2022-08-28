function data = import_data(path, opts)
    %IMPORT_DATA Import and parse spectroscopical data
    %   Loops through all files in a folder and performs import
    %
    %   FILE TYPE MODES:
    %       0 = WIP     (default)
    %       1 = MATLAB
    %       2 = ASCII
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
        opts.type int8 = 0;
        opts.folder logical = false;
        opts.gui = [];
        opts.processing = get_processing_options;
        opts.start_path = pwd;
    end

    % Get input path and validate input
    if isempty(path)
        % Ask for user input
        try
            [files, base_dir] = get_path_user_input(opts.folder, start_path=opts.start_path);
        catch ME
            switch ME.identifier
                case 'Ramat:User'
                    fprintf("No input path was provided.\n");
                    return;
                otherwise
                    rethrow(ME);
            end
        end

    else
        % Validate given path and override opts.folder
        try
            opts.folder = validate_path(path);
        catch ME
            switch ME.identifier
                case 'Ramat:IO'
                    fprintf("Invalid path. File or folder not found.")
                    return;
                otherwise
                    rethrow(ME);
            end
        end

        % Take given path
        if opts.folder
            base_dir = path;
        else
            files = path;
        end

    end

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

    % Force column vector
    files = files(:);

    number_of_files = numel(files);

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
                case 0
                    % WIP Files
                    newdata = import_single_wip(file, gui=opts.gui, processing=opts.processing);
                    data = [data newdata];
                    
                case 1
                    % .MAT FILES
                    data(f) = importSingleRamanGraph(file, gui=opts.gui);
                    
            end
        	
	    end
        
        
    else
	    fprintf('     Folder %s has no data files in it.\n', thisPath);
    end
    
    % Fource output to column
    data = data(:);


    %% Nested functions

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