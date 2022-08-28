classdef PCAResult < DataItem
    %PCARESULT Contains results of PCA
    %
    %   Parent Class: DataItem
    %
    %   Properties inherited from parent class "DataItem":
    %       name                string
    %       description         string
    %       parent_container    Container
    %       Type                string  (private)
        
    properties
        Coefs double;                           % Coefficients
        Score double;                           % Scores
        Variance double;

        % Source Reference
        source Analysis = Analysis.empty();
        source_data struct = struct();

        % Other info
        CoefsBase double = [0 1];               % Spectral Base for loadings plot of the coefficients
        DataSizes;
        dataType = "PCA";
    end

    properties (SetAccess=private)
        Type = "PCA";
    end
    
    properties (Dependent)
        NumGroups;
        NumDataPoints;
        Range;
    end
    
    methods
        function self = PCAResult(coefsbase, coefs, score, variance, parent)
            %PCARESULT Construct an instance of this class

            arguments
                coefsbase double;
                coefs double;
                score double;
                variance double;
                parent AnalysisResultContainer = AnalysisResultContainer.empty();
            end
            
            self.name = "";
            self.parent_container = parent;
            
            self.CoefsBase = coefsbase;
            self.Coefs = coefs;
            self.Score = score;
            self.Variance = variance;

            self.description = self.generate_description();
                        
        end
        
        % Method Signatures
        scoresscatter(self, pcax);
        plotLoadings(self, pcax);
        
        % Methods
        function desc = generate_description(self)
            % Generate a simple description of the PCA analysis

            desc = vertcat(...
                sprintf( "Name:   %s", self.name ), ...
                sprintf( "Generated from: %s", self.source.display_name), ...
                sprintf( "Range:  %.1f - %.1f", self.Range(1), self.Range(2) ), ...
                sprintf( "Groups: %.0f", self.NumGroups ), ...
                sprintf( "Points: %.0f", self.NumDataPoints ) );

        end

        function recalculate(self)
            %RECALCULATE Recalculates PCA from linked analysis
            
            new_pca_result = self.source.compute_pca();
            self.update(new_pca_result);
        end

        function update(self, new_pcares)
            %UPDATE Updates properties with new PCAResult, provided by
            %new_pcares

            arguments
                self PCAResult;
                new_pcares PCAResult;
            end

            self.Coefs = new_pcares.Coefs;
            self.CoefsBase = new_pcares.CoefsBase;
            self.Score = new_pcares.Score;
            self.Variance = new_pcares.Variance;
            self.source_data = new_pcares.source_data;

        end
        
        function numgroups = get.NumGroups(self)
            % Get the number of groups
            numgroups = length(self.source_data);
        end
        
        function numdatapoints = get.NumDataPoints(self)
            % Get the number of data points
            sizes = size(self.Score);
            numdatapoints = sizes(1);
        end
        
        function range = get.Range(self)
            % Get the number of data points
            range = [min(self.CoefsBase), max(self.CoefsBase)];
        end

        function ax = plot(self, kwargs)
            %PLOT Default plotting function of PCAResult

            arguments
                self;
                kwargs.Axes = [];
                kwargs.PCs uint8 = [1 2];
                kwargs.Preview = true;
                kwargs.PlotType = "";
            end

            ax = [];

            pcax = kwargs.PCs;
            self.scoresscatter(pcax, Axes=kwargs.Axes);

        end

        function add_loadings_spectrum(self, pcax)
            %ADD_LOADINGS_SPECTRUM Generate a loadings spectrum and add it
            %to the parent container

            arguments
                self;
                pcax uint8 = 1;
            end
            
            specsimple = self.gen_loadings_spectrum(pcax);
            self.append_sibling(specsimple);
        end

        function plot_loadings_spectrum(self, pcax)
            %PLOPT_LOADINGS_SPECTRUM Plot / preview loadings spectrum,
            %without adding it to the parent container

            arguments
                self;
                pcax uint8 = 1;
            end

            specsimple = self.gen_loadings_spectrum(pcax);
            specsimple.plot();
            specsimple.delete();
        end


        function specsimple = gen_loadings_spectrum(self, pcax)
            %GEN_LOADINGS_SPECTRUM Generate a loadings spectrum
            %   Outputs a SpectrumSimple object.

            arguments
                self
                pcax uint8 = 1;
            end

            xdat = self.CoefsBase;
            ydat = self.Coefs(:, pcax);

            specsimple = SpectrumSimple( ...
                xdat, "cm-1", ...
                ydat, "a.u.", ...
                self);

            specsimple.name = "Loadings PC" + string(pcax(:)');
            specsimple.legend_entries = "PC" + string(pcax(:));

        end
            
        
    end
end

