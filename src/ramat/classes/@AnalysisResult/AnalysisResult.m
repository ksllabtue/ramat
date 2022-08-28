classdef AnalysisResult < handle & matlab.mixin.Heterogeneous
    %ANALYSISRESULT Super Class of all analysis result classes
    %   Child classes: PCAResult, ...
    
    properties
        Name;
    end
    
    properties (Dependent)
        DisplayName;
    end
    
    properties (Abstract)
        dataType;
    end
    
    methods
        function displayname = get.DisplayName(self)
            %DISPLAYNAME Format name nicely
            
            if (self.Name == "")
                displayname = "PCA Result";
            else
                displayname = string( self.Name );
            end
        end
    end
end

