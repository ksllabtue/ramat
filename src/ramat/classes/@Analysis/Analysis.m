classdef Analysis < handle
    %ANALYSIS Analysis subset used for PCA Analysis
    %   Detailed explanation goes here
    
    properties (Access = public)
        name string = "";
        parent Project = Project.empty;
        GroupSet = AnalysisGroup.empty;
        Selection Link = Link.empty;
    end

    properties (Access = public, Dependent)
        display_name;
        DataSet; % Set of all DataContainers
        samples; % Set of all samples or replicates
        unique_samples;
    end

    methods
        pcaresult = compute_pca(self, options);
        tsneresult = compute_tsne(self, options);
    end
    
    methods
        function self = Analysis(parent_project, dataset, name)
            %CONSTRUCTOR

            arguments
                parent_project Project;
                dataset DataContainer;
                name string = "";
            end

            self.parent = parent_project;
            self.append_data(dataset);
            self.name = name;

        end
        
        function append_data(self, dataset, new_group_name, opts)
            %APPEND_DATA Appends new data to the current analysis. This
            %function will also take care of the grouping within the
            %analysis
            %
            %   Usage:
            %       [analysis].append_data(dataset) will append data based
            %       on parent groups of dataset
            %
            %       [analysis].append_data(dataset, "group A") will append
            %       all data to analysis group called "group A"
            %       irrespective of the original parent groups of the
            %       dataset

            arguments
                self Analysis;
                dataset {mustBeA(dataset, ["Group", "DataContainer"])};
                new_group_name string = "";
                opts.level = 1;
            end

            if isempty(dataset), return; end

            % If groups are given, distribute according to provided groups
            if isa(dataset, "Group")
                for group = dataset(:)'
                    analysis_group = self.add_group(group.name);

                    group_data = group.get_all_data();
                    analysis_group.append_data(group_data);
                end
                return;
            end

            % If group name is given, use this name
            if new_group_name ~= ""
                newgroup = self.add_group(new_group_name);
                newgroup.append_data(dataset);
                return;
            end

            % If groups are not given, infer from parent Group
            parent_groups = dataset.get_parent_groups(unique=true, level=opts.level);

            for group = parent_groups(:)'
                % Create group
                newgroup = self.add_group(group.name);

                % Append data belonging to that group
                group_dataset = dataset([dataset.parent] == group);
                newgroup.append_data(group_dataset);
            end
            
        end
                
        function set_name(self, name)
            self.name = name;
        end
        
        function displayname = get.display_name(self)
            %DISPLAY_NAME Get formatted name

            if (self.name == "")
                displayname = "Unnamed Analysis Subset";
            else
                displayname = self.name;
            end

        end
        
        function newgroup = add_group(self, name)
            %ADD_GROUP Add analysis group to current analysis subset

            arguments
                self Analysis;
                name string = "";
            end
            
            newgroup = AnalysisGroup(self, name);
            
            % Add new group to group set.
            self.GroupSet = [self.GroupSet; newgroup];
            
        end
        
        function move_data_to_group(self, dataset, newgroup)
            %MOVE_DATA_TO_GROUP Moves data to an analysis group by
            %DataContainer handle
            %   This function will move ALL instances of the DataContainer
            %   to a single group.
            
            for i = 1:numel(dataset)
                % For every datacontainer that has to be moved
                
                datacon = dataset(i);
                
                % Step 1: Remove data from old group(s)
                                
                % Remove occurences of the datacontainer in unassigned
                % dataset.
