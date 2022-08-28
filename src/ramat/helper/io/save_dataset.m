function save_dataset(prj, options)
    %SAVE_DATASET Summary of this function goes here
    %   Detailed explanation goes here

    arguments
        prj Project = Project.empty();
        options.App = [];
    end

    if isempty(prj), return; end

    [filename, path] = uiputfile(...
        {'*.ramat','Raman MATLAB Dataset (*.ramat)'; ...
         '*.mat','MATLAB-files (*.mat)'});
    
    try 
        save( fullfile(path, filename), 'prj' );
    catch
        warning('Could not save project.');
        return
    end
    
    fprintf('Project saved successfully.');
    
end

