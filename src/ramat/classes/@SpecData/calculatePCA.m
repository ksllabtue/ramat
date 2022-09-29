function pcaresult = calculatePCA(self, options)
    %CALCULATEPCA Calculate principle component analysis (PCA) of an array
    %of spectral data objects
    %
    %   Input
    %       self:   (mx1) array of SpecData
    %       options.range:  (2x1) double
    %       options.algorithm: "svd", "svd-nsc", "eig", "als", "nipals"

    arguments
        self;
        options.range double = [];
        options.algorithm string = "svd";
        options.invert_pcs = false;         % Invert all scores with respect to pc1
        options.normalize logical = false;
        options.normalization_range double = [];
        options.ask_user_input = true;     % Ask for additional user input through prompt
    end

    % Ask for user input
    if options.ask_user_input
        options = ask_normalization(options);
    end

    fprintf("Calculating PCA using " + options.algorithm + " algorithm.\n");
       
    % Prepare data
    [x, graph_base] = self.prepare_multivariate( ...
        range=options.range, ...
        normalize=options.normalize, ...
        normalization_range=options.normalization_range);

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
    pcaresult = PCAResult(graph_base, coefs, scores, variance);
    pcaresult.source_opts = options;

    function options = ask_normalization(options)
        % Ask additional information on normalization

        % Ask prompt
        prompt = {'Should the spectra be renormalized? Enter a range (in cm-1) or leave empty for no normalization.'};
        dlgtitle = 'Normalization';
        dims = [1 70];
        definput = {'500-3200'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);

        % Parse input
        range = str2num(replace(answer{1},"-",","));
        fprintf("Entered range: " + num2str(range) + "\n");

        % Parse input
        if isempty(range), return; end
        if numel(range) ~= 2, return; end

        options.normalize = true;
        options.normalization_range = range;

    end

end

