function tsneres = compute_tsne(self, options)
    %COMPUTE_TSNE Compute a t-SNE of current analysis subset.
    %   Input:
    %       self
    %       options.range:      range [2x1 array] in cm^-1
    %       options.selection   selection of DataContainers
    %       options.algorithm   algorithm
    %       options.method      distance method
    %
    %   Output:
    %       pcaresult:  PCAResult object
    
    arguments
        self Analysis
        options.range double = [];
        options.selection (:,:) DataContainer = DataContainer.empty;
        options.algorithm = "barneshut";
        options.method = "mahalanobis";
    end
    
    tsneres = TSNEResult.empty;

    % Create copy of analysis as struct
    s = self.struct(selection = true, specdata = true, accumsize = true);
    specdata = vertcat(s.specdata);

    % Check if spectral data has been selected
    if isempty(specdata)
        warning("No spectral data has been selected");
        return;
    end

    % Calculate PCA
    tsneres = specdata.tsne(range=options.range, algorithm=options.algorithm, method=options.method);

    % Provide source reference
    tsneres.source = self;
    tsneres.source_data = s;
    tsneres.name = sprintf("t-SNE Result from %s", self.display_name);

end
