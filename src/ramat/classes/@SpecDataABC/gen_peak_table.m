function peak_table = gen_peak_table(self, options)
    % FIND_PEAKS

    arguments
        self {mustBeA(self, "SpecDataABC")};
        options.min_prominence double = 0.1;
        options.negative_peaks logical = false;
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

    if class(self) == "SpecData"
        ydata = self.get_single_spectrum();
    else
        ydata = self.data;
    end

    range = max(ydata) - min(ydata);

    % Calculate absolute prominence
    abs_min_prominence = options.min_prominence * range;

    % Find peaks
    [y, x] = findpeaks(ydata, xdata, MinPeakProminence=abs_min_prominence);
    peaks = struct('x', num2cell(x(:)), 'y', num2cell(y(:)));
    [peaks.neg] = deal(false);

    % Do negative peaks?
    if options.negative_peaks
        [y, x] = findpeaks(-ydata, xdata, MinPeakProminence=abs_min_prominence);
        y = -y;
        peaks_neg = struct('x', num2cell(x(:)), 'y', num2cell(y(:)));
        [peaks_neg.neg] = deal(true);
        peaks = [peaks; peaks_neg];
    end

    % Create PeakTable
    peak_table = PeakTable(peaks, self);
    peak_table.name = "Peaks of " + string(self.name);

    % Store used options to find peaks
    peak_table.min_prominence = options.min_prominence;
end