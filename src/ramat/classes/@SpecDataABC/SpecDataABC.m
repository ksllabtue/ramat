classdef (Abstract) SpecDataABC < DataItem
    %SPECDATAABC Abstract Base Class (ABC) for spectral data
    %   This class is a abstract base class for classes that store spectral
    %   data.
    %
    %   Child classes:
    %       SpectrumSimple  Simple static, non-spatial spectral data
    %       SpecData        Full spectral data
    %   
    %   Parent Class: DataItem
    %
    %   Properties inherited from parent class "DataItem":
    %       name        string
    %       description string
    %       parent      DataContainer
    %       Type        string

    properties (Abstract)
        % Spectral data, must have concrete implementation
        data;
    end
    
    properties      
        % Spectral Data
        data_unit string;
        
        % Spectral Base
        graph double;
        graph_unit string;
        
        % PeakTable
        peak_table = PeakTable.empty();
    end
    
    properties (Access = public, Dependent)
        GraphSize;
    end

    properties (Dependent, Abstract)
        DataSize;
    end
    
    properties (SetAccess = private)
        Type = "SpecData";
    end

    % List of exportable formats
    properties (SetAccess = private, GetAccess = private)
        format_list = ["csv";"mat";"xlsx"];
    end

    % Signatures
    methods
        peak_table = add_peak_table(self, options);
        peak_table = gen_peak_table(self, options);
    end
    
    methods

        function idx = wavnumtoidx(self, wavnum)
            % WAVNUMTOIDX Convert wavenumbers to indices
            
            if numel(wavnum) == 1
                idx = find(self.graph > wavnum, 1, 'first');
            elseif numel(wavnum) == 2
                startIdx = find(self.graph > wavnum(1), 1, 'first');
                endIdx = find(self.graph < wavnum(2), 1, 'last');
                
                idx = [startIdx, endIdx];
            end
            
        end

        function export(self, options)
            %EXPORT Exports numerical data of specdata to specificied
            %output format

            arguments
                self;
                options.path string = "";
                options.format string = "";
                options.format_list string = self.format_list;
                options.direction string = "horizontal";
                options.include_wavenum logical = true;
                options.rand_subset logical = true;
                options.rand_num uint32 = 100;
            end

            % Prepare data
            export_array = self.get_formatted_export_array( ...
                direction=options.direction, ...
                include_wavenum=options.include_wavenum, ...
                rand_subset=options.rand_subset, ...
                rand_num=options.rand_num);

            % Ask for path
            if options.path == ""
                [file, path] = self.export_ui_dialog(format=options.format, format_list=self.format_list);
                options.path = fullfile(path, file);
            end

            % Write to file
            fprintf("\nWriting to file...\n");
            writematrix(export_array, options.path);
            fprintf("Finished.\n");
            
        end

        function numarray = get_formatted_export_array(self, options)
            %GET_FORMATTED_EXPORT_ARRAY Outputs formatted flat array ready
            %for export or printing.
            %
            %   Example usage:
            %       get_formatted_export_array(self,
            %       direction="horizontal") will generate the following:
            %        0      wavenumbers --->
            %        idx1   data of spectrum 1 --->
            %        idx2   data of spectrum 2 --->

            arguments
                self
                options.direction string = "vertical";
                options.include_wavenum logical = true;
                options.rand_subset logical = false;    % Select random subset of data
                options.rand_num uint32 = 100;          % Number of randomly selected spectra
            end

            numarray = [];

            if options.include_wavenum, numarray = self.graph; end

            flatdata = [];
            pos = [];

            if options.rand_subset
                % Get a small selection
                [flatdata, pos] = self.select_random(options.rand_num);

                % Append positions (spectral indices) as first row
                flatdata = [pos(:)' ; flatdata];
                numarray = [0; numarray];
            else
                flatdata = self.get_flatdata();
            end

            % Append flat data
            numarray = [numarray flatdata];

            % Transpose
            if options.direction == "horizontal", numarray = transpose(numarray); end
            
        end

        function flatdata = get_flatdata(self)
            %FLATDATA
            % Default. Overriden in <SpecData>
            flatdata = self.data;
        end

        function [data, pos] = select_random(self, rand_num)
            %SELECT_RANDOM Selects a random number of spectra from the
            %data and outputs corresponding spectral indices.
            %
            %   Output:
            %       data    The random spectra
            %       pos     The indices belonging to the randomly selected
            %               data.

            arguments
                self;
                rand_num uint32 = 100;
            end
            
            % This is returned by default
            data = self.get_flatdata();
            pos = 1:self.DataSize;

            % Check if we can actually sample from this
            if rand_num > self.DataSize
                warning("Number of random sampled spectra is larger than data size.");
                return;
            end

            % Select random spectra.
            pos = randperm(self.DataSize, rand_num);
            data = data(:, pos);

        end
        
        % DEPENDENT PROPERTIES
        function wavres = get.GraphSize(self)
            % Returns size or wave resolution of the spectral graph
            wavres = size(self.graph, 1);
        end

        function preview_peak_table(self, options)
            %PREVIEW_PEAK_TABLE

            arguments
                self
                options.Axes = [];
                options.min_prominence = 0.1;
                options.negative_peaks = false;
            end

            peaktable = self.gen_peak_table(min_prominence=options.min_prominence, negative_peaks=options.negative_peaks);

            if isempty(peaktable)
                warning("No peak table was extracted.");
                return;
            end

            peaktable.plot(Axes = options.Axes);
            
        end

        function add_context_actions(self, cm, node, app)
            %ADD_CONTEXT_ACTIONS Retrieve all (possible) actions for this
            %data item that should be displayed in the context menu
            %   This function adds menu items to the context menu, which
            %   link to specific context actions for this data item.
            %
            arguments
                self;
                cm matlab.ui.container.ContextMenu;
                node matlab.ui.container.TreeNode;
                app ramatguiapp;
            end

            % Get parent actions of DataItem
            add_context_actions@DataItem(self, cm, node, app);

            % Get specific context actions for SpecDataABC
            opts.min_prom = app.MinimumProminenceEditField.Value;
            opts.neg_peaks = app.PeakAnalysisNegativeCheckbox.Value;

            menu_item = uimenu(cm, ...
                Text="Peak Analysis");
            uimenu(menu_item, ...
                Text="Preview Peak Analysis (min_prom: " + string(opts.min_prom) + ")", ...
                MenuSelectedFcn={@preview, self, opts});
            uimenu(menu_item, Text="Extract Peak Table (min_prom: " + string(opts.min_prom) + ")", ...
                MenuSelectedFcn={@extract, self, app, opts});

            uimenu(cm, Text="Export ...", MenuSelectedFcn=@(~,~) ExportOptionsDialog(self));

            function preview(~, ~, self, opts)
                self.preview_peak_table(min_prominence=opts.min_prom, negative_peaks=opts.neg_peaks);
            end

            function extract(~, ~, self, app, opts)
                self.add_peak_table(min_prominence=opts.min_prom, negative_peaks=opts.neg_peaks);
                update_data_items_tree(app, self.parent_container);
            end

        end
        
    end

    methods (Abstract)

    end

    % Spectral operations
    methods
        function r = plus(a, b)
            r = op_start(a, b);
            r.data = a.data + b.data;
            r.graph = a.graph;
            r.graph_unit = a.graph_unit;
        end

        function r = minus(a, b)
            r = op_start(a, b);
            r.data = a.data - b.data;
            r.graph = a.graph;
            r.graph_unit = a.graph_unit;
        end

        function r = sum(vec)
            r = op_start(vec);
            r.data = sum([vec.data], 2);
            r.graph = vec(1).graph;
            r.graph_unit = vec(1).graph_unit;
        end

        function r = mean(vec)
            r = op_start(vec);
            r.data = mean([vec.data], 2);
            r.graph = vec(1).graph;
            r.graph_unit = vec(1).graph_unit;
        end
    end
end

