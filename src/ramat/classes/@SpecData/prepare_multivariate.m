function [x, base] = prepare_multivariate(self, options)
    %PREPARE_MULTIVARIATE Prepares data for multivariate data analysis
    %
    %   Output:
    %       x       prepared data
    %       base    graph base
    
    arguments
        self SpecData;
        options.range double = [];
    end

    if ~isempty(options.range)
        % Calculate PCA of a specific range
        startG = options.range(1);
        endG = options.range(2);
        
        % Create a trimmed SpecData() as a copy.
        tmpdat = trim_spectrum(copy(self), startG, endG);
        base = tmpdat.graph;            
        
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

