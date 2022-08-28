classdef AnalysisResultContainer < Container
    %AnalysisResultContainer Contains DataItems that are part of an 
    %analysis result
    %   Similar to DataContainer, but contains DataItems that are part of
    %   an analysis result, e.g. PCAResult and extracted information.

    %   Properties inherited from parent class "Container":
    %       name            string
    %       parent          Group
    %       parent_project  string
    %       children        DataItem
    %       dataType        string (Abstract)

    properties
    end

    properties (Dependent)
        data PCAResult;
        dataType;
    end

    methods
        function self = AnalysisResultContainer(prj, name, parent)
            %ANALYSISRESULTCONTAINER Constructor
            
            arguments
                prj Project = Project.empty();
                name string = "";
                parent Group = Group.empty();
            end

            % New container should have project parent, otherwise it might
            % not be saved.
            if isempty(prj)
                throw(MException('Ramat:validation', 'New analysis container does not have project parent.'));
            end

            % Set to root group, if no group is provided.
            if isempty(parent)
                parent = prj.analysis_result_root;
            end

            self.parent_project = prj;
            self.name = name;
            self.parent = parent;

        end

        function ax = plot(self, kwargs)
            %PLOT Default plotting method, overloads default plot function.
            %   This is the default method to plot data within the container. It
            %   only takes the container as necessary input argument, additional
            %   keyword arguments provide plotting options and axis handles.
            %
            %   Examples:
            %       PLOT(result);
            %

            arguments
                self AnalysisResultContainer;
                kwargs.Axes = [];
                kwargs.Preview = true;
                kwargs.PlotType = "";
            end

            if isempty(self.data)
                return;
            end

            % Forward to data
            dataitem = self.data;
            kwargs = unpack(kwargs);
            ax = dataitem.plot(kwargs{:});

        end

    end

    methods
        function datatype = get.dataType(self)
            datatype = "";
            if isempty(self.data), return; end

            datatype = self.data.dataType;
        end

        function icon = get_icon(self)
            %ICON Gets icon, based on data

            % Retrieve default icon for DataContainer
            icon = get_icon@Container(self);
            if isempty(self.data), return; end

            % Retrieve icon, based on current data item
            icon = self.data.icon;
        end

        function data = get.data(self)
            %DATA Get most important child as data item

            data = PCAResult.empty();
            if isempty(self.children), return; end

            classes = arrayfun(@(x) string(class(x)), self.children);
            data = self.children([find(classes == "PCAResult", 1)]);
            data = [data; self.children([find(classes == "TSNEResult", 1)])];

        end
    end
end