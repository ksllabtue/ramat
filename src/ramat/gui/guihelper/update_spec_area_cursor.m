function update_spec_area_cursor(specdat, coords, ax, main_axes)
    %UPDATE_SPEC_AREA_CURSOR

    arguments
        specdat SpecData = [];
        coords double = [];
        ax matlab.ui.control.UIAxes = [];
        main_axes matlab.ui.control.UIAxes = [];
    end

    % Check if cursor exists
    if isempty(specdat.cursor)
        specdat.cursor = Cursor(specdat);
    end
    
    % Update cursor coordinates
    specdat.cursor.setx(coords(1));
    specdat.cursor.sety(coords(2));

    % Redraw overlay, when axes are provided
    if ~isempty(ax)
        update_spec_area_filter_overlay(ax, specdat);
    end

    % Update main app spectral preview
    if ~isempty(main_axes)
        update_spectral_preview(specdat.parent_container, main_axes);
    end

end