function [x, base] = prepare_multivariate(self, options)
    %PREPARE_MULTIVARIATE Prepares data for multivariate data analysis
    %
    %   Output:
    %       x       prepared data
    %       base    graph base
    
    arguments
        self SpecData;
        options.range double = [];
        options.redo_normalization logical = false;
        options.renormalization_range double = [];
    end

    if ~isempty(options.range)
        % Calculate PCA of a specific range
        startG = options.range(1);
        endG = options.range(2);

        tmpdat = copy(self);
        tmpdat.normalize_spectrum(range=[500 3200]);
        
        % Create a trimmed SpecData() as a copy.
        tmpdat = trim_spectrum(tmpdat, startG, endG);
        base = tmpdat.graph;

        % --- TO DO ---
        % Strategy to deal with different graph bases

        % Option 1: simply omit overlength
        graph_sizes = [tmpdat.GraphSize];

        % Are graph bases the same
        if ~all(graph_sizes == graph_sizes(1))
            
            warning("Not all graph bases are equally long!");

            min_length = min(graph_sizes);

            warning("Strategy: omitting overlength (might result in data loss)");
            
            % Trim further to minimum
            for spec = tmpdat(:)'
                spec.graph = spec.graph(1:min_length);
                spec.data = spec.data(:,:,1:min_length);
            end
        end

        % --- xx xx ---

        % Perform renormalization
        % Recommended after trimming
        if options.redo_normalization
            fprintf("Renormalizing spectra.\n");
            tmpdat.normalize_spectrum();
        end
        
        flatdata = horzcat(tmpdat.FlatDataArray);
        
        % Free up memory
        delete(tmpdat);
        clear tmpdat
        
    else
        % Use the full range
        
        flatdata = horzcat(self.FlatDataArray);
        base = self.graph;
        
    end


    
    % Remove NaN-Spectra
    flatdata( :, all(isnan(flatdata))) = [];
    
    x = transpose(flatdata);
end

