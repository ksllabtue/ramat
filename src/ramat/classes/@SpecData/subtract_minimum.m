function subtract_minimum(self, options)
    % SUBTRACT_OFFSET Subtract constant
    %   Subtracts a global or local minimum
    
    arguments
        self;
        options.local = false;
        options.local_start = 0;
        options.local_end = 1;
    end

    % Retrieve flattened 2-dimensional array
    gdat = self.graph;
    flatdat = self.FlatDataArray;

    % Find indices of region
    if options.local
        start_index = find(gdat > options.local_start, 1, 'first');
        end_index = find(gdat < options.local_end, 1, 'last');
    else
        start_index = 1;
        end_index = size(gdat);
    end

    % Find minima
    minima = min(flatdat(start_index:end_index, :));

    if isempty(minima)
        minima = 0;
    end

    % Subtract minima
    self.data = flatdat - minima;

end    