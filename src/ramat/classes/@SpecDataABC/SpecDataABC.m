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
                options.zero_to_nan logical = false;
                options.ignore_nan logical = true;
            end

            % Prepare data
            export_array = self.get_formatted_export_array( ...
                direction=options.direction, ...
                include_wavenum=options.include_wavenum, ...
                rand_subset=options.rand_subset, ...
                rand_num=options.rand_num, ...
                zero_to_nan = options.zero_to_nan, ...
                ignore_nan = options.ignore_nan);

            % Ask for path
            if options.path == ""
                [file, path] = self(1).export_ui_dialog(format=options.format, format_list=self(1).format_list);
                options.path = fullfile(path, file);
            end

            write_mode = "overwrite";
            if options.format == "xlsx", write_mode = "overwritesheet"; end

            % Write to file
            fprintf("\nWriting to file...\n");
            writematrix(export_array, options.path, WriteMode=write_mode);
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
                options.zero_to_nan logical = false;
                options.ignore_nan logical = true;
            end

            numarray = [];

            % Create column with wave numbers
            wavenum_col = [];
            if options.include_wavenum, wavenum_col = self(1).graph; end
            if options.rand_subset, wavenum_col = [0; wavenum_col]; end

            % Prepare for concatenation of multiple spectra
            num_items = numel(self);
            if num_items > 1, wavenum_col = [0; wavenum_col]; end

            flatdata = [];
            pos = [];
            i = 1;

            % Go through every spectrum s in self
            for s = self(:)' 
                % Data segment creation
                if options.rand_subset
                    % Get a small selection
                    [sel_data, pos] = s.select_random(options.rand_num, zero_to_nan=options.zero_to_nan, ignore_nan=options.ignore_nan);
                    % Create data segment
                    dat = zeros(s.GraphSize + 1, size(sel_data, 2));
                    dat(1,:) = pos(:)';         % Append positions (spectral indices) as first row
                    dat(2:end, :) = sel_data;   % Append selected data on following rows.
                else
                    % Create data segment
                    dat = s.get_flatdata();
                end

                % When multiple items are selected, include index as first
                % row.
                if num_items > 1
                    id_row = repmat(i,[1, size(dat, 2)]);
                    dat = [id_row; dat];
                end

                % Cocatenate data segment.
                flatdata = [flatdata dat];

                i = i+1;
            end

            % Append flat data
            numarray = [wavenum_col flatdata];

            % Transpose
            if options.direction == "horizontal", numarray = transpose(numarray); end
            
        end

        function flatdata = get_flatdata(self, options)
            %FLATDATA
            % Default. Overriden in <SpecData>

            arguments
                self;
                options.zero_to_nan logical = false;
                options.ignore_nan logical = true;
            end

            dat = self.data;

            % Process data
            if options.zero_to_nan, dat = SpecData.zero_to_nan(dat); end
            if options.ignore_nan, dat = SpecData.remove_nan(dat); end
            
            flatdata = dat;
        end

        function [data, pos] = select_random(self, rand_num, options)
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
                options.zero_to_nan logical = false;
                options.ignore_nan logical = true;
            end
            
            % This is returned by default
            opts = unpack(options);
            data = self.get_flatdata(opts{:});
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

        function set_zero_to_nan(self, options)
            %SET_ZERO_TO_NAN Sets spectra, which are completely zeroed out
            %to NaN.
            %   This function sets all pixels in which the entire spectrum
            %   equals to zero to NaN. This is a wrapper function of
            %   get_zero_to_nan, which only retrieves the data with all
            %   pixels in which all zeroed-out pixels are set to NaN

            arguments
                self {mustBeA(self, "SpecDataABC")};
                options.copy logical = false;
            end
            
            if options.copy
                self = copy(self);
                self.append_sibling(self);
            end

            self.data = self.get_zero_to_nan();
        end

        function nandata = get_zero_to_nan(self)
            %GET_ZERO_TO_NAN Returns spectrum in which zeroed-out pixels
            %are set to NaN
            %   This function sets all pixels in which the entire spectrum
            %   equals to zero to NaN.

            arguments
                self {mustBeA(self, "SpecDataABC")};
            end

            % Positions that should be set to NaN
            nandata = SpecDataABC.zero_to_nan(self.data);
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

        function format_list = get_export_formats(self)
            %GET_EXPORT_FORMATS Returns list of exportable formats.
            format_list = self.format_list;
        end
        
    end

    methods (Static)
        function data = zero_to_nan(data)
            %ZERO_TO_NAN Returns spectrum in which zeroed-out pixels are
            %set to NaN

            arguments
                data {mustBeNumeric};
            end

            sizes = size(data);
            
            switch numel(sizes)
                case 2
                    % Positions that should be set to NaN
                    idx = all(data == 0, 1);
                    % Set to nan
                    data(:,idx) = deal(nan);
                case 3
                    % Positions that should be set to NaN
                    idx = all(data == 0, 3);
                    idx = repmat(idx, [1 1 sizes(3)]);
                    % Set to nan
                    data(idx) = nan;
            end
            
        end

        function data = remove_nan(data)
            %REMOVE_NAN Removes all nan spectra. Only works with flattened
            %spectra!

            arguments
                data {mustBeNumeric};
            end

            sizes = size(data);

            % Can only remove nan from flattened array
            if numel(sizes) > 2, return; end
            
            % Positions that should be set to NaN
            idx = all(isnan(data), 1);

            % Set to nan
            data(:,idx) = [];
        end
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

