function out(str, opts)
    %OUT Wrapper for fprintf to enable write to GUI

    arguments
        str string = string.empty();
        opts.gui = []; % GUI handle
        opts.clear logical = 0;
    end

    fprintf(str);
    fprintf("\n");

    if isempty(opts.gui)
        return;
    end

    if ~isvalid(opts.gui)
        warning("GUI element deleted.");
        return;
    end

    % Clear GUI text component
    if opts.clear
        opts.gui.Value = "";
    end

    % Append string to GUI text component
    opts.gui.Value = [opts.gui.Value; str];
    drawnow;
    scroll(opts.gui, 'bottom');
    
end

