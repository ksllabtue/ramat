function assign_spectral_cursor(f, ax)
    %ASSIGN_SPECTRAL_CURSOR Checks if axes already have a cursor

    arguments
        f matlab.ui.Figure;
        ax;
    end

    if ~isempty(f.UserData)
        if ~isempty(f.UserData.Cursor)
            % Re-assign axes
            f.UserData.Cursor.axes = ax;
            f.UserData.Cursor.active = true;
            f.UserData.Cursor.draw();
            f.UserData.Cursor.hook(f);
            return;
        end
    end

    % Create cursor and assign axes
    f.UserData.Cursor = SpectralCursor(f, ax);

    % Re-assign callback
    if isempty(f.WindowButtonMotionFcn)
        f.UserData.Cursor.hook(f);
    end

end

