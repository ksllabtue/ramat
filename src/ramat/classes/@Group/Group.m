classdef Group < handle
    %GROUP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        name string = "";
        parent {mustBeA(parent, ["Group", "Project"])} = Group.empty();
        children {mustBeA(children, "Container")} = DataContainer.empty();
        child_groups Group;
        icon string = "Folder_24.png";
    end
    
    properties (Access = public, Dependent)
        display_name;
        parent_project;
    end
           
    methods
        function self = Group(parent, name)
            %GROUP Construct an instance of this class
            %   Detailed explanation goes here

            arguments
                parent {mustBeA(parent, ["Group", "Project"])} = Group.empty();
                name string = "";
            end

            if isempty(parent)
                warning("New group must have a parent.");
                return;
            end
            
            self.parent = parent;
            self.name = name;
            
        end

        function add_children(self, children)
            %ADD_CHILDREN Adds children containers and sets their group
            %
            %   Usage:
            %   add_children(group, child_arr)

            arguments
                self Group;
                children {mustBeA(children, "Container")} = DataContainer.empty();
            end

            % Set children type
            if isempty(self.children)
                self.children = children;
                children.setgroup(self);
                return;
            end

            % Append to list of children
            self.children = [self.children; children];

            % Set group
            children.setgroup(self);

        end

        function remove_child(self, dataset)
            %REMOVE_CHILD Deletes child
            %   Checks if dataset is part of children and removes it from
            %   the list of children

            arguments
                self Group;
                dataset DataContainer;
            end

            % Unset the corresponding children
            idx = find(dataset == self.children);
            self.children(idx) = [];

        end

        function group = add_child_group(self, name)
            %ADD_CHILD_GROUP Adds a lower level group

            arguments
                self Group;
                name string = "New Group";
            end

            group = Group(self, name);
            self.child_groups(end + 1) = group;
            
        end
        
        
        function specplot(self, stacked)
            % SPECPLOT

            warning("Group.specplot() is deprecated.");
            
            fig = figure;
            hold on
            
            for i = 1:numel(self)
                % For every instance of Group()
                
                % Get handles of all instances of DataContainer() within
                % the current instance Group() that contain spectral data.
                h = self(i).children.getDataHandles('SpecData');
                
                xdata = [];
                ydata = [];
                
                if ~isempty(h)
                    % TO-DO: implement a check for uniform GRAPHDATA
                    xdata = h(1).Graph;
                    ydata = mean( horzcat( h.FlatDataArray ), 2, 'omitnan');
                    
                    if nargin>1
                        if stacked == 1
                            ydata = ydata - 0.01 .* (mod(i,2) - 1);
                        end
                    end
                    
                end
                
                plot(xdata, ydata);
                                
            end
            
            legend({self.name}');
            
        end

        function parent_prj = get.parent_project(self)
            %PARENT_PROJECT is the top-level parent
            parent_prj = get_parent_project(self);
        end

        function display_name = get.display_name(self)
            %DISPLAY_NAME Makes sure that displayed name is not empty

            display_name = self.name;

            if display_name == ""
                display_name = sprintf("Unnamed %s", class(self));
            end
        end
        
        function remove(selfs)
            %REMOVE Soft Destructor
            
            for self = selfs(:)'
                % Do not remove root groups
                if class(self.parent.parent) == "Project", return; end
    
                if ~isempty(self.child_groups), self.child_groups.remove(); end
                if ~isempty(self.children), self.children.remove(); end
                self.parent.child_groups(self.parent.child_groups == self) = [];
                self.delete();
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

            selection = vertcat(app.DataMgrTree.SelectedNodes.NodeData);

            % Add "add to analysis set" menu nodes
            node_add_to = uimenu(cm, 'Text', 'Add to Analysis Set ...');
            uimenu(node_add_to, ...
                'Text', '<New Analysis>', ...
                'Callback', @(~,~) add_to_analysis(app, selection, Analysis.empty));

            % Populate sub menu with all available analysis sets
            for analysis = app.prj.analyses(:)'
                name = analysis.display_name;
                uimenu(node_add_to, ...
                    'Text', name, ...       % Name of analysis subset
                    'Callback', @(~,~) add_to_analysis(app, selection, analysis)); 
            end

            % Create new group
            uimenu(cm, Text="Create new group", Callback=@(~,~) add_group(self, node, app))

            % Dump to workspace
            uimenu(cm, Text="Dump to Workspace", Callback={@DumptoWorkspaceSelected, app})

            % Remove
            uimenu(cm, Text="Remove", MenuSelectedFcn={@remove, self, node});

            % Nested functions
            function add_to_analysis(app, selection, analysis)
                % User has selected <ADD TO ANALYSIS>           
                selection.add_to_analysis(analysis);
                
                % Update GUI Managers
                app.updatemgr(Parts=[2, 3]);
            end

            function add_group(self, node, app)
                new_group = self.add_child_group();
                gen_child_nodes(node, new_group, app);
            end

            function remove(~, ~, self, node)
                self.remove();
                update_node(node, "remove");
            end

            function DumptoWorkspaceSelected(~, ~, app)
                % User has selected <DUMP TO WORKSPACE>
                dump_selection(app.selected_datacontainers);
            end

        end

        function analysis = add_to_analysis(self, analysis)
            
            arguments
                self Group;
                analysis Analysis = Analysis.empty();
            end

            prj = self(1).parent_project;

            if isempty(analysis)
                analysis = prj.add_analysis();
            end

            analysis.append_data(self);

        end

        function dataset = get_all_data(self)

            dataset = DataContainer.empty();

            for group = self.child_groups(:)'
                all_child_data = group.get_all_data();
                dataset = [dataset(:); all_child_data(:)];
            end

            dataset = [dataset(:); self.children];
        end
        
        function t = table(self)
            %TABLE Output data formatted as table
            %   This method overrides table() and replaces the need for
            %   struct2table()
            
            t = struct2table(struct(self), 'AsArray', true);
            
        end
        
        function s = struct(self)
            %STRUCT Output data formatted as structure
            %   This method overrides struct()
            
            publicProperties = properties(self);
            s = struct();
            for i = 1:numel(self)
                for j = 1:numel(publicProperties)
                    s(i).(publicProperties{j}) = self(i).(publicProperties{j}); 
                end 
            end
        end


        
    end
end

