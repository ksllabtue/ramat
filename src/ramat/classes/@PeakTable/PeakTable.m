classdef PeakTable < DataItem
    % PEAKTABLE Stores extracted peak table

    properties
        peaks struct = struct.empty;
        parent_specdata;
        min_prominence = [];
    end

    properties (Dependent)
    	locations;
        as_table;
    end

    properties (SetAccess = private)
        Type = "PeakTable";
    end

    properties (SetAccess = private, GetAccess = private)
        format_list = ["csv";"mat"];
    end

    % Method signatures
    methods
        plot(self, options)
    end

    methods
        function self = PeakTable(peaks, parent_specdata, name)
            % PEAKTABLE Construct an instance of this class

            arguments
                peaks {mustBeA(peaks, ["struct", "double"])} = [];
                parent_specdata {mustBeA(parent_specdata, "SpecDataABC")} = SpecData.empty;
                name string = "";
            end

            % Parse input into struct
            if isa(peaks, "double")
                peaks = PeakTable.convert_to_struct(peaks);
            end

            self.peaks = peaks;
            self.parent_specdata = parent_specdata;
            self.name = name;
        end

        function x = get.locations(self)
            x = self.peaks.x;
        end

        function t = get.as_table(self)
            % TABLE Outputs peaks and locations as table

            t = struct2table(self.peaks);
            t.Properties.VariableNames = ["Wavenum", "Height", "Negative"];
        end

        function export(self, options)
            %EXPORT

            arguments
                self PeakTable;
                options.path string = "";
                options.format string = "";
            end

            if options.path == ""
                [file, path] = export_ui_dialog(self, format=options.format, format_list=self.format_list);
                options.path = fullfile(path, file);
            end

            if strcmp(path,' \ '), return; end

            peaktable = self.as_table;

            switch options.format
                case "csv"
                    writetable(peaktable, options.path);
                case "mat"
                    save(options.path, 'peaktable');
            end

        end

        function print(self)
            %PRINT Prints the peaktable to console
            fprintf("\n== PeakTable ==\n");
            fprintf("Name:       " + self.name + "\n");
            if ~isempty(self.parent_specdata), fprintf("Parent:     " + [self.parent_specdata.name] + "\n"); end
            fprintf("Min prom:   %f\n\n", self.min_prominence);
            disp(self.as_table);
        end


        function add_context_actions(self, cm, node, app)
            %ADD_CONTEXT_ACTIONS Retrieve all (possible) actions for this
            %data item that should be displayed in the context menu
            %   This function adds menu items to the context menu, which
            %   link to specific context actions for this data item.
            %
            arguments
                self PeakTable;
                cm matlab.ui.container.ContextMenu;
                node matlab.ui.container.TreeNode;
                app ramatguiapp;
            end

            % Get parent actions of DataItem
            add_context_actions@DataItem(self, cm, node, app);

            uimenu(cm, Text="Plot", MenuSelectedFcn=@(~,~) plot(self));

            uimenu(cm, Text="Print Peak Table", MenuSelectedFcn=@(~,~) print(self));
            
            menu_export = uimenu(cm, Text="Export as ...");
            uimenu(menu_export, Text="Comma-separated values (.csv, .txt)", MenuSelectedFcn={@export, self, "csv"});
            uimenu(menu_export, Text="MATLAB file (.mat)", MenuSelectedFcn={@export, self, "mat"});




            function export(~, ~, self, format)
                self.export(format=format);
            end

        end

    end

    methods (Static)
        function peaks = convert_to_struct(peaks)
            %CONVERT_TO_STRUCT Converts array as input into struct with
            %fields "x" and "y"

            arguments
                peaks double = [];
            end
            
            x = peaks(:,1);
            y = peaks(:,2);
            peaks = struct('x', num2cell(x(:)), 'y', num2cell(y(:)));
        end
    end



end
