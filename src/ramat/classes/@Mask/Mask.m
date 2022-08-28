classdef Mask < DataItem
    %MASK Logical mask for area scans
    
    properties
        data logical = logical.empty(); % Mask data
    end

    properties (Dependent)
        XSize;
        YSize;
        ZSize;
        DataSize;
    end

    properties (SetAccess = private)
        Type = "Mask";
    end
    
    methods
        function self = Mask(data, name)
            %MASK Construct an instance of this class
            
            arguments
                data logical = logical.empty();
                name string = "";
            end

            % Mask
            self.name = name;
            self.data = data;
            
        end
        
        %% Dependent Properties

        function xres = get.XSize(self)
            xres = size(self.Data, 1);
        end
        
        function yres = get.YSize(self)
            yres = size(self.Data, 2);
        end
        
        function zres = get.ZSize(self)
            % TO BE IMPLEMENTED
            zres = 1;
        end
        
        function datares = get.DataSize(self)
            datares = self.XSize * self.YSize * self.ZSize;
        end
    end

end

