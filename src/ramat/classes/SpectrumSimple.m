classdef SpectrumSimple < SpecDataABC
    %SPECTRUMSIMPLE Simple spectral class.
    %   This class contains simple spectral data (X and Y data) for direct
    %   plotting and peak analysis. This class can be used for plotting
    %   data. This class can NOT store spatial data.
    %
    %   Parent Class: SpecDataABC
    %
    %   Properties inherited from parent class "DataItem":
    %       name        string
    %       description string
    %       parent      DataContainer
    %       Type        string
    %
    %   Properties inherited from parent class "SpecDataABC":
    %       data        double  (abstract)
    %       data_unit   string
    %       graph       double (1xm)
    %       graph_unit  string
    %       peak_table  PeakTable

    properties (Access = public)
        data;
        source {mustBeA(source, ["SpecData", "PCAResult"])} = SpecData.empty;
        legend_entries string = "data";
    end

    properties (Dependent)
        DataSize;
    end

    methods
        function self = SpectrumSimple(xdata, xdata_unit, ydata, ydata_unit, source, opts)
            %SPECTRUMSIMPLE Creates an instance of a simple spectral class

            arguments
                xdata double = [];
                xdata_unit string = "";
                ydata double = [];
                ydata_unit string = "";
                source {mustBeA(source, ["SpecData", "PCAResult"])} = SpecData.empty;
                opts.legend_entries string = "";
            end

            self.graph = xdata;
            self.graph_unit = xdata_unit;
            self.data = ydata;
            self.data_unit = ydata_unit;
            self.source = source;

            % Get legend entries
            if ~isempty(source) && (opts.legend_entries == "")
                opts.legend_entries = source.name;
            end
            self.legend_entries = opts.legend_entries;

        end

        function m = max(self)
            m = max(max([self.data]));
        end

        function [ax, f] = plot(self, kwargs)
            %PLOT

            arguments
                self;
                kwargs.Axes = [];                
                kwargs.plot_type = "Overlaid";   % 'Overlaid', 'Stacked'
                kwargs.plot_stack_distance = 1;   % Stacking Shift Multiplier
                kwargs.normalize = false;
                kwargs.plot_peaks = true;
                kwargs.legend_entries string = self.legend_entries;
            end

            % Call plot at superclass, to properly set axes
            [ax, f] = plot@DataItem(self, Axes=kwargs.Axes);

            % Set-up Axes
            ax.PlotBoxAspectRatioMode = 'auto';
            ax.DataAspectRatioMode = 'auto';
            ax.XLimMode = 'auto';
            ax.YLimMode = 'auto';
            ax.YDir = 'normal';
            ax.XTickMode = 'auto';
            ax.YTick = [];

            ax.Color = 'none';

            % Set Labels
            ax.XLabel.String = "Raman Shift " + self(1).graph_unit;
            ax.YLabel.String = self(1).data_unit;

            % Hold for multiple data
            hold(ax, 'on');
            
            % Calculate shift in case stacked data is plotted
            if kwargs.plot_type == "Stacked"
                % Stacked Plot
                multiplier = kwargs.plot_stack_distance;
                
                if kwargs.normalize
                    stackShift = multiplier;
                else
                    % Apply multiplier to maximum value
                    stackShift = max(self) * multiplier;
                end
                
            else
                % Overlaid Plot
                stackShift = 0;
            end

            % PLOTTING
            for i = 1:numel(self)
                s = self(i);

                % Abort if multiple large-area scans have been given
%                 if (numel(self) > 1 && dat.Data.DataSize > 1)
%                     throw(MException("Ramat:Cannotplot", "Cannot plot multiple large area scans in single preview window."));
%                 end

                xdat = s.graph;
                ydat = s.data;
                
                % Normalize YData
                if kwargs.normalize
                    ydat = ydat - min(ydat);
                    ydat = ydat ./ max(ydat);
                    
                end
                
                % Stacked Plot
                if kwargs.plot_type == "Stacked"
                    ydat = ydat - (i - 1)*stackShift;
                    
                end

                plot(ax, xdat, ydat);

                % Add peaks
                if kwargs.plot_peaks
%                     if ~isempty(self(i).peak_table)
%                         % There are peaktables
%                         peaktable = dat.children( find(vertcat(dat.children.Type) == "PeakTable", 1, 'first' ) );
%                         peaktable.plot(Axes=ax);
%                     end
                end

            end

            % Add legend
            leg = legend(ax, vertcat(kwargs.legend_entries));
            leg.Color = 'none';
            leg.Box = "off";

            % Release hold
            hold(ax, 'off');

        end
        
        function datasize = get.DataSize(self)
            %DATASIZE Number of spectra
            
            sizes = size(self.data);
            datasize = sizes(2);
        end
    end
    
end