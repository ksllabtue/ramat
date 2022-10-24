classdef SpecFilter < DataItem
    %SPECFILTER Spectral Filter for Area Scans
    %   Detailed explanation goes here
    
    properties
        range;              % Working Range of Filter
        operation;          % Mathematical Operation to Perform
        parent_specdata;    % Linked spectral data
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
        
        function result = get_result(self, specdat)
            %   RESULT
            %   specdat:    Operand (Input)
            %   result:     Output

            arguments
                self SpecFilter;
                specdat SpecData = SpecData.empty;
            end

            % What is our operand?
            if isempty(specdat)
                specdat = self.parent_specdata;
            end

            % Preallocate
            result = nan(specdat(1).XSize, specdat(1).YSize, numel(specdat));
            i = 1;
                        
            for s = specdat(:)'
                idxrange = s.wavnumtoidx( self.range );
    
                operand = s.data(:, :, idxrange(1):idxrange(2));
                
                switch self.operation
                    case 'sum'
                        % Sum filter
                        res = sum(operand, 3);
                    case 'avg'
                        % Average filter
                        res = mean(operand, 3);
                    case 'max'
                        % Maximum filter
                        res = max(operand, [], 3);
                    case 'min'
                        % Minimum filter
                        res = min(operand, [], 3);
                    case 'maxmin'
                        % Get height difference
                        hi = max(operand, [], 3);
                        lo = min(operand, [], 3);
                        res = hi - lo;
                    case 'maxloc'
                        % Get location of maximum
                        [~, idx] = max(operand, [], 3);
                        res = s.graph(idx + idxrange(1));
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

        function [ax, f] = plot(self, options)
            %PLOT Plotting method for SpecFilter

            arguments
                self;
                options.?PlotOptions;
                options.Axes = [];
            end

            % Get axes handle or create new figure window with empty axes
            [ax, f] = self.plot_start(Axes = options.Axes);

            % Plot generated result
            imgdata = self.get_result();
            imagesc(imgdata);

        end

        function add_context_actions(self, cm, node, app)
            %ADD_CONTEXT_ACTIONS Retrieve all (possible) actions for this
            %data item that should be displayed in the context menu
            %   This function adds menu items to the context menu, which
            %   link to specific context actions for this data item.
            %
            arguments
                self;
                cm matlab.ui.container.ContextMenu;
                node matlab.ui.container.TreeNode;
                app ramatguiapp;
            end

            % Get parent actions of DataItem
            add_context_actions@DataItem(self, cm, node, app);

            % Add plotting menu
            uimenu(cm, Text="Plot spectral filter output", MenuSelectedFcn=@(~,~) plot(self));

            % Edit spectral filter
            uimenu(cm, Text="Edit spectral filter");


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

            result = filter.get_result(specdat);

            filter.delete();
        end

    end
end

