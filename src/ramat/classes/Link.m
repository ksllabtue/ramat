classdef Link < handle & matlab.mixin.indexing.RedefinesDot & matlab.mixin.Copyable
    %LINK Links analysis element to datacontainer
    %   This class will link to one or more DataContainers. All calls (dot
    %   references) will be forwarded. It adds three methods: moveup,
    %   movedown, and remove().

    properties
        target DataContainer = DataContainer.empty;
        parent AnalysisGroup = AnalysisGroup.empty;
        name string;
        selected logical = true;
        sample = "";
    end

    properties (Dependent)
        display_name string;
        icon;
    end

    % Cached properties, in case target gets deleted.
    properties (Access = private)
        cached_display_name string;
    end

    properties (Dependent)
        idx uint8;
    end

    methods
        function self = Link(target, parent)
            %LINK Construct an instance of this class (Link)
            
            self.target = target;
            self.parent = parent;

            self.cached_display_name = target.display_name;
        end
    end

    methods (Access=protected)
        % Forward dot reference
        % Python-equivalent: __call__ method
        function varargout = dotReference(self,indexOp)
            [varargout{1:nargout}] = self.target.(indexOp);
        end

        function self = dotAssign(self,indexOp,varargin)
            [self.target.(indexOp)] = varargin{:};
        end
        
        function n = dotListLength(self,indexOp,indexContext)
            
            % Strategy when target has been deleted
            if ~isempty(self.target)
                if ~isvalid(self.target)
                    self.target = DataContainer.empty();
                else
                    self.cached_display_name = self.target.display_name;
                end
            end

            n = listLength(self.target,indexOp,indexContext);
        end
    end

    methods
        function assign_sample(self, sample, options)
            %ASSIGN_SAMPLE

            arguments
                self Link;
                sample string;
                options.askinput logical = false;
            end

            if options.askinput, sample = Link.askinput(); end

            [self.sample] = deal(sample);
        end

        function displayname = get.display_name(self)
            %DISPLAY_NAME Constructs display name

            if isempty(self.target), self.get_deleted_name(); return; end
            if ~isvalid(self.target), self.get_deleted_name(); return; end

            if self.name ~= ""
                displayname = self.name;
                return;
            end

            displayname = self.target.display_name;
            self.cached_display_name = self.target.display_name;

        end

        function icon = get.icon(self)

            if self.selected
                icon = self.target.icon;
            else
                icon = "cross-12.png";
            end

        end

        function descname = get_descriptive_name(self)
            %GET_DESCRIPTIVE_NAME Constructs descriptive name including
            %sample name

            descname = self.get_sample_display_name + " " + self.display_name;
        end

        function displayname = get_deleted_name(self)

            displayname = "(DELETED) " + self.cached_display_name;
            
        end

        function sample_name = get_sample_display_name(self)
            %GET_SAMPLE_DISPLAY_NAME
            
            sample_name = self.sample;

            if sample_name == ""
                sample_name = "unnamed";
            end

            % Enclose
            sample_name = "(" + sample_name + ")";
        end

        function deselect(self)
            %DESELECT Unselect links
            [self.selected] = deal(false);
        end

        function select(self)
            %SELECT Select links
            [self.selected] = deal(true);
        end

        function idx = get.idx(self)
            %IDX Get index of group
            if isempty(self.parent), return; end
            idx = find(self == self.parent.children);
        end

        function moveup(self)
            %MOVEUP Move group up one place

            % Cannot move up from 1st place
            if self.idx == 1, return; end

            % Move by swapping with previous sibling
            swapidx = [self.idx - 1, self.idx];
            self.parent.children(swapidx) = self.parent.children(fliplr(swapidx));
        end

        function movedown(self)
            %MOVEDOWN Move group down one place
            
            % Cannot move down from last place
            if self.idx == numel(self.parent.children), return; end

            % Move by swapping with previous sibling
            swapidx = [self.idx + 1, self.idx];
            self.parent.children(swapidx) = self.parent.children(fliplr(swapidx));
        end

        function remove(self)
            %REMOVE Soft Destructor

            % Unset at parent
            self.parent.children(self.parent.children == self) = [];

            % Destruct
            self.delete();

        end

    end

    % Context menu methods
    methods
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

            % Get analysis.
            analysis = self.parent.parent;
            if isempty(analysis), return; end

            % Get Selection
            selection = vertcat(app.AnalysisMgrTree.SelectedNodes.NodeData);
            selected_nodes = vertcat(app.AnalysisMgrTree.SelectedNodes);

            % Create menu for group assignment
            uimenu(cm, ...
                'Text', 'Assign to New Group', ...
                'Callback', {@assign_to, self, analysis, [], app});
            
            if numel(analysis.GroupSet) > 0
                % The active analysis subset has groups
                mh = uimenu(cm, 'Text', 'Assign to ...');
                
                % Create menus for every group in the analysis
                for group = analysis.GroupSet(:)'
                    uimenu(mh, 'Text', group.display_name, 'Callback', {@assign_to, selection, analysis, group, app}); 
                end
            end

            % Create menu for sample assignment
            mh = uimenu(cm, Text="Assign sample/replicate ...");

            % To new sample
            uimenu(mh, Text="<New Sample/Replicate>", Callback = @(~,~) assign_to_sample(selection, selected_nodes, "", true));

            % To existing samples
            for sampl = analysis.unique_samples(:)'
                uimenu(mh, ...
                    Text = string(sampl), ...
                    Callback = @(~,~) assign_to_sample(selection, selected_nodes, string(sampl), false));
            end

            uimenu(cm, Text = "Select", MenuSelectedFcn={@select, selection, selected_nodes});
            uimenu(cm, Text = "Deselect", MenuSelectedFcn={@deselect, selection, selected_nodes});
            
            uimenu(cm, Text = "Move up", MenuSelectedFcn={@moveup, selection, node});
            uimenu(cm, Text = "Move down", MenuSelectedFcn={@movedown, selection, node});
            uimenu(cm, Text = "Remove", MenuSelectedFcn = {@remove, selection, node});

            function select(~,~,self,node)
                self.select();
                update_node(node, "icon");
            end

            function deselect(~,~,self,node)
                self.deselect();
                update_node(node, "icon");
            end

            function moveup(~,~,self,node)
                self.moveup();
                update_node(node, "moveup");
            end

            function movedown(~,~,self,node)
                self.movedown();
                update_node(node, "movedown");
            end

            function remove(~, ~, self, node)
                % User has selected <REMOVE>
                self.remove();
                update_node(node, "remove");
            end

            % Menu selected function: AddtoMenu
            function assign_to(~, ~, self, analysis, newgroup, app)
                % User has selected <ASSIGN TO ...>
                if isempty(newgroup)
                    newgroup = analysis.add_group();
                end

                analysis.move_data_to_group(self, newgroup);
                
                % Update GUI Managers
                app.updatemgr(Parts=3);
            end

            function assign_to_sample(self, node, newsample, askinput)
                % Ask for user input
                if askinput, newsample = Link.askinput(); end

                % Assign
                self.assign_sample(newsample);

                % Update nodes in GUI
                update_node(node, "descriptive_name");
            end

        end
    end

    methods (Static)
        function samplename = askinput()
            %Ask prompt
            prompt = {'Enter name of the sample or replicate:'};
            dlgtitle = 'Add sample / replicate';
            dims = [1 70];
            definput = {''};
            answer = inputdlg(prompt,dlgtitle,dims,definput);

            samplename = string(answer{1});
        end
    end
end