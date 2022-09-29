function peak_table = gen_peak_table(self, options)
    % FIND_PEAKS

    arguments
        self {mustBeA(self, "SpecDataABC")};
        options.min_prominence double = 0.1;
        options.min_height double = -Inf;       % Minimum height, default: -Inf = no minimum
        options.negative_peaks logical = false; % Negative peaks below zero
        options.inverted_peaks logical = false; % Inverted peaks (valleys)
    end

    peak_table = [];

    % Check if the signal processing toolbox is installed
    if exist('findpeaks') == 0
        warning("Function findpeaks() does not exist. Is the Signal Processing Toolbox installed?");
        return
    end
    
    if ~isvalid(self) || isempty(self)
        % Handle to deleted object?
        return
    end

    xdata = self.graph;

    % Extract single spectrum
    if class(self) == "SpecData"
        ydata = self.get_single_spectrum();
    else
        ydata = self.data;
    end

    % What is the yrange
    range = max(ydata) - min(ydata);

    % Calculate absolute prominence
    abs_min_prominence = options.min_prominence * range;
    abs_min_height = options.min_height * range;

    % Find peaks
    [y, x] = findpeaks(ydata, xdata, MinPeakProminence=abs_min_prominence, MinPeakHeight=abs_min_height);

    % Are inverted peaks (valleys) allowed?
    if ~options.inverted_peaks, x(y<0) = []; y(y<0) = []; end

    % Create struct
    peaks = PeakTable.convert_to_struct([x y]);
    [peaks.neg] = deal(false);

    % Do negative peaks?
    if options.negative_peaks
        [y, x] = findpeaks(-ydata, xdata, MinPeakProminence=abs_min_prominence, MinPeakHeight=abs_min_height);

        % Are inverted peaks (valleys) allowed?
        if ~options.inverted_peaks, x(y<0) = []; y(y<0) = []; end
        
        % Add to struct
        y = -y;
        peaks_neg = PeakTable.convert_to_struct([x y]);
        [peaks_neg.neg] = deal(true);
        peaks = [peaks; peaks_neg];
    end

    % Create PeakTable
    peak_table = PeakTable(peaks, self);
    peak_table.name = "Peaks of " + string(self.name);

    % Store used options to find peaks
    peak_table.min_prominence = options.min_prominence;
end