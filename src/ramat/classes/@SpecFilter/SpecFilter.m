classdef SpecFilter < DataItem
    %SPECFILTER Spectral Filter for Area Scans
    %   Detailed explanation goes here
    
    properties
        range;  % Working Range of Filter
        operation;  % Mathematical Operation to Perform
    end
    
    properties (SetAccess = private)
        Type = "SpecFilter";
    end
            
    methods
        function self = SpecFilter(options)
            %SPECFILTER Construct an instance of this class
            %   Detailed explanation goes here
            
            arguments
                options.name string = "";
                options.range double = [1000, 1300];
                options.operation char = 'sum';
            end
            
            self.name = options.name;
            self.range = options.range;
            self.operation = options.operation;
            
            
        end
        
        function result = getResult(self, specdat)
            %   RESULT
            %   specdat:    Operand (Input)
            %   result:     Output
            
            idxrange = specdat.wavnumtoidx( self.range );
            
            switch self.operation
                case 'sum'
                    result = sum( specdat.data(:, :, idxrange(1):idxrange(2)), 3);
                case 'avg'
                    result = mean( specdat.data(:, :, idxrange(1):idxrange(2)), 3);
                case 'maxmin'
                    hi = max( specdat.data(:, :, idxrange(1):idxrange(2)), [], 3);
                    lo = min( specdat.data(:, :, idxrange(1):idxrange(2)), [], 3);
                    result = hi - lo;
            end
            
        end
        
    end
end

