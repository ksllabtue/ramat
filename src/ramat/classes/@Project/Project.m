classdef Project < handle
    %PROJECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name string = "";
        analyses Analysis = Analysis.empty;
    end

    properties (Dependent)
        data_root Group;
        analysis_result_root Group;
    end

    properties (Access = private)
        root Group = Group.empty;
    end

    properties
        DataSet = DataContainer.empty;
        GroupSet = Group.empty;
        ActiveAnalysis = Analysis.empty;
        ActiveAnalysisResult = AnalysisResult.empty;
    end
    
    methods
        function self = Project(name)
            %PROJECT Constructor

            arguments
                name string = "Unnamed project"
            end

            self.name = name;

            % Create root groups
            self.root = Group(self, "Root");
            self.root.add_child_group("Data Root");
            self.root.add_child_group("Analysis_Result_Root");
        end

        function append_data(self, dataset, group)
            %APPEND_DATA:
            %   Appends a dataset (set of DataContainer) to the project,
            %   e.g after importing data
            %

            arguments
                self Project;
                dataset DataContainer;
                group = Group.empty();
            end

            % Assign parent project
            [dataset.parent_project] = deal(self);
           
            % Create a new group for the newly appended data if group does
            % not exist or is empty
            if isempty(group)
                root_folder = self.data_root;
                group = root_folder.add_child_group("New Import");
            end

            % Add children to this group
            group.add_children(dataset);

            self.DataSet = [self.DataSet; dataset];
        end
        
        function new_group = add_group(self, groupname, parent)
            %ADD_GROUP

            arguments
                self Project;
                groupname string = "";
                parent Group = Group.empty;
            end

            % Always make sure the new group is added to the root
            if isempty(parent)
                parent = self.data_root;
            end
            
            new_group = parent.add_child_group(groupname);
            self.GroupSet(end + 1) = new_group;
            
        end
        
        function newAnalysisHandle = add_analysis(self, dataset)
            %ADD_ANALYSIS
            %   Add a new data subset for analysis
            %   Returns:    handle to new analysis subset
            
            newAnalysisHandle = Analysis(self, dataset);
            self.analyses = [self.analyses; newAnalysisHandle];
        end
        
        function result = create_pca(self, options)
            %CREATE_PCA Create new PCA analysis
            
            arguments
                self Project
                options.Range = [];
                options.Selection (:,:) DataContainer = DataContainer.empty;
                options.algorithm string = "svd";
            end

            result = [];

            % Checks
            if isempty(self.analyses)
                return;
            end
            if isempty(self.ActiveAnalysis)
                return;
            end
            
            % Create PCA
            subset = self.ActiveAnalysis;
            pcaresult = subset.compute_pca(Range=options.Range, Selection=options.Selection, algorithm=options.algorithm);
            if isempty(pcaresult), return; end

            % Pack in container
            result = AnalysisResultContainer(self);
            result.append_child(pcaresult);
            result.name = pcaresult.name;
            
        end
        
        function add_analysis_result(self, newresult, group)
            %ADD_ANALYSIS_RESULT

            arguments
                self Project;
                newresult AnalysisResultContainer;
                group Group = Group.empty();
            end

            % Set target group
            if isempty(group)
                group = self.analysis_result_root;
            end
            
            % Append analysis result
            group.add_children(newresult);

        end
        
    end

    methods
        % Get root groups

        function root = get.data_root(self)
            root = self.root.child_groups(1);
        end

        function root = get.analysis_result_root(self)
            root = self.root.child_groups(2);
        end

        function pcar = get_active_pca_result(self)

            pcar = [];
            if isempty(self.ActiveAnalysisResult), return; end
            if isempty(self.ActiveAnalysisResult.data), return; end
            if class(self.ActiveAnalysisResult.data) ~= "PCAResult", return; end

            pcar = self.ActiveAnalysisResult.data;
        end
        
    end
end

