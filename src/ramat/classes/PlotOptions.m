classdef PlotOptions
    properties
        Axes = [];               % Axes Handle
        preview = false;         % When true, LAScan is reduced to one spectrum
        plot_type = "Overlaid";   % 'Overlaid', 'Stacked'
        plot_stack_distance = 1;   % Stacking Shift Multiplier
        normalize = false;
        plot_peaks = true;
        legend_entries string = "";
        plot_zero_line logical = false;

        % PCAs
        PCs uint8 = [1 2];
    end
end