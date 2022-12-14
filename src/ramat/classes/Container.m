classdef (Abstract) Container < handle
    %CONTAINER Abstract parent class of DataContainer and
    %AnalysisResultContainer
    %   Can contain DataItems that are part of a measurement or an analysis
    %   result.

    properties
        name string;
        parent Group;
        parent_project Project;
        children {mustBeA(children, "DataItem")} = SpecData.empty();
        meta struct = struct.empty();
    end

    properties (Dependent)
        display_name string;
        icon string;
        prev Container;
        next Container;
    end

    properties (Abstract, Dependent)
        dataType string;
    end

    methods (Sealed)
        function append_child(self, data_items)
            %APPENDCHILD
            %   Appends DataItem object to list of data items
            %   It can also append multiple DataItems objects to multiple
            %   DataContainer objects if the number of instances is equal.

            arguments
                self {mustBeA(self, "Container")};
                data_items {mustBeA(data_items, "DataItem")};
            end
            
            num_data_items = numel(data_items);
            num_self = numel(self);
        
            % Input sanitazation
            
            if ~(num_self == 1 || num_data_items == 1 || num_data_items == num_self)
                % The number of SpecData objects cannot be unambigeously
                % appended to the corresponding DataContainer instances.
                return
            end
        
            % Implementation
        
            if num_self == 1
                % Append new data item(s) to single Container
                for item = data_items
                    item.parent_container = self;
                    self.children(end+1) = item;
                end
            
            else
                % Append new data item(s) to multiple Containers
        
                if num_data_items == 1
                    % Distribute single data item to multiple Containers
                    for container = self
                        data_items.parent_container = container;
                        container.children(end + 1) = data_items;
                    end
        
                else
                    % Multiple DataItems to multiple DataContainers (1 to
                    % 1)
                    for i = 1 : num_self
                        new_item = data_items(i);
                        container = self(i);
        
                        new_item.parent_container = container;
                        container.children(end + 1) = new_item;
                    end
        
                end
            end
        
        end

        function move_to_group(self, new_group, parent_group)
            %MOVE_TO_GROUP Moves container to new group
            %

            arguments
                self Container;
                new_group Group = Group.empty();
                parent_group Group = Group.empty();
            end

            % Check if new group is singular
            if numel(new_group) > 1
                warning('Cannot move to multiple groups at once');
                return;
            end

            % New group is invalid (i.e. deleted)
            if ~isvalid(new_group)
                warning('Reference to deleted group');
                return
            end

            % Move to a new group
            % Create new group when no group is given. Retrieve from first self.
            if isempty(new_group)
                new_group = self(1).parent_project.add_group("New Group", parent_group);
            end

            % Remove from old group
            for i = 1:numel(self)
                self(i).parent.remove_child(self(i));
            end

            % Add to new group and set new group
            new_group.add_children(self);

        end

        function setgroup(self, group)
            %SETGROUP Set parent group

            arguments
                self;
                group Group;
            end

            for i = 1:numel(self)
                self(i).parent = group;
            end
            
        end

        function bool = is_homogeneous_array(self)
            %IS_HOMOGENEOUS_ARRAY Checks whether an array of DataContainers
            %contain Data of the same class. Returns a boolean
            %(MATLAB: logical).
            bool = all(self(1).dataType == vertcat(self.dataType));
        end

        function parents = get_parent_groups(self, opts)
            %GET_PARENT_GROUPS Return parent groups
            %   Return an array of (unique) parent groups, n levels up.
            %
            %   Usage:
            %       [containers].get_parent_groups(unique=true, level=2)
            %       returns a unique array of parents, 2 levels up.

            arguments
                self;
                opts.unique = true;
                opts.level = 1;
            end

            % Iterate over levels
            for i = 1:opts.level
                % Reached the end?
                if any(isempty([self.parent])), return; end
                if any(isa([self.parent], "Project")), return; end

                % Retrieve parents
                parents = [self.parent];
                if opts.unique, parents = unique(parents); end
                self = parents;
            end

        end

