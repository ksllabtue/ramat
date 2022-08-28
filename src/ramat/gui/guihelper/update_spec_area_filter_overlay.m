function update_spec_area_filter_overlay(ax, specdat)
    %UPDATE_SPEC_AREA_FILTER_OVERLAY

    arguments
        ax = [];
        specdat SpecData = [];
    end

    % Check if cursor exists
    if isempty(specdat.cursor)
        specdat.cursor = Cursor(specdat);
    end

    hold(ax, 'on');

    % Delete overlay
    if numel(ax.Children) > 1
        delete(ax.Children(1:end-1));
    end
    
    % Draw cursor
    co = [0.85 0.33 0.1];
    plot(ax, specdat.cursor.pgon, EdgeColor=co, LineWidth=1.5, FaceAlpha=0);
    line(ax, [0, specdat.cursor.x - specdat.cursor.size], [1, 1].*specdat.cursor.y, Color=co);
    line(ax, [specdat.cursor.x + specdat.cursor.size, specdat.XSize], [1, 1].*specdat.cursor.y, Color=co);
    line(ax, [1, 1].*specdat.cursor.x, [0, specdat.cursor.y - specdat.cursor.size], Color=co);
    line(ax, [1, 1].*specdat.cursor.x, [specdat.cursor.y + specdat.cursor.size, specdat.YSize], Color=co);

    % Disable hit test for overlay, so image can still be clicked
    for i = 1 : numel(ax.Children) - 1
        ax.Children(i).HitTest = 0;
        ax.Children(i).PickableParts = 'none';
    end

end