%                 self.DataSet(self.DataSet == datacon) = [];
                
                % Check all the groups
                for g = 1:numel(self.GroupSet)
                    % Find occurences of the datacontainer in this group's
                    % children and remove the occurences
                    
                    group = self.GroupSet(g);
                    group.children(datacon == group.children) = [];
                    
                end
                
                % Step 2: Assign data to new group
                newgroup.append_data(datacon);
            end
            
        end

        function auto_assign_samples(self)
            %AUTO_ASSIGN_SAMPLES Automatically assign samples based on the
            %parent group in the project.

            for link = self.DataSet(:)'
                link.assign_sample(link.target.parent.display_name);
            end
            
        end
        
        function dataset = get.DataSet(self)
            %DATASET Ungrouped list of datacontainers of this analysis
            %subset.
            
            dataset = Link.empty;
            
            for i = 1:numel(self.GroupSet)
                % Look for data in each group
                
                group = self.GroupSet(i);
                
                for j = 1:numel(group.children)
                    dc = group.children(j);
                    
                    dataset = [dataset; dc];
                    
                end
            end
            
        end

        function samples = get.samples(self)
            %SAMPLES Gets list of samples

            samples = categorical(vertcat(self.DataSet.sample));

            % Remove empty sample names
            samples(isundefined(samples)) = [];
        end

        function samples = get.unique_samples(self)
            samples = unique(self.samples);
        end

        function sample_indices = get_unique_sample_indices(self)
            sample_indices = Analysis.get_unique_indices(self.samples);
        end
        
        function plot(self, options)
            %PLOT
            
            arguments
                self
                options.Selection = self.DataSet;
            end
            
            data = options.Selection;

            specplot = SpecPlot(data, self.parent);
                        
            SpectralPlotEditor(specplot);
            
        end

        function gen_specplot(self, options)


        end
        
        
        function set_selection(self, selection)
            %SELECTION Update the list of selected data containers
            %   Input:
            %   selection:  can be either list of datacontainers or of GUI
            %   tree nodes
            
            links = Link.empty();
            
            % Type-Based
            switch class(selection)
                case "matlab.ui.container.TreeNode"
                    % Tree nodes provided
                    
                    % Only include nodes that contain data
                    for i=1:numel(selection)
                        if class(selection(i).NodeData) == "Link"
                            links(end+1) = selection(i).NodeData;
                        end
                    end
                    
                case "Link"
                    % Actual datacontainers provided
                    
                    links = selection;
                    
            end
            
            % Check whether provided selection actually only contains
            % elements that are present in this analysis
            links = intersect(self.DataSet, links);
            
            % Update Selection
            self.Selection = links;
            
        end

        function disp(self)
            %PRINT Print info to terminal

            for analysis = self(:)'
                fprintf("\n");
                fprintf("Analysis Name: " + analysis.name + "\n");
                disp(struct2table(analysis.struct()));
            end
            
        end

        function s = struct(self, options)
            %STRUCT Output data formatted as structure
            %   This method overrides struct()
            %   Create struct, calls struct method of AnalysisGroup

            arguments
                self Analysis;
                options.selection logical = false;
                options.specdata logical = false;
                options.accumsize logical = false;
            end

            options = unpack(options);                        
            s = self.GroupSet.struct(options{:});

        end

        function get_data_table(self)
            %GET_DATA_TABLE

            

        end

        %% Destructor
        
        function delete(self)
            %DESTRUCTOR Delete all references to object

            fprintf("Deleting %s...", self.display_name);
           
            % Delete references at parent
            prj = self.parent;
            
            if ~isvalid(prj)
                % Program is probably closing, prj hasn't been found
                % Skip checks
                return
                
            end

            % Delete all analysis groups (children)
            for i = 1:numel(self.GroupSet)
                if isvalid(self.GroupSet(i))
                    delete(self.GroupSet(i));
                end
            end
            
            % Remove itself from the dataset
            idx = find(self == prj.AnalysisSet);
            prj.AnalysisSet(idx) = [];

            fprintf(" (%d analysis groups have been removed as well)\n", i);

        end
            
    end

    methods (Static)
        function idx = get_unique_indices(samples)
            % Return unique indices of samples

            [~, ~, idx] = unique(samples);
        end

    end
end

