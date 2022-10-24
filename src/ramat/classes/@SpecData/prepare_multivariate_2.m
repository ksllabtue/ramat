function tmpdata = prepare_multivariate_2(self, options)
    %PREPARE_MULTIVARIATE_2 Prepares data for multivariate data analysis
    %
    %   Output:
    %       tmpdata     Copy of original data
    
    arguments
        self SpecData;
        options.?PCAOptions;
        options.use_range logical = false;
        options.range double = [];
        options.normalize logical = false;
        options.normalization_range double = [];
    end

    out("Preparing multivariate data...");

    % Work on temporary copy
    tmpdata = copy(self);

    % Normalize spectrum
    if options.normalize
        tmpdata.normalize_spectrum(range=options.normalization_range);
    end
    
    % Trim spectrum
    if options.use_range 
        tmpdata.trim_spectrum(options.range);
    end

end

