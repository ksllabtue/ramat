classdef DataContainer < Container
    %DATACONTAINER Class
    %   Parent Class: Container
    %
    %   This object class contains all data objects belonging to a single
    %   measurement. It can contain multiple Data Items (e.g. SpecData
    %   Instances)
    %
    %   Properties inherited from parent class "Container"
    %       name            string
    %       parent          Group
    %       parent_project  Project
    %       children        DataItem
    %       dataType        string
    
    properties (Access = public) % deprecated
        Name;
        selected;
        Group = Group.empty();
        DataItems = DataItem.empty;
        ProjectParent;
        ActiveFilter = SpecFilter.empty;
    end
    
    properties (Access = public, Dependent)
        Data        % This will always be the handle to the last/active data item in DataItems
        dataType;
        
        Graph;
        DataPreview;
        
        XSize;
        YSize;
        DataSize;
        
        AnalysisGroupParent = AnalysisGroup.empty;
        
        DisplayName;
        
        Filter = SpecFilter.empty;
        FilterOutput;
    end


    % Method signatures
    methods (Access = public)
        trimData(self, startx, endx, overwrite);    % should go to data item level
        normalizeData(self, overwrite);             % should go to data item level
        subsetHandle = add_to_new_subet(self);
        add_to_subset(self, subsetHandle);
        ax = plot(self, kwargs);
        appendDataItem(self, data_item);
    end

    methods
        function self = DataContainer(name, parent_prj, data_items)
            %DATACONTAINER Construct an instance of this class

            arguments
                name string = "";
                parent_prj Project = Project.empty();
                data_items {mustBeA(data_items, "DataItem")} = SpecData.empty();
            end

            self.name = name;
            self.parent_project = parent_prj;
            
            if ~isempty(data_items)
                self.append_data_item(data_items);
            end
            
        end
        
        function h = get.Data(self)
            % Return handle for the last/active data item
            
            if numel(self.DataItems)    
                % Container contains data items, return last one of
                % following types: SpecData, ImageData, TextData
                dataitemtypes = self.listDataItemTypes();
                
                if any(dataitemtypes == "SpecData")
                    h = self.DataItems( find(dataitemtypes == "SpecData", 1, 'last') );
                elseif any(dataitemtypes == "ImageData")
                    h = self.DataItems( find(dataitemtypes == "ImageData", 1, 'last') );
                elseif any(dataitemtypes == "TextData")
                    h = self.DataItems( find(dataitemtypes == "TextData", 1, 'last') );
                else
                    h = self.DataItems(end);
                end
                
            else
                % Container is empty, return empty DataItem instance
                h = DataItem.empty;
            end
        end
        

        
        function L = findgroup(self, group)
            %FINDGROUP returns handles of objects belonging to the provided
            %Group (Group object)

            warning("The function DataContainer.findgroup() is deprecated.");
            
            L = DataContainer.empty;
            
            for i = 1:numel(self)
                if ~isempty(self(i).Group)
                    if (self(i).Group == group)
                        L = [L; self(i)];
                    end
                end
            end
            
        end
        
       
        function addSpecData(self, name, gdata, data, graph_unit, data_unit)
            %ADDSPECDATA
            %   Create new SpecData instance containing spectral data

            warning("The function DataContainer.addSpecData() is deprecated.");
            
            lastInstance = numel(self.DataItems);
            self.DataItems( lastInstance + 1 ) = SpecData(name, gdata, data, graph_unit, data_unit);
            
        end
        
        function appendSpecData(self, specdataobj)
            %APPENDSPECDATA
            %   Appends specdata object to list of data items
            %   It can also append multiple SpecData objects to multiple
            %   DataContainer objects if the number of instances is equal.
            %
            %   This function is deprecated. Use APPENDDATAITEM() instead.
            %   
            %   TO DO:
            %   Make general data item function
            
            numSpecDataObj = numel(specdataobj);
            numSelf = numel(self);
            
            if ~(numSpecDataObj == 1 || numSpecDataObj == numSelf)
                % The number of SpecData objects cannot be unambigeously
                % appended to the corresponding DataContainer instances.
                
                return
            end
            
            for i = 1 : numSelf
                % For every instance of DataContainer

                % Deprecated notice
                warning("The function appendSpecData() is deprecated. " + ...
                    "Please replace with appendDataItem().");

                self(i).appendDataItem(specdataobj);
            end
        end
        
        function duplicateData(self, datatype)
            
            if nargin > 1
                h = self.getDataHandles(datatype);
            else
                h = self.getDataHandles();
            end
                
            duplicates = copy(h);
            
            self.appendSpecData( duplicates );
            
            
        end
        
        function pcaresult = grouped_pca(self)
            %GROUPED_PCA DEPRECATED
            %   Groups Data Containes, Sorts by group, calculates PCA

            warning("The function DataContainer.grouped_pca() is deprecated.");
            
            % Filter for SpecDat
            set = findobj(self, 'dataType', "SpecData");
            
            
            % Find unique groups and sort by group
            group_arr = vertcat(set.Group);
            group_name = transpose({group_arr.Name});
            [~, ~, group_num] = unique(group_arr);
