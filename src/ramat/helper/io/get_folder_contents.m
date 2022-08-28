function file_list = get_folder_contents(base_dir, type)
    %GET_FOLDER_CONTENTS

    file_list = cells.empty();

    % Get all files of a certain type in a folder
    switch type
        case 0
            file_struct = dir(fullfile(base_dir, '*.wip'));
        case 1
            file_struct = dir(fullfile(base_dir, '*.mat'));
        case 2
            file_struct = dir(fullfile(base_dir, '*.asc'));
            file_struct = [file_struct; dir(fullfile(base_dir, '*.txt'))];
    end
    
    for file = file_struct
        file_list{end+1} = fullfile(base_dir, file.name);
    end
    
end