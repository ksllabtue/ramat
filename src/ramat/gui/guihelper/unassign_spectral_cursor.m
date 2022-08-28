function unassign_spectral_cursor(f)
    %UNASSIGN_SPECTRAL_CURSOR Remove callback to cursor
    
    arguments
        f matlab.ui.Figure = [];
    end

    % Clear callback
    f.WindowButtonMotionFcn = "";

end