%             num_spectra = transpose([set.XSize] .* [set.YSize]);
            data = vertcat(set.Data);
            
            % NaNs are not included in PCA and should, therefore, be left
            % out of the calculation of the number of spectra
            num_spectra = zeros( numel(set), 1 );
            for i = 1 : numel(set)
                num_spectra(i) = sum( ~any( isnan( set(i).Data.FlatDataArray) ) );
            end
                        
            T = table(group_num, group_name, num_spectra, data);
            T = sortrows(T, 'group_num');
            
            % Create summary table
            num_spectra = accumarray(T.group_num, T.num_spectra);
            group_name = unique(T.group_name);
            G = table( group_name, num_spectra );
            
            % Perform PCA
            pcaresult = data.calculatePCA();
            
            % Append Groups
            pcaresult.Groups = G;
            
        end
        
        function h = getDataHandles(self, data_type)
            %% Get handles of spectral data objects
            
            if nargin > 1
                try
                    set = findobj(self, 'dataType', data_type);
                    h = vertcat(set.Data);
                catch
                    warning('Could not find suitable data.');
                    h = [];
                end
            else
                % Get all handles of DataItem() child classes within the
                % DataContainer() instances.
                h = vertcat(self.Data);
            end
            
        end
        
        function set.Name(self, newname)
            self.Name = newname;
        end

   
                
        %% Getters and setters of Dependent Properties
        function displayname = get.DisplayName(self)
            %DISPLAYNAME Format name nicely
            
            if (self.Name == "")
                displayname = "No Name";
            else
                displayname = string(self.Name);
            end
        end
              
        function dataType = get.dataType(self)
            %DATATYPE GETTER
            %   Get Type attribute value of active DataItem instance.
            
            if numel(self.DataItems)
                % DataContainer contains data items
                % Get Type attribute value
                dataType = self.Data.Type;
                
            else
                % DataContainer does not contain any data items
                dataType = "empty";
                
            end
        end


        function graph = get.Graph(self)
            % Get a graph preview
            
            if (self.dataType == "SpecData")
                graph = self.Data.Graph;
            else
                graph = [];
            end
            
        end
        
        function graph = get.DataPreview(self)
            % Get a data preview
            
            if (self.dataType == "SpecData")
                graph = self.Data.get_single_spectrum();
            else
                graph = [];
            end
            
        end
        
        function xsize = get.XSize(self)
            % Get XSize
            
            xsize = [];
            
            if (self.dataType == "TextData")
                return    
            end
            
            % Retrieve XSize of DataItem
            if numel(self.DataItems)
                xsize = self.Data.XSize;
            else
                xsize = [];
            end
            
        end
        
        function ysize = get.YSize(self)
            % Get YSize
            
            ysize = [];
            
            if (self.dataType == "TextData")
                return    
            end
            
            % Retrieve YSize of DataItem
            if numel(self.DataItems)
                ysize = self.Data.YSize;
            else
                ysize = [];
            end
            
        end
        
        function datasize = get.DataSize(self)
            % Get DataSize
            
            datasize = [];
            
            if (self.dataType == "TextData")
                return    
            end
            
            % Retrieve DataSize of DataItem
            if numel(self.DataItems)
                datasize = self.Data.DataSize;
            else
                datasize = [];
            end
            
        end
        
        function analysisGroupParent = get.AnalysisGroupParent(self)
            %ANALYSISGROUPPARENT Retrieve analysis group this data
            %container has been assigned to.
            
            % Search in project.
            prj = self.ProjectParent;
            
            analysisGroupParent = AnalysisGroup.empty;
            
            % Search in analysis sets.
            for i = 1 : numel(prj.AnalysisSet)
                subset = prj.AnalysisSet(i);
                
                % Search in analysis groups.
                for j = 1:numel(subset.GroupSet)
                    subsetgroup = subset.GroupSet(j);
                    
                    if any(self == subsetgroup.Children)
                        % Parent found.
                        analysisGroupParent = subsetgroup;
                        
                    end
                    
                end
            end
        end
        
        function filter = get.Filter(self)
            %FILTER Returns the active filter
            
            filter = SpecFilter.empty();
            
            % Only specdata can be filtered
            if self.dataType ~= "SpecData"
