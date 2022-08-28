function pcaresult = calculatePCA(self, options)
    %CALCULATEPCA Calculate principle component analysis (PCA) of an array
    %of spectral data objects
    %
    %   Input
    %       self:   (mx1) array of SpecData
    %       options.range:  (2x1) double
    %       options.algorithm: "svd", "eig", "als"

    arguments
        self;
        options.range double = [];
        options.algorithm string = "svd";
    end
       
    % Prepare data
    [x, graph_base] = self.prepare_multivariate(range=options.range);

    % Calculate PCA
    [coefs, score, ~, ~, variance] = pca(x, Algorithm=options.algorithm);
    
    % Return results as an PCAResult Object
    pcaresult = PCAResult(graph_base, coefs, score, variance);

end

