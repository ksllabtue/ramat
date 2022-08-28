classdef (Abstract) DataItem < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    %DATAITEM Abstract parent class of all data items
    %   Subclasses are:
    %   PCAResult, ImageData, SpecData, SpecFilter, TextData, PeakTable,
    %   Mask
    
    properties
        name string;
        description string;
        parent_container {mustBeA(parent_container, 'Container')} = DataContainer.empty();
    end

    properties (Dependent)
        icon;
    end
    
    properties (Abstract, SetAccess = private)
        Type;
    end

    properties (SetAccess = private, GetAccess = private)
        format_list = "";
    end
        
    methods (Sealed)
        function append_sibling(self, new_data_item)
            %APPENDSIBLING Appends a new data item to parent data container
            %   Appends the new data item NEW_DATA_ITEM to the parent data
            %   container of SELF.
            %
            %   TO-DO: make it possible to append to array of DataItems

            arguments
                self
                new_data_item {mustBeA(new_data_item, 'DataItem')} = SpecData.empty();
            end

            if isempty(self.parent_container) || ~isvalid(self.parent_container)
                % Handle to deleted object?
                return
            end

            % Append DataItem
            self.parent_container.append_child(new_data_item);
            
        end


        function T = listItems(self)
            %LISTITEMS: brief overview
            
            T = self.totable();
            T = T(:, {'Type', 'Description'});
        end

        function T = totable(self)
            %TABLE Output data formatted as table
            %   This method overrides table() and replaces the need for
            %   struct2table()
            T = struct2table(struct(self));
            
        end
        
        function s = struct(self)
            %STRUCT Output data formatted as structure
            %   This method overrides struct()
            
            s = struct();
            for i = 1:numel(self)
                s(i).Type = self(i).Type;
                s(i).Description = self(i).Description;
                s(i).DataItem = self(i);
            end
            
        end

        function o = eq(a, b)
            %EQ Overloading equality operator "==" with Sealed = true, as
            %required for heterogeneous arrays in MATLAB
            o = eq@handle(a,b);
        end

        function format_list = get_export_formats(self)
            %GET_EXPORT_FORMATS Returns list of exportable formats.

            % If empty, return mat by default.
            if self.format_list == ""
                format_list = "mat";
                return;
            end

            % Retrieve formats
            format_list = self.format_list;
            
        end

    end

    methods
        function [ax, f] = plot(self, kwargs)
            % Get axes handle or create new figure window with empty axes

            arguments
                self;
                kwargs.Axes = [];
                kwargs.reset logical = true;
            end

            if isempty(kwargs.Axes)
                f = figure;
                ax = axes('Parent',f);
            else
                if ( class(kwargs.Axes) == "matlab.graphics.axis.Axes" || class(kwargs.Axes) == "matlab.ui.control.UIAxes")
                    ax = kwargs.Axes;
        
                    % Get figure parent, might not be direct parent of axes
                    f = get_parent_figure(ax);
                    
                    % Clear axes
                    if kwargs.reset, cla(ax, 'reset'); end
                else
                    warning("Invalid Axes Handle");
                    return;
                    
                end
            end
        end

        function [file, path] = export_ui_dialog(self, options)
            %EXPORT_UI_DIALOG Open ui dialog, presenting the user with the
            %available export options.

            arguments
                self {mustBeA(self, "DataItem")};
                options.path string = "";
                options.format string = "";
                options.format_list string = self.format_list;
            end

            format = options.format;
           
            if options.format == ""
                format = options.format_list;
            end

            % Get path filters, depending on the format.
            pathfilter = self.get_export_filter(format);

            % Show UI-put-file dialog
            [file, path] = uiputfile(pathfilter, 'Export Data Item');

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

            menu_item = uimenu(cm, ...
                Text="Remove",MenuSelectedFcn={@remove, self, node});

            function remove(~, ~, self, node)
                self.remove();
                update_node(node, "remove");
            end

        end

        function icon = get.icon(self)
            %ICON Default method to retrieve icon and make this a dependent
            %property. For overrides in subclasses, override the method
            %get_icon() instead. Do not change this property.
            icon = self.get_icon();
        end

        function icon = get_icon(self)
            %GET_ICON Default method to retrieve icon. Override this method
            %in subclasses to assign different icons for subclasses.

            icon = self.get_default_icon();
        end

        function remove(self)
            %REMOVE Soft Destructor

            self.parent_container.children(self.parent_container.children == self) = [];
            self.delete();

        end
        
    end

    % Operator overloading
    methods (Sealed)
        function r = op_start(varargin)
            %OP_START Checks whether operation can be performed.
            if nargin == 1
                a = varargin{1};
                assert(class(a) ~= "DataItem", 'OperatorAssertion:InhomogeneousOperands', "Can only operator on homogeneous arrays.")
            elseif nargin == 2
                a = varargin{1};
                b = varargin{2};
                assert(strcmp(class(a), class(b)), 'OperatorAssertion:InhomogeneousOperands', "Can only operate on two similar classes.");
            end
            
            % Create new instance of class
            r = feval( class(a) );
        end
    end

    methods (Static)
        function pathfilter = get_export_filter(format_list)
            %GET_EXPORT_FILTER Get list of possible export file types

            pathfilter = cell.empty(0,2);

            if any(format_list == "csv"), pathfilter = [pathfilter; {'*.csv;*.txt', 'Comma-separated values (*.csv,*.txt)'}]; end
            if any(format_list == "mat"), pathfilter = [pathfilter; {'*.mat', 'MAT-files (*.mat)'}]; end
            if any(format_list == "xlsx"), pathfilter = [pathfilter; {'*.xlsx', 'Excel Workbook (*.xlsx)'}]; end

            pathfilter = [pathfilter; {'*.*', 'All Files (*.*)'}];

        end

        function icon = get_default_icon()
            icon = "Default.png";
        end
    end
    
end