%                 filter = SpecFilter.empty();
                return
            end
            
            % Only LA Scans
            if self.DataSize <= 1
%                 filter =
                return
            end
            
            dataitemtypes = self.listDataItemTypes();
            
            % Is there no filter present?
            if ~any(dataitemtypes == "SpecFilter")
                % Create new filter
                newfilter = SpecFilter();
                self.appendSpecData(newfilter)
                self.setFilter(newfilter);
                
            end
            
            % Is there a filter present, but not set to active?
            if isempty(self.ActiveFilter)
                % Return last SpecFilter from data items
                dataitemtypes = self.listDataItemTypes();
                idx = find(dataitemtypes == "SpecFilter", 1, 'last');
                self.setFilter(self.DataItems(idx));
            end
            
            filter = self.ActiveFilter;
            
        end
        
        function setFilter(self, filter)
            self.ActiveFilter = filter;
        end
        
        function output = get.FilterOutput(self)
            %FILTEROUTPUT Output of filter operation.
            
            if isempty(self.Filter)
                output = [];
                return
                
            end
            
            % Return output of filter
            specdat = self.Data;
            output = self.Filter.getResult(specdat);
            
        end
        
        %% Overrides
        
        function maxval = max(self)
            %MAX Returns maximum value of Data attribute
            
            maxval = max( vertcat( self.DataPreview ) );
            
        end

        function avg_datacontainer = mean(self)
            % MEAN Returns averaged spectra

            % Calculate mean
            specdat = self.getDataHandles;
            avg_specdat = specdat.mean();
            avg_datacontainer = DataContainer(avg_specdat.Name);
            avg_datacontainer.appendDataItem(avg_specdat);

        end
        
        
        %% Destructor
        
        function delete(self)
            %DESTRUCTOR Delete all references to object
            
            prj = self.ProjectParent;
            
            if ~isvalid(prj)
                % Program is probably closing, prj hasn't been found
                % Skip checks
                return
                
            end
            
            % Remove itself from the dataset
            idx = find(self == prj.DataSet);
            prj.DataSet(idx) = [];

            % Remove itself from the group
            if ~isempty(self.Group)
                self.Group.remove_child(self);
            end
            
            % Remove itself from every analysis group
            if ~isempty(self.AnalysisGroupParent)
                idx = find(self == self.AnalysisGroupParent.Children);
                self.AnalysisGroupParent.Children(idx) = [];
            end
            
            
        end
        
        %% Other methods
        function t = listDataItems(self)
            t = listItems(self.DataItems);
        end
        
        function types = listDataItemTypes(self)
            %LISTDATAITEMTYPES Returns array of data item types
            types = vertcat(self.DataItems.Type);
            
        end
        
        
        
        function idx = currentlySelectedDataItem(self)
            idx = numel(self.DataItems);
        end
        
    end
    
    methods (Hidden) %DEBUGGING
        function dbg(obj)
            keyboard
        end
    end
    
end

