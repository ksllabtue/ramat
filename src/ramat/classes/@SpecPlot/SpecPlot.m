classdef SpecPlot
    %SPECPLOT Saved spectral plot
    %   ...
    
    properties
        name string;
        parent Project;
        data AnalysisGroup;
        options = struct();
        selection Link;
    end
    
    properties
        dataType = "SpecPlot";
    end
    
    methods
        function self = SpecPlot(data, parent, kwargs)
            %SPECPLOT Construct an instance of this class
            %   ...
            
            arguments
                data {mustBeA(data, ["DataContainer", "Link"])};
                parent Project;
                kwargs.plot_type = 'Overlaid';
            end

            self.data = AnalysisGroup(Analysis.empty(), "Plotting");
            self.data.append_data(data);
            self.selection = self.data.children;

            self.parent = parent;
            
            self.options.plot_type = kwargs.plot_type;
            self.options.plot_stack_distance = 1;
            
        end

        function [ax, f] = plot(self, options)

            arguments
                self SpecPlot;
                options.Axes = [];
            end

            static_data = self.data.get_static_list();

            static_data.plot( ...
                Axes = options.Axes, ...
                plot_type = self.options.plot_type, ...
                plot_stack_distance = self.options.plot_stack_distance, ...
                legend_entries = self.get_legend_entries);

        end

        function legend_entries = get_legend_entries(self)
            %GET_LEGEND_ENTRIES Get legend entries from names of links
            %(custom names)

            legend_entries = vertcat(self.data.children.display_name);
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
            links = intersect(self.data.children, links);
            
            % Update Selection
            self.selection = links;
            
        end
        
    end
end

