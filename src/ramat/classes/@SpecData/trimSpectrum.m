function self = trimSpectrum(self, startG, endG, kwargs)
    % Trims spectral data to [startG, endG]
    % startG and endG should be provided in the graph units, ie. if
    % graph units are given in 1/cm, the trim limits should be in
    % the same units.

    arguments
        self;
        startG;
        endG;
        kwargs.copy logical = false;
    end

    if (endG > startG)
        % Trim Region is valid

        for i = 1:numel(self)
            % Repeat operation for each spectral data object

            graph = self(i).graph;
            dat = self(i).data;

            % Find indices of trim region
            startIdx = find(graph > startG, 1, 'first');
            endIdx = find(graph < endG, 1, 'last');

            graph = graph( startIdx:endIdx , :);
            dat = dat(:, :, startIdx:endIdx);

            if kwargs.copy
                % Create copy
                new_specdat = copy(self);
                new_specdat.graph = graph;
                new_specdat.data = dat;
                new_specdat.description =  sprintf("Trim [%i - %i]", startG, endG);
                self.append_sibling(new_specdat);
            else
                self(i).graph = graph;
                self(i).data = dat;
            end


        end
    else
        warning('Trim region is invalid. Second values should be greater than the first value.');
    end
end