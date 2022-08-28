classdef AnalysisGroup < handle
    %ANALYSISGROUP Analysis Group class which contains DataContainers
    %   These groups are used for grouping in plots and pca analysis
    
    properties (Access = public)
        name string = "";
        children Link;
        parent Analysis;
        parent_project Project;
    end
    
    properties (Access = public, Dependent)
        display_name string;
        prev AnalysisGroup;
        next AnalysisGroup;
        idx uint8;
    end
    
    methods
        function self = AnalysisGroup(parent, name, data)
            %CONSTRUCTOR

            arguments
                parent Analysis;
                name string = "";
                data DataContainer = DataContainer.empty;
            end

            self.parent = parent;

            if ~isempty(self.parent), self.parent_project = parent.parent; end

            self.name = name;
            self.append_data(data);
            
        end
        
        function append_data(self, data)
            %APPEND_DATA Append data to children of current analysis group
            %   data:   nx1 DataContainer

            arguments
                self AnalysisGroup;
                data {mustBeA(data, ["DataContainer", "Link"])};
            end

            if isempty(data), return; end

            % Convert to links
            if class(data(1)) == "DataContainer"
                % Only allow spectral data
                data(vertcat(data.dataType) ~= "SpecData") = [];
                
                datalinks = arrayfun(@(x) Link(x, self), data);
            else
                datalinks = data;
            end
            
            % Make sure parents are set correctly
            [datalinks.parent] = deal(self);

            % Append to list
            self.children = [self.children; datalinks];
            
        end
        
        function set.name(self, newname)
            self.name = newname;
        end
        
        function displayname = get.display_name(self)
            %DISPLAYNAME Format name nicely
            
            if (self.name == "")
                displayname = "Unnamed Analysis Group";
            else
                displayname = string( self.name );
            end
        end

        function s = struct(self, options)
            %STRUCT Output data formatted as structure
            %   This method overrides struct()
            %   Convert AnalysisGroups to struct containing references to
            %   the linked data containers.

            arguments
                self AnalysisGroup;
                options.selection logical = false;
                options.custom_selection DataContainer = DataContainer.empty;
                options.specdata logical = false;
                options.accumsize logical = false;
            end
            
            s = struct();
            
            % set defaults
            if options.specdata, s.specdata = []; end
            if options.accumsize, s.accumsize = []; end

            for i = 1:numel(self)
                s(i).name = self(i).display_name;

                % Filter selection only
                if options.selection
                    s(i).children = intersect(self(i).children, self(i).parent.Selection);
                elseif ~isempty(options.custom_selection)
                    s(i).children = intersect(self(i).children, options.custom_selection);
                else
                    s(i).children = self(i).children;
                end

                % Get children link targets: datacontainers
                s(i).children = vertcat(s(i).children.target);
                if isempty(s(i).children), continue; end

                % Get handles to data items (SpecData) instead of
                % containers
                if options.specdata
                    s(i).specdata = s(i).children.getDataHandles("SpecData");
                end

                % Get accumulated sizes
                if (options.specdata && options.accumsize)
                    s(i).accumsize = sum([s(i).specdata.DataSize]);
                end

            end
            
        end

        function l = get_static_list(self, opts)
            %GET_STATIC_LIST Get list of simple specdats

            arguments
                self
                opts.selection Link = self.children;
            end

            links = opts.selection;

            dc = vertcat(links.target);
            specdats = vertcat(dc.getDataHandles("SpecData"));
            l = specdats.get_spectrum_simple();
        end

        function remove(self)
            %REMOVE Soft Destructor

            % Delete all children links
            if ~isempty(self.children), self.children.remove(); end

            % Unset at parent
            self.parent.GroupSet(self.parent.GroupSet == self) = [];

            % Destruct
            self.delete();

        end
        
    end

    % Methods for indexing and restructuring
    methods
        function idx = get.idx(self)
            %IDX Get index of group
            if isempty(self.parent), return; end
            idx = find(self == self.parent.GroupSet);
        end

        function prev = get.prev(self)
            %PREV Get previous sibling

            prev = [];
            if isempty(self.parent), return; end
            if self.idx == 1, return; end

            prev = self.parent.children(self.idx - 1);
        end

        function next = get.next(self)
            %PREV Get next sibling

            next = [];
            if isempty(self.parent), return; end
            if self.idx == numel(self.parent.children), return; end

            next = self.parent.children(self.idx + 1);
        end

        function moveup(self)
            %MOVEUP Move group up one place

            % Cannot move up from 1st place
            if self.idx == 1, return; end

            % Move by swapping with previous sibling
            swapidx = [self.idx - 1, self.idx];
            self.parent.GroupSet(swapidx) = self.parent.GroupSet(fliplr(swapidx));
        end

        function movedown(self)
            %MOVEUP Move group down one place
            
            % Cannot move down from last place
            if self.idx == numel(self.parent.GroupSet), return; end

            % Move by swapping with previous sibling
            swapidx = [self.idx + 1, self.idx];
            self.parent.GroupSet(swapidx) = self.parent.GroupSet(fliplr(swapidx));
        end
    end
end

