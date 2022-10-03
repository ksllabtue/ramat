function [x, base] = prepare_multivariate(self, options)
    %PREPARE_MULTIVARIATE Prepares data for multivariate data analysis
    %
    %   Output:
    %       x       prepared data
    %       base    graph base
    
    arguments
        self SpecData;
        options.range double = [];
        options.normalize logical = false;
        options.normalization_range double = [];
        options.rand_subset logical = false;
        options.rand_num uint32 = 100;
    end


    % Work on temporary copy
    tmpdat = copy(self);

    % Normalize spectrum
    if options.normalize
        tmpdat.normalize_spectrum(range=options.normalization_range);
    end

    if ~isempty(options.range)
        % Calculate PCA of a specific range
        startG = options.range(1);
        endG = options.range(2);
        
        % Create a trimmed SpecData() as a copy.
        tmpdat = trim_spectrum(tmpdat, startG, endG);


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
%         if options.normalize
%             fprintf("Renormalizing spectra.\n");
%             tmpdat.normalize_spectrum();
%         end
        
        flatdata = tmpdat.get_formatted_export_array(include_wavenum=false, zero_to_nan=true, rand_subset=options.rand_subset, rand_num=options.rand_num, include_index_number=false);
        base = tmpdat.graph;
        
    else
        % Use the full range
        
        flatdata = tmpdat.get_formatted_export_array(include_wavenum=false, zero_to_nan=true, rand_subset=options.rand_subset, rand_num=options.rand_num, include_index_number=false);
        base = self.graph;
        
    end

    
    % Remove NaN-Spectra
    flatdata( :, all(isnan(flatdata))) = [];

    x = transpose(flatdata);

    % Free up memory
    delete(tmpdat);
    clear tmpdat
end

