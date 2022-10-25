function self = force_equal_graph_size(self, options)
    
    arguments
        self SpecData;
        options.as_copy logical = false;
    end

    if options.as_copy
        self = copy(self);
    end

    % --- TO DO ---
    % Strategy to deal with different graph bases
    % Option 1: simply omit overlength
    graph_sizes = [self.GraphSize]';

    % Are graph bases the same
    if ~all(graph_sizes == graph_sizes(1))

        out("[NOTICE] Not all graph bases are equally long!");
        out("[NOTICE] Strategy: omitting overlength (might result in data loss)");

        min_length = min(graph_sizes);

        % Trim further to minimum
        for spec = self(:)'
            spec.graph = spec.graph(1:min_length);
            spec.data = spec.data(:,:,1:min_length);
        end
    end

end