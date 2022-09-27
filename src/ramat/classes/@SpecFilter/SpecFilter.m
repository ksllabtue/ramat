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

            arguments
                self SpecFilter;
                specdat SpecData;
            end

            % Preallocate
            result = nan(specdat(1).XSize, specdat(1).YSize, numel(specdat));
            i = 1;
                        
            for s = specdat(:)'
                idxrange = s.wavnumtoidx( self.range );
    
                operand = s.data(:, :, idxrange(1):idxrange(2));
                
                switch self.operation
                    case 'sum'
                        res = sum(operand, 3);
                    case 'avg'
                        res = mean(operand, 3);
                    case 'max'
                        res = max(operand, [], 3);
                    case 'min'
                        res = min(operand, [], 3);
                    case 'maxmin'
                        hi = max(operand, [], 3);
                        lo = min(operand, [], 3);
                        res = hi - lo;
                end

                % Append to output
                result(:,:,i) = res;
                i = i+1;
            end

            % Simplify
            if (size(result,1) == size(result,2) && size(result,2) == 1)
                result = permute(result, [3 1 2]);
            end
            
        end
    end

    methods (Static)
        function result = calc(specdat, options)
            %CALC Calculate filter result once

            arguments
                specdat
                options.range = [1000, 1300];
                options.operation = "sum";
            end

            options = unpack(options);
            filter = SpecFilter(options{:});

            result = filter.getResult(specdat);

            filter.delete();
        end

    end
end

