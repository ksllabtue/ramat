classdef TSNEResult < DataItem
    %PCARESULT Contains results of t-SNE
    %
    %   Parent Class: DataItem
    %
    %   Properties inherited from parent class "DataItem":
    %       name                string
    %       description         string
    %       parent_container    Container
    %       Type                string  (private)
        
    properties
        y double;

        % Source Reference
        source Analysis = Analysis.empty();
        source_data struct = struct();

        % Other info
        CoefsBase double = [0 1];               % Spectral Base for loadings plot of the coefficients
        DataSizes;
        dataType = "tSNE";
    end

    properties (SetAccess=private)
        Type = "tSNE";
    end
    
    properties (Dependent)
%         NumGroups;
%         NumDataPoints;
%         Range;
    end
    
    methods
        function self = TSNEResult(y, parent)
            %PCARESULT Construct an instance of this class

            arguments
                y double;
                parent AnalysisResultContainer = AnalysisResultContainer.empty();
            end
            
            self.name = "";
            self.y = y;
            self.parent_container = parent;
                        
        end

        function [ax, f] = plot(self, options)

            arguments
                self TSNEResult;
                options.Axes = [];
                options.Preview = false;
                options.PlotType = [];
            end

            [ax, f] = plot@DataItem(self, Axes=options.Axes);
            scatter(ax, self.y(:,1), self.y(:,2));

        end
    end
end