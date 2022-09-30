function ax = plot(self, options)
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
        options.?PlotOptions;
        options.Axes = [];
        options.Precision {mustBeReal,mustBeNumeric} = 0;     % number of digits right of decimal
        options.plot_type = "Overlaid";   % 'Overlaid', 'Stacked'
        options.plot_stack_distance = 1;   % Stacking Shift Multiplier
        options.fancy_peak_markers = true;
        options.plot_parent_spectra = true;
    end

    if any(isempty(self)) || any(~isvalid(self))
        % Nothing has been selected or handle of deleted object.
        return
    end

    ax = options.Axes;
    yshift = 0;

    % Retrieve parent spectra
    parent_spectra = vertcat(self.parent_specdata);
    if numel(parent_spectra) ~= numel(self)
        % Cannot plot parent spectra. One or more parent spectra are empty.
        options.plot_parent_spectra = false;
    end

    % Plot original linked spectral data
    if options.plot_parent_spectra
        [ax, ~] = parent_spectra.plot(Axes = ax, plot_type = options.plot_type, plot_stack_distance = options.plot_stack_distance);        
        
        if options.plot_type == "Stacked"
            yshift = parent_spectra.calculate_stack_shift(options.plot_stack_distance);
        end
    end
%     for ptable = self(:)'
%         if ~isempty(ptable.parent_specdata)
%             [ax, ~] = ptable.parent_specdata.plot(Axes = ax);
%         end
%     end

    % Get axes handle or create new figure window with empty axes
    % Do NOT reset plot, because we are going to add stuff if we plot over
    % a spectrum
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
    
    % Plotting starts, allow for multiple PeakTables to be plotted
    % simultaneously
    ti = 0;
    for ptable = self(:)'

        % Add annotation for every peak
        for peak = ptable.peaks(:)'
    
            % Use fancy peak markers?
            if options.fancy_peak_markers
                pm = PeakMarker(ax, peak.x, peak.y, peak.neg, fontsize=13);

                pm.fix_shift(-yshift * ti);
                continue;
            end

            % Plot regular peak markers
            plot_regular_peak_markers(peak, options, ax);
                
        end

        ti = ti + 1;

    end

    function plot_regular_peak_markers(peak, options, ax)
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