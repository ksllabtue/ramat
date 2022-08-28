function pcaresult = compute_pca(self, options)
    %COMPUTE_PCA Compute a principle component analysis (PCA) of current 
    % analysis subset.
    %   Input:
    %       self
    %       options.Range:      range [2x1 array] in cm^-1
    %       options.Selection   selection of DataContainers
    %
    %   Output:
    %       pcaresult:  PCAResult object
    
    arguments
        self Analysis
        options.Range double = [];
        options.Selection (:,:) DataContainer = DataContainer.empty;
        options.algorithm = "svd";
    end
    
    pcaresult = PCAResult.empty;

    % Create copy of analysis as struct
    s = self.struct(selection = true, specdata = true, accumsize = true);
    specdata = vertcat(s.specdata);

    % Check if spectral data has been selected
    if isempty(specdata)
        warning("No spectral data has been selected");
        return;
    end

    % Calculate PCA
    pcaresult = specdata.calculatePCA(range = options.Range, algorithm = options.algorithm);

    % Provide source reference
    pcaresult.source = self;
    pcaresult.source_data = s;
    pcaresult.name = sprintf("PCAResult from %s", self.display_name);

end


