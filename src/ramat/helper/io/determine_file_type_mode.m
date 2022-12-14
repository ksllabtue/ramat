function fileTypeMode = determine_file_type_mode(fileNames)
% Determines the file type for import

len = length(fileNames);

if (len == 0)
    throw(MException('Ramat:IO', "No files were found."));
end

% Determine extensions for all input files
ext = cell(1, len);

for i = 1:length(fileNames)
    [~, ~, ext{i}] = fileparts(fileNames{i});
end

% Check if the extensions are the same
if all(strcmp(ext, ext{1}))
    uniformExt = lower(ext{1});
    
    switch uniformExt
        case '.wip'
            fileTypeMode = "wip";
        case '.mat'
            fileTypeMode = "mat";
        case '.asc'
            fileTypeMode = "txt";
        case '.txt'
            fileTypeMode = "txt";
        case '.xls'
            fileTypeMode = "xls";
        case '.xlsx'
            fileTypeMode = "xls";
        otherwise
            throw(MException('Ramat:IO', 'File Extension not Supported'));
    end
else
    throw(MException('Ramat:IO', 'Multiple files extensions provided.'));
end

end