function [status, identifier] = witio_isenabled()
    % WITIO_ISENABLED Checks whether the witio add on is enabled
    %   Checks whether the WITIO reader is enabled and all helper functions can
    %   be found. When the reader is not found, ask the user to install and
    %   enable the extension.
    %
    %   WITIO_ISENABLED() performs check and asks user
    %
    %   See also ENABLEWITIOHELPER.


    % default output
    identifier = -1;
    status = false;

    % Get list of installed add ons
    installedAddons = matlab.addons.installedAddons;

    % Check for witio toolbox
    witio_row = installedAddons(ismember(installedAddons.Name,'wit_io'),:); 

    if isempty(witio_row)
        fprintf('WITIO Toolbox is not installed.\n');

        if yesno_prompt('Do you want to install WITIO Toolbox?')
            enableWITIOhelper(action='install');
        else
            return
        end

    end

    fprintf('WITIO toolbox found.\n')

    % WITIO module is installed
    witio_row = witio_row(1,:);
    identifier = witio_row.Identifier;   
    status = matlab.addons.isAddonEnabled(identifier);

    if ~status
        fprintf('The WITIO reader is not enabled. This is required to read WITec project files.\n');
        
        if yesno_prompt('Do you want to enable the WITIO Toolbox?')
            
            % Enable the toolbox
            try
                matlab.addons.enableAddon(identifier)
            catch ME
                warning(ME.message);
                return
            end

        else
            return
        end
    end

    fprintf('WITIO toolbox enabled.\n')

    if ~exist('varargin_dashed_str_inds')
        fprintf('WITIO toolbox helper functions are not loaded.\n');
        
        enableWITIOhelper(action="add_helper");
    end

    % end --

    function out = yesno_prompt(question)
        prompt = sprintf('%s Options: [Y/YES, n/no]\n', question);
        validResponse = false;
        
        while ~validResponse
            response = lower(input(prompt,'s'));
            validResponse = ismember(response,{'yes','y','no','n',''});
        end

        % Determine which response was entered
        if strcmpi(response,'yes') || strcmpi(response,'y') || isempty(response)
            out = true;
        else
            out = false;
        end
    end

end