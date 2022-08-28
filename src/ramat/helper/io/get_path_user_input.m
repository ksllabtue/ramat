function [files, base_dir] = get_path_user_input(folder, opts)
    %GET_PATH_USER_INPUT Ask for user input
    arguments
        folder logical = 0;
        opts.start_path string = pwd;
    end

    files = cell.empty();
    base_dir = string.empty();

    if folder
        % Ask for folder, which contains the files
        base_dir = uigetdir(opts.start_path);

    else
        % Ask for files
        [file_names,base_dir,~] = uigetfile( ...
            {'*.wip', 'WiTEC Project Files (*.wip)'; ...
            '*.mat', 'MATLAB Export (*.mat)'; ...
            '*.txt;*.asc', 'ASCII Format (*.txt,*.asc)'}, ...
            'Select one or more files', ...
            'MultiSelect', 'on');

        % Get full file paths
        if iscell(file_names)
            for file = file_names
                files{end+1} = fullfile(base_dir, file);
            end
        else
            files = {fullfile(base_dir, file_names)};
        end

    end

    if base_dir == 0
        throw(MException('Ramat:User', "User cancelled input dialog."))
    end

end