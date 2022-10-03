classdef SpecData < SpecDataABC
    %SPECDATA Full spectral data class
    %   This class stores spectral data, including spatial information.
    %   This class will generate a simple spectrum "SpectrumSimple" class
    %   for plotting purposes.
    %
    %   Parent Class: SpecDataABC < DataItem
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
        % Spectral Data
        data;

        % Meta
        excitation_wavelength double;
        
        % Spatial Grid Data
        x double;
        y double;
        z double;
        xlength double;
        ylength double;
        zlength double;

        % Cursor for large area spectra
        cursor Cursor;

        % Mask
        mask Mask;

        % Filter
        active_filter SpecFilter = SpecFilter.empty();
    end

    properties (Access = public, Dependent)
        %Filter
        filter;
        filter_output;

        FilteredData;
        FlatDataArray;
%         GraphSize;
        XSize;
        YSize;
        ZSize;
        DataSize;
    end

    % List of exportable formats
    properties (SetAccess = private, GetAccess = private)
        format_list = ["csv";"mat";"xlsx"];
    end

    % Signatures
    methods
        remove_baseline(self, method, kwargs);
        out = clipByMask(self, mask);
        y = tsne(self, opts);
        out = trim_spectrum(self, startg, endg, opts);
    end
    
    methods
        function self = SpecData(name, graphbase, data, graphunit, dataunit, options)
            %SPECDATA Construct an instance of this class
            %   Stores x-data and y-data

            arguments
                name string = "";
                graphbase double = [];
                data {mustBeA(data, ["double", "single"])} = [];
                graphunit string = "cm-1";
                dataunit string = "a.u.";
                options.dimensions int32 = [];
            end

            % Convert data to double
            if class(data) == "single"
                data = double(data);
            end

            % Store input args as properties
            self.name = name;
            self.graph = graphbase;
            self.graph_unit = graphunit;
            self.data_unit = dataunit;

            % Set data
            self.set_data(data, dimensions=options.dimensions);

            % Create LA scan cursor
            self.cursor = Cursor(self);

        end
        
        
        function normalize_spectrum(self, kwargs)
            % Normalizes spectrum, so sum(Data) = 1

            arguments
                self
                kwargs.copy logical = false;
                kwargs.range double = [];
            end

            fprintf("Normalizing " + num2str(numel(self)) + " spectra, using range: " + num2str(kwargs.range) + ".\n");
            
            % Repeat operation for each spectral data object
            for s = self(:)'

                % Divide by sums of the individual spectra
                dat = s.data;

                % Sum
                if isempty(kwargs.range)
                    % Calculate sum of entire spectrum
                    sumdat = sum(dat, 3);
                else
                    % Calculate sum of part of spectrum
                    idx = s.wavnumtoidx(kwargs.range);
                    sumdat = sum(dat(:,:,idx(1):idx(2)), 3);
                end

                norm_data = dat ./ sumdat;

                if kwargs.copy
                    % Create copy
                    new_specdat = copy(self);
                    new_specdat.data = norm_data;
                    new_specdat.description =  "Normalized";
                    self.append_sibling(new_specdat);
                else
                    % Overwrite
                    s.data = norm_data;
                end
            end
        end
                
        function remove_constant_offset(self)
            % Removes a constant offset (minimum value)
            
            % Repeat operation for each spectral data object
            for i = 1:numel(self)
                dat = self(i).data;
                graph_resolution = self(i).GraphSize;
                
                min_values = min(dat, [], 3);
                subtractionMatrix = repmat(min_values, 1, 1, graph_resolution);
                
                self(i).data = dat - subtractionMatrix;
            end
        end
        function removeConstantOffset(self)
            warning("Rename SpecData.removeConstantOffset()");
            self.remove_constant_offset();
        end

        function [ax, f] = plot(self, options)
            %PLOT Default plotting method, overloads default plot function.
            %   This is the default method to plot data within the SpecData. It
            %   only takes the data container as necessary input argument, additional
            %   keyword arguments provide plotting options and axis handles.
            %
            %   It generates SpectrumSimple instances and calls the plot
            %   method of SpectrumSimple.

            arguments
                self SpecData;
                options.?PlotOptions;
                options.Axes = [];
            end

            spec_simple = self.get_spectrum_simple();

            opts = namedargs2cell(options);
            [ax, f] = spec_simple.plot(opts{:});

            spec_simple.delete();
        end
        

        function spec_simple = get_spectrum_simple(self)
            %GET_SPECTRUM_SIMPLE Get simple spectrum class
            %   wrapper function of GET_SINGLE_SPECTRUM.
            %
            %   Out:
            %       spec_simple (1xn) Spectrum_1D

            nout = numel(self);
            spec_simple = SpectrumSimple.empty(nout,0);

            for i = 1:nout
                ydata = self(i).get_single_spectrum();
    
                spec_simple(i) = SpectrumSimple( ...
                    self(i).graph, ...                     % xdata
                    self(i).graph_unit, ...                % xdata_unit
                    ydata, ...                          % ydata
                    self(i).data_unit, ...                 % ydata_unit
                    self(i));                              % source
            end

        end

        function spec = get_single_spectrum(self)
            %GET_SINGLE_SPECTRUM Retrieves single spectrum at cursor or
            %accumulated over the size of the cursor
            %
            %   Out:
            %       spec    double

            if (self.DataSize == 1)
                spec = self.data(1, 1, :);
                spec = permute(spec, [3 1 2]);
                return;
            end

            if isempty(self.cursor)
                self.cursor = Cursor(self);
            end

            if (self.cursor.size == 1)
                spec = self.data(self.cursor.x, self.cursor.y, :);

            else
                % Accumulate over cursor
                
                rows = self.cursor.mask_coords.rows;
                cols = self.cursor.mask_coords.cols;
                spec = mean(self.data(rows(1):rows(2), cols(1):cols(2), :),[1 2]);

            end

            % Return 1-dimensional array
            spec = permute(spec, [3 1 2]);

        end

        function flatdata_out = get_flatdata(self, options)
            %GET_FLATDATA Returns m*n (two-dimensional) matrix.
            %   Returns flattened array. Input can be an array of multiple
            %   SpecData objects. In that case, the sizes should be
            %   consistent.

            arguments
                self SpecData;
                options.zero_to_nan logical = false;
                options.ignore_nan logical = true;
            end

            % Prepare output
            rownum = self(1).GraphSize;

            if ~options.ignore_nan
                % Preallocated (optimized)
                colnum = sum([self.DataSize]);
                flatdata_out = zeros(rownum, colnum, 'double');
            else
                flatdata_out = double.empty(rownum,0);
            end

            % Size checks
            if ~all([self.GraphSize] == rownum)
                fprintf("Data sizes are inconsistent. Cannot concatenate flat data into array.\n");
                return;
            end

            colidx = 1;

            for spectrum = self(:)'
                % Get spectral data
                dat = spectrum.data;

                % Process data
                if options.zero_to_nan, dat = SpecData.zero_to_nan(dat); end

                % Flatten
                flat = SpecData.flatten(dat);

                % Remove nans
                if options.ignore_nan, flat = SpecData.remove_nan(flat); end
                numcols = size(flat,2);
                
                % Insert
                if ~options.ignore_nan
                    % Concatenate optimized
                    flatdata_out(:,colidx:colidx+numcols-1) = flat;
                    % Update column index
                    colidx = colidx + numcols;
                    continue;
                end

                % Concatenate non-optimized
                flatdata_out = [flatdata_out; flat]; %#ok<AGROW>
            end

        end

        function non_nan_datasize = get_non_nan_datasize(self, options)

            arguments
                self SpecData;
                options.zero_to_nan logical = true;
            end

            % Get spectral data
            dat = self.data;

            % Process data
            if options.zero_to_nan, dat = SpecData.zero_to_nan(dat); end

            non_nans = ~any(isnan(dat), 3);

            non_nan_datasize = sum(non_nans, "all");

        end


        function filter = get.filter(self)
            %FILTER Returns the active filter

            arguments
                self SpecData;
            end
                                    
            % Only LA Scans
            if self.DataSize <= 1
                return
            end

            filter = SpecFilter.empty();
            dataitemtypes = self.parent_container.listDataItemTypes();
            
            % Is there no filter present?
            if ~any(dataitemtypes == "SpecFilter")
                % Create new filter
                newfilter = SpecFilter();
                self.append_sibling(newfilter)
                self.set_filter(newfilter);
                
            end
            
            % Is there a filter present, but not set to active?
            if isempty(self.active_filter)
                % Return last SpecFilter from data items
                idx = find(dataitemtypes == "SpecFilter", 1, 'last');
                self.set_filter(self.parent_container.children(idx));
            end
            
            filter = self.active_filter;
            
        end
        
        function set_filter(self, filter)
            self.active_filter = filter;
        end
        
        function output = get.filter_output(self)
            %FILTEROUTPUT Output of filter operation.
            
            if isempty(self.filter)
                output = [];
                return
                
            end
            
            % Return output of filter
            output = self.filter.getResult(self);
            
        end

        function icon = get_icon(self)
            %GET_ICON Overrides <DataItem>.icon dependent property.
            icon = get_icon@DataItem(self);
            if (self.DataSize == 1), icon = "TDGraph_2.png"; end
            if (self.DataSize > 1), icon = "TDGraph_0.png"; end
        end

        function tags = get_tags(self)
            %GET_TAGS Returns tags for e.g. tooltips formatted as strings

            tags = string.empty;
            for s = self(:)'
                specnum = 1:s.DataSize;
                tags = [tags; s.name + specnum'];
            end
        end

        %% Overrides

      
        function avg_specdat = mean(self)
            % MEAN Returns averaged spectral data

            arguments
                self SpecData;
            end

            % Can only do for similarly sizes specdats
            assert(range(vertcat(self.GraphSize)) == 0, "Not all SpecData instances are equal in size.");
            assert(range(vertcat(self.XSize)) == 0, "Not all SpecData instances are equal in size.");
            assert(range(vertcat(self.YSize)) == 0, "Not all SpecData instances are equal in size.");

            % Calculate average
            avg_dat = mean(cat(4, self.data), 4);

            % Create SpecDat
            newname = sprintf("Average of %d", numel(self));
            avg_specdat = SpecData(newname, self(1).graph, avg_dat, self(1).graph_unit, self(1).data_unit);
    
        end
        
        % DEPENDENT PROPERTIES        
        function xres = get.XSize(self)
            xres = size(self.data, 1);
        end
        
        function yres = get.YSize(self)
            yres = size(self.data, 2);
        end
        
        function zres = get.ZSize(self)
            % TO BE IMPLEMENTED
            zres = 0;
        end
        
        function datares = get.DataSize(self)
            datares = self.XSize * self.YSize;
        end
        
        function flatdata = get.FlatDataArray(self)
            flatdata = SpecData.flatten(self.data);
        end

        function filtereddata = get.FilteredData(self)
            % Returns filtered and masked data

            filtereddata = clipByMask(self, self.Mask, Clip=false);

        end
        
        
        %% Setter
        
        function set_data(self, data, options)
            %SET_DATA

            arguments
                self SpecData;
                data = [];
                options.dimensions int32 = [];
            end

            if isempty(data), return; end

            % Can we set three-dimensional data directly?
            if numel(size(data)) == 3
                self.data = data;
                return;
            end

            % Convert and set data
            self.set_2d_data(data, options.dimensions);

        end

        function set_2d_data(self, data, dimensions, options)

            arguments
                self SpecData;
                data = [];
                dimensions int32 = [];
                options.direction string = "vertical";
            end

            if isempty(data), return; end

            % Is it a single spectrum?
            if any(size(data) == 1)
                options.dimensions = [1 1];
                self.data = SpecData.unflatten(data, options.dimensions);
                return;
            end

            % Convert
            if isempty(dimensions)
                    dimensions = [self.XSize self.YSize];
            end
            self.data = SpecData.unflatten(data, dimensions);

        end
        

        
    end

    methods (Static)
        function flatdata = flatten(data, direction)
            %FLATTEN Convert ixjxk (three-dimensional) data array to ixj
            %data array
            %   Returns a two-dimensional m-by-n array of spectral data
            %   
            %   Input:
            %       - data      3d data
            %       - direction (optional)  without: outputs m-by-n array,
            %       where m is number of wavenumbers and n is number of
            %       spectra. When horizontal: m = num spectra, n = num
            %       wavenumbers

            arguments
                data
                direction string = "vertical";
            end

            graphsize = size(data, 3);
            flatdata = permute(data, [3 1 2]);
            flatdata = reshape(flatdata, graphsize, [], 1);

            % Transpose, if horizontal is desired
            if direction == "horizontal"
                flatdata = transpose(flatdata);
            end
        end

        function threedimdata = unflatten(data, dimensions, options)
            %UNFLATTEN Convert a two-dimension i*j data array to an ixjxk
            %(three-dimensional) data array
            %   Returns a three-dimensional mxnxo data array

            arguments
                data
                dimensions int32 = [];
                options.direction string = "vertical";
                options.graphsize int32 = [];
            end

            if isempty(dimensions) || isempty(data)
                out("Cannot unflatten data. Dimensions or data is empty.");
                return;
            end

            % Make sure we get horizontal spectra --->
            if options.direction == "vertical"
                data = transpose(data);
            end

            % Check whether we can reshape
            xsize = dimensions(1);
            ysize = dimensions(2);            
            assert(xsize*ysize == size(data, 1), "Cannot unflatten data. Provided dimensions %d x %d = %d do not match number of provided spectra: %d", xsize, ysize, xsize*ysize, size(data,1));

            % Retrieve graphsize from array dimensions
            if isempty(options.graphsize), options.graphsize = size(data,2); end

            threedimdata = permute(reshape(data, xsize, ysize, options.graphsize), [2 1 3]);
        end
    end
end

