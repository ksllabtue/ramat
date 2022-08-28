function data = importRaman(varargin)
%IMPORTRAMAN
%   Loops through all files in a folder and performs import
%
%   FILE TYPE MODES:
%       0 = WIP
%       1 = MATLAB
%       2 = ASCII
%
%   Input Arguments:
%  (ARG 1:) PATH TYPE. (*0 = FILES, 1 = FOLDER)
%  (ARG 2:) IMPORT TYPE MODE. (*0 = WIP, 1 = MATLAB, 2 = ASCII)
%  (ARG 3:) SEARCH PATH. If not provided: asks for user input.
%  (ARG 4:) GUI APP HANDLE. If not provided: output to command window
%
%   Example:
%
%   data = importRaman();
%   data = importRaman('folder', 1, [], app)


%% PARSE INPUT ARGUMENTS

% PATH TYPE: FILES or FOLDER
if (nargin >= 1 && ~isempty(varargin{1}))
    pathtype = varargin{1};
else
    % If not provided, default: FILES
    pathtype = 0;
end

% IMPORT TYPE MODE: WIP, MATLAB, or ASCII
if (nargin >= 2 && ~isempty(varargin{2}))
    filetype = varargin{2};
else
    % If not provided, default: WIP
    filetype = 0;
end

% SEARCH PATH.
if (nargin >= 3 && ~isempty(varargin{3}))
    % Search path provided
    thisPath = varargin{3};
    
    % Search path is provided, determine path type and check whether path is valid..
    % This overrides ARG 1!
    switch exist(thisPath)
        case 2
            pathtype = 'file';
        case 7
            pathtype = 'folder';
        case 0
            warning('File or folder not found.');
        otherwise
            warning('Invalid path');
    end
    
    % If a file is provided, split the path into:
    % thisFolder:   File directory
    % fileList:     File name + extension
    if (strcmp(pathtype, 'file'))
        [baseDir, fname, fext] = fileparts(thisPath);
        fileNames = [fname, fext];
    end
        
else
    % No start path provided. Ask for user input.
    start_path = pwd;
    
    switch pathtype
        case 0
            % Ask for files
            [fileNames,baseDir,~] = uigetfile( ...
                {'*.wip', 'WiTEC Project Files (*.wip)'; ...
                '*.mat', 'MATLAB Export (*.mat)'; ...
                '*.txt;*.asc', 'ASCII Format (*.txt,*.asc)'}, ...
                'Select one or more files', ...
                'MultiSelect', 'on');
            
        case 1
            % Ask for folder, which contains files
            baseDir = uigetdir(start_path);
            if baseDir == 0
                return;
            end
    end
            
end

% GUI APP HANDLE
if (nargin == 4 && ~isempty(varargin{4}))
    % GUI handle provided
    consoleOutput = false;
    app = varargin{4};
else
    % GUI handle not provided, output with fprintf to console window.
    consoleOutput = true;
end

%% COMPILE LIST OF FILES

% writeBuffer = sprintf('Processing folder %s\n', thisFolder);
% if (consoleOutput == true)
%     fprintf('%s', writeBuffer);
% else
%     app.StatusTextArea.Value = [app.StatusTextArea.Value; writeBuffer];
% end

if (pathtype == 1)
    switch filetype
        case 0
            fileList = dir(fullfile(baseDir, '*.wip'));
        case 1
            fileList = dir(fullfile(baseDir, '*.mat'));
        case 2
            fileList = dir(fullfile(baseDir, '*.asc'));
            fileList = [fileList; dir(fullfile(baseDir, '*.txt'))];
    end
    
    fileNames = transpose({fileList.name});
    
else
    if (size(strlength(fileNames),2) == 1)
        % We got a single file name as char array:
        % Put fileName into a cell, so we know that the length of
        % fileNames = 1.
        fileNames = {fileNames};
    end
        
    filetype = determineFileTypeMode(fileNames);
    
    fileNames = transpose(fileNames);
end


numberOfFiles = length(fileNames);

if numberOfFiles >= 1
    data = [];
    
	% Go through all those files.
	for f = 1 : numberOfFiles
		fullFileName = fullfile(baseDir, fileNames{f});
		
		%% === START OF IMPORT CODE ===
        
        if (consoleOutput == true)
            clc
        else
            app.StatusTextArea.Value = "";
        end
        
        writeBuffer = sprintf('Processing file %d of %d\n', f, numberOfFiles);
        writeBuffer = append(writeBuffer, sprintf('%s\n', fileNames{f}));
        writeBuffer = append(writeBuffer, sprintf('Importing Data\n'));
        if (consoleOutput == true)
            fprintf('%s', writeBuffer);
        else
            app.StatusTextArea.Value = [app.StatusTextArea.Value; writeBuffer];
            drawnow;
        end
        
        switch filetype
            case 0
                data = [data importSingleWIP(fullFileName)];
            case 1
                if (consoleOutput == true)
                    data(f) = importSingleRamanGraph(fullFileName);
                else
                    data(f) = importSingleRamanGraph(fullFileName,app);
                end
        end
        		
		% === END OF IMPORT ===
	end
    
    
else
	fprintf('     Folder %s has no data files in it.\n', thisPath);
end

% Fource output to column
data = data(:);
 
end
