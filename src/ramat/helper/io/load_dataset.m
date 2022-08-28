function prj = load_dataset(prj, options)
    %OPEN Summary of this function goes here
    %   Detailed explanation goes here
    
    arguments
        prj Project = Project.empty();
        options.App = []
    end
        

    if (exist('app', 'var') && isempty(options.App))
        options.App = app;
    end
    
    % Show UI dialog
    [file,path,indx] = uigetfile( ...
        {'*.ramat','Raman MATLAB Dataset (*.ramat)'; ...
        '*.mat','MATLAB Files (*.mat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Select a Data Set');
    fullPath = fullfile(path, file);
    
    % Load Dataset
    try
        loaded_dataset = load(fullPath, 'prj', '-mat');
    catch
        warning("Invalid file");
        return
    end
    
    prj.delete();
    prj = loaded_dataset.prj;
    
%     Set name of project (in case dataset file has been renamed)
    prj.name = file;
    
    % Update GUI data trees
    if ~isempty(options.App)
        app = options.App;
        
        app.prj.delete();
        app.prj = loaded_dataset.prj;
        
        app.updatemgr();
        
        % Set UI window title
        app.DVRamanToolUIFigure.Name = app.prj.name;
    end
    
    fprintf('Loaded %s successfully.\n', file);
    
end

