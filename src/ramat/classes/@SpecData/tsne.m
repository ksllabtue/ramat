function tsneres = tsne(self, options)
    %TSNE Calculate t-Distributed Stochastic Neighbor Embedding (t-SNE) of
    %an array of spectral data objects
    %
    %   Input
    %       self:   (mx1) array of SpecData
    %       options:options struct

    arguments
        self;
        options.range double = [];
        options.algorithm string = "barneshut";
        options.method string = "euclidian";
    end
       
    % Prepare data
    [x, ~] = self.prepare_multivariate(range=options.range);

    % Calculate PCA
    y = tsne(x, Algorithm=options.algorithm, Distance=options.method);
    
    % Return results as an TSNEResult Object
    tsneres = TSNEResult(y);

end