%         function result = is_a_parent(self, group, opts)
%             %IS_A_PARENT Returns whether a given group is a (higher-level)
%             %parent of the given containers
% 
%             arguments
%                 self;
%                 group Group;
%                 opts.limit = 10;
%             end
% 
%             for i = 1:opts.limit
%                 % Reached the end?
%                 if any(isempty([self.parent])), return; end
%                 if any(isa([self.parent], "Project")), return; end
% 
%             end
% 
%         end



    end

    methods

        function set.name(self, newname)
            %NAME Setter

            % Set name of container
            self.name = newname;

            % Also set name of data item
            dat = self.get_data();
            if isempty(dat), return; end
            dat.name = newname;
            
        end

        function data = get_data(self)
            %GET_DATA Returns handle to main data.

            data = [];

        end

        function set_meta(self, field, value)
            %SET_META

            assert(field ~= "name", "Naming field 'name' is not allowed.");
            assert(field ~= "id", "Naming field 'id' is not allowed.");

            for s = self(:)'
                s.meta(1).(field) = value;
            end
        end

        function out = get_meta(self, field, options)
            %GET_META
            arguments
                self
                field string = "";
                options.as_table logical = false;
            end

            out = {};

            for i = 1:numel(self)
                if ~isfield(self(i).meta, field)
                    out{i} = [];
                    continue;
                end

                % Add output
                out{i} = self(i).meta.(field);
            end


            % Is homogeneous?
            celltype = cellfun(@(x) string(class(x)),out);
            if ~all(celltype(1) == celltype), return; end

            % Homogenize output
            out = cell2mat(out);
            out = out(:);
        end

        function t = get_meta_table(self)

            meta_s = self(1).meta;
            meta_s(1).name = self(1).display_name;
            meta_s(1).id = 1;
            t = struct2table(meta_s);
           
            
            if numel(self) == 1, return; end

            for i = 2:numel(self)
                meta_s = self(i).meta;
                meta_s(1).name = self(i).display_name;
                meta_s(1).id = i;
                t2 = struct2table(meta_s);
                t = outerjoin(t,t2,MergeKeys=true);
            end

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

            % Dump to workspace
            uimenu(cm, Text="Dump to Workspace", Callback={@DumptoWorkspaceSelected, app})

            % Remove
            uimenu(cm, Text="Remove", MenuSelectedFcn={@remove, self, node});

            function remove(~, ~, self, node)
                self.remove();
                update_node(node, "remove");
            end

            function DumptoWorkspaceSelected(~, ~, app)
                % User has selected <DUMP TO WORKSPACE>
                dump_selection(app.selected_datacontainers);
            end

        end
    end

    % Builtin overrides
    methods
        function t = table(self)
            %TABLE Output data formatted as table
            %   This method overrides table() and replaces the need for
            %   struct2table()
            
            t = struct2table(struct(self));
            
        end
        
        function s = struct(self)
            %STRUCT Output data formatted as structure
            %   This method overrides struct()
            
            publicProperties = properties(self);
            s = struct();
            for i = 1:numel(self)
                for j = 1:numel(publicProperties)
                    if strcmp(publicProperties{j}, 'Group') && ~isempty(self(i).Group)
                        s(i).(publicProperties{j}) = self(i).(publicProperties{j}).Name;
                    else
                        s(i).(publicProperties{j}) = self(i).(publicProperties{j}); 
                    end
                end 
            end 
        end

        % soft destructor
        function remove(self)
            %REMOVE soft destructor

            for i = 1:numel(self)
                self(i).children.delete();
                self(i).parent.children(self(i).parent.children == self(i)) = [];
                self(i).parent_project.DataSet(self(i).parent_project.DataSet == self(i)) = [];

                self(i).delete();
            end

        end        
    end

    % Getters (dependent properties)
    methods
        function display_name = get.display_name(self)
            %DISPLAY_NAME Readable display name

            display_name = self.name;

            if display_name == ""
                display_name = sprintf("unnamed %s", class(self));
            end

        end

        function prev = get.prev(self)
            %PREV Get previous sibling

            prev = [];

            if isempty(self.parent)
                return;
            end

            % Find itself in the list of children
            idx = find(self == self.parent.children);

            if idx == 1
                return;
            else
                prev = self.parent.children(idx - 1);
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

        function next = get.next(self)
            %PREV Get previous sibling

            next = [];

            if isempty(self.parent)
                return;
            end

            % Find itself in the list of children
            idx = find(self == self.parent.children);

            if idx == numel(self.parent.children)
                return;
            else
                next = self.parent.children(idx + 1);
            end

        end


    end

    methods (Static)

        function icon = get_default_icon()
            icon = "Default.png";
        end

    end
end