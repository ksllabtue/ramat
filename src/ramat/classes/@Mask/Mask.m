classdef Mask < DataItem
    %MASK Logical mask for area scans
    
    properties
        data logical = logical.empty(); % Mask data
        parent_specdata SpecData = SpecData.empty();
    end

    properties (Dependent)
        flat_indices int32;
        XSize;
        YSize;
        ZSize;
        DataSize;
    end

    properties (SetAccess = private)
        Type = "Mask";
    end
    
    methods
        function self = Mask(data, parent_specdata, name)
            %MASK Construct an instance of this class
            
            arguments
                data logical = logical.empty();
                parent_specdata SpecData = SpecData.empty();
                name string = "";
            end

            % Mask
            self.data = data;
            self.parent_specdata = parent_specdata;
            self.name = name;
            
        end

        function generate_random(self, rand_num, options)

            arguments
                self Mask;
                rand_num int32;
                options.zero_to_nan logical = true;
                options.ignore_nan logical = true;
                options.dimensions (1,2) int32 = [];
            end

            if isempty(self.parent_specdata) && isempty(options.dimensions)
                return;
            end

            if ~isempty(self.parent_specdata)
                % Use generate random selection function of the spectral
                % data
                maskdata = self.parent_specdata.gen_random_selection(rand_num, zero_to_nan=options.zero_to_nan, ignore_nan=options.ignore_nan);

                % Set mask data
                self.data = maskdata;

                return;
            end

            % Generate random mask without linked spectral data
            data_size = options.dimensions(1) * options.dimensions(2);
            linear_mask = false(data_size, 1);
            idx = randperm(data_size, rand_num);
            linear_mask(idx) = true;
            maskdata = reshape(linear_mask, options.dimensions);

            self.data = maskdata;

        end

        function [ax, f] = plot(self, options)

            arguments
                self;
                options.?PlotOptions;
                options.Axes = [];
            end

            % Get axes handle or create new figure window with empty axes
            [ax, f] = self.plot_start(Axes = options.Axes);

            imagesc(self.data);

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

            % Add plotting menu
            uimenu(cm, Text="Plot", MenuSelectedFcn=@(~,~) plot(self));

            % Add generate
            uimenu(cm, Text="Generate random selection mask", MenuSelectedFcn=@(~,~) self.generate_random())

        end
        
        %% Dependent Properties
        function flat_indices = get.flat_indices(self)
            %FLAT_INDICES Get flat index numbers of spectra

            flat_mask = self.data(:);
            flat_indices = find(flat_mask);
        end

        function xres = get.XSize(self)
            xres = size(self.Data, 1);
        end
        
        function yres = get.YSize(self)
            yres = size(self.Data, 2);
        end
        
        function zres = get.ZSize(self)
            % TO BE IMPLEMENTED
            zres = 1;
        end
        
        function datares = get.DataSize(self)
            datares = self.XSize * self.YSize * self.ZSize;
        end
    end

end

