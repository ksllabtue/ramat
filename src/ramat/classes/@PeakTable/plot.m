function plot(self, options)
    %PLOT Plots peaks with annotations, overloads default plot function.
    %   This is the default method to plot the peaks contained in the
    %   PeakTable. It only takes the PeakTable as necessary input argument,
    %   additional keyword arguments provide plotting options and axis
    %   handles.
    %
    %   Examples:
    %   
    %   PLOT(peaktable, Axes=ax)

    arguments
        self PeakTable;
        options.Axes = [];
        options.Precision {mustBeReal,mustBeNumeric} = 0;     % number of digits right of decimal
        options.fancy_peak_markers = true;
    end

    if isempty(self) || ~isvalid(self)
        % Nothing has been selected or handle of deleted object.
        return
    end

    ax = options.Axes;

    % Plot original linked spectral data
    if ~isempty(self.parent_specdata)
        [ax, ~] = self.parent_specdata.plot(Axes = options.Axes);
    end

    % Get axes handle or create new figure window with empty axes
    [ax, ~] = self.plot_start(Axes = ax, reset=false);

    % Hold axes, so peaks are added to existing plot
    hold(ax, "on");

    % Clear any existing peakmarkers
    if isfield(ax.UserData, "peakmarkers")
        for peakmarker = ax.UserData.peakmarkers(:)'
            peakmarker.delete();
        end
        ax.UserData = rmfield(ax.UserData, "peakmarkers");
    end

    % Add annotation
    for peak = self.peaks(:)'

        % Use fancy peak markers?
        if options.fancy_peak_markers
            PeakMarker(ax, peak.x, peak.y, peak.neg);
            continue;
        end

        % Markers
        down_symbol = "▼";
        up_symbol = "▲";
        if peak.neg, marker_symbol = up_symbol;
        else, marker_symbol = down_symbol; end

        % Create string for annotation
        annotation_string = sprintf("%.*f", options.Precision, peak.x);
        annotation_marker = {annotation_string; marker_symbol; ""; ""; ""};
        
        % Invert for negative peaks
        if peak.neg, annotation_marker = flipud(annotation_marker); end
        
        % Add annotation to plot
        t = text(ax, peak.x, peak.y, annotation_marker);
        t.HorizontalAlignment = 'center';
        t.FontWeight = 'bold';
    end

end