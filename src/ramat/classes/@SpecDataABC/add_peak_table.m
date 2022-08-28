function peak_table = add_peak_table(self, options)
    % ADD_PEAK_TABLE Finds peaks and adds extracted peak table
    %   This is a wrapper function for FIND_PEAKS.

    arguments
        self {mustBeA(self, "SpecDataABC")};
        options.min_prominence = 0.1;
        options.negative_peaks = false;
    end

    % To pass options kwargs, convert to struct to cell
    if ~isempty(options)
        options = namedargs2cell(options);
    else
        options = cell.empty();
    end

    peak_table = [];

    if ~isvalid(self) || isempty(self)
        % Handle to deleted object?
        return
    end

    % Find peaks
    peak_table = self.gen_peak_table(options{:});

    % Append extracted peak table
    self.peak_table = peak_table;
    self.append_sibling(peak_table);

end