function f = get_parent_figure(ax)
    %GET_PARENT_FIGURE Retrieve figure handle of axes
    %   Parent figure is not always direct parent of axes, therefore it has
    %   to be found in a loop.
    
    f = ax;
    limit = 0;
    while (class(f) ~= "matlab.ui.Figure")
        f = f.Parent;
        limit = limit + 1;
        if limit > 10
            throw(MException('Ramat:UI',"Could not find figure"))
        end
    end
end

