function varargout = dump_selection(selection)
    %DUMP_SELECTION Dumps selection to workspace
    %   Dumping objects to the base workspace for quick access.
    
    arguments
        selection = [];
    end

    if nargout == 0
        % Assign a name
        varname = lower(class(selection));
        
        assignin('base', varname, selection);

        % Show in command window
        fprintf("Dumped selection to workspace:\n\n  " + varname + " = \n");
        disp(selection)
    elseif nargout == 1
        varargout = selection;
    else
        return
    end
end

