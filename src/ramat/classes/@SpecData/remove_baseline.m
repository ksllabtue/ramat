function remove_baseline(self, method, kwargs)
    % REMOVEBASELINE Returns object with baseline removed
    %   NaN-safe and preserves NaN values
    
    arguments
        self;
        method = 'builtin';
        kwargs struct = [];
    end

    % Do python-like unpacking of kwargs
    kwargs = unpack(kwargs);

    for i = 1:numel(self)

        if method == "constant"
            % Use class method SUBTRACT_MINIMUM
            self(i).subtract_minimum(kwargs{:});
            return
        end

        % Retrieve flattened 2-dimensional array
        flatdat = self(i).FlatDataArray;
        nSpectra = self(i).XSize * self(i).YSize;

        % Make NaN-safe
        nan_array = isnan(flatdat);
        nan_columns = max(nan_array, [], 1);
        has_nan = any(nan_columns);
        if has_nan
            % Return array with solely actual numbers
            numerical_columns = ~nan_columns;
            flatdat = flatdat(:, numerical_columns);
            nSpectra = size(flatdat, 2);
        end

        if (nSpectra > 100)
            fprintf('--- Removing baseline from %i spectra. This might take a while.\n', nSpectra);
        end

        % Perform removal of baseline
        switch method
            case 'constant'
                % Subtract constant value
                
                % Already implemented
                
            case 'builtin'
                % Use MATLAB builtin function

                % Repeat x axis
                % TO DO: make it work with different xbase lengths
                xbase = repmat(self(i).graph, 1, nSpectra);
                
                % Run background subtraction and pass options
                adjusted_data = bgs_builtinBackAdj(xbase, flatdat, kwargs{:});
                
            case 'airPLS'
                % Use airPLS algorithm

                adjusted_data = bgs_airPLS(flatdat, 10e4, 2, 0.05);
            otherwise

                fprintf('Baseline Correction Method not implemented.\n');
                return
        end
        

        % Return adjusted data into spectral object
        if has_nan
            % Only update the numerical columns
            rows = boolean(ones(1, self(i).GraphSize));
            self(i).data( rows , numerical_columns ) = adjusted_data;
        else
            self(i).data = adjusted_data;
        end

    end

end

