function pcaresult = calculate_pca_static(x, options)
    %CALCULATE_PCA_STATIC Calculate principle component analysis (PCA) of
    % a static data array
    %
    %   Input
    %       x:   (mxn) input array in horizontal direction (m = number of
    %       spectra, n = graph size)
    %       options.range:  (2x1) double
    %       options.algorithm: "svd", "svd-nsc", "eig", "als", "nipals"

    arguments
        x double = [];
        options.?PCAOptions;
        options.range double = [];
        options.algorithm string = "svd";
        options.invert_pcs = false;         % Invert all scores with respect to pc1
        options.normalize logical = false;
        options.normalization_range double = [];
        options.ask_user_input = true;     % Ask for additional user input through prompt
        options.rand_subset logical = false;
        options.rand_num uint32 = 100;
    end

    fprintf("Calculating PCA using " + options.algorithm + " algorithm.\n");
       
    % Choose inversion, svd-nsc is just svd with inverted pcs (to
    % approximate the NIPALS algorithm sign convention).
    if options.algorithm == "svd-nsc"
        options.algorithm = "svd";
        options.invert_pcs = true;
    end

    % Calculate PCA
    if options.algorithm == "nipals"
        [scores, coefs, variance] = nipals(x, 10);
    else
        [coefs, scores, ~, ~, variance] = pca(x, Algorithm=options.algorithm);
    end

    % Invert pcs when svd-nsc is selected
    if options.invert_pcs
        scores(:,2:end) = -scores(:,2:end);
    end
    
    % Return results as an PCAResult Object
    pcaresult = PCAResult([], coefs, scores, variance);
    pcaresult.source_opts = options;

end

