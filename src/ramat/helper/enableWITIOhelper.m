function success = enableWITIOhelper(kwargs)
    % ENABLEWITIOHELPER Enables the witio toolbox

    arguments
        kwargs.action = "add_helper";
    end

    success = false;

    switch kwargs.action
        case 'install'
            install_witio_toolbox();
        case 'add_helper'
            add_witio_helper_functions();
    end


    function install_witio_toolbox()
        % INSTALL_WITIO_TOOLBOX Run the witio toolbox installation

        toolbox_path = fullfile('redist', 'wit_io');

        if ~exist(toolbox_path)
            fprintf('Toolbox installation file not found.\n');
            return
        end

        try
            installedToolbox = matlab.addons.toolbox.installToolbox( fullfile(toolbox_path, 'wit_io.mltbx') );
        catch ME
            % Repackage error as warning, continue without toolbox
            warning(ME.message);
            return
        end

        fprintf('Installed WITIO Toolbox.\n');
        success = true;

    end

    function add_witio_helper_functions()
        % ADD_WITIO_HELPER_FUNCTIONS Adds /helper subdir of witio toolbox

        if ~exist('varargin_dashed_str_inds')
            % Get root dir of witio toolbox
            [dir, ~, ~] = fileparts(which('wit_io_license'));

            % Add helper content
            helperdir = fullfile(dir, 'helper');
            addpath(genpath(helperdir));
        end

        fprintf('Added WITIO helper functions to MATLAB path.\n');
        success = true;

    end

end