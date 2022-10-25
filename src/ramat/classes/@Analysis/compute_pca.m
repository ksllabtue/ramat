function pcaresult = compute_pca(self, options)
    %COMPUTE_PCA Compute a principle component analysis (PCA) of current 
    % analysis subset.
    %   Input:
    %       self
    %       options.Range:      range [2x1 array] in cm^-1
    %
    %   Output:
    %       pcaresult:  PCAResult object
    
    arguments
        self Analysis
        options.?PCAOptions;
        options.use_range logical = false;
        options.range double = [];
        options.algorithm = "svd";
        options.normalize logical = false;
        options.normalization_range double = [];
        options.rand_subset logical = false;
        options.rand_num uint32 = 100;
        options.use_mask logical = false;
        options.create_mask logical = true;
        options.zero_to_nan logical = false;
        options.ignore_nan logical = true;
    end
    
    pcaresult = PCAResult.empty;

    opts = unpack(options);

    % Create copy of analysis as struct
    s = self.struct(selection = true, specdata = true, accumsize = true);

    % Prepare multivariate data: trimming, normalization
    for i = 1:numel(s)
        specdata = vertcat(s(i).specdata);
        s(i).specdata_prepared = specdata.prepare_multivariate_2(opts{:});
    end

    % Assert equal graph sizes
    all_specdata = vertcat(s.specdata_prepared);
    all_specdata.force_equal_graph_size();

    % Create master data table
    for i = 1:numel(s)
        specdata = vertcat(s(i).specdata_prepared);
        [datatbl, wavenum] = specdata.get_formatted_export_array(...
            as_table=true, ...
            merge_data_cols=true, ...
            rand_subset=options.rand_subset, ...
            rand_num=options.rand_num, ...
            use_mask=options.use_mask, ...
            create_mask=options.create_mask, ...
            zero_to_nan=options.zero_to_nan, ...
            ignore_nan=options.ignore_nan, ...
            include_reflinks=true);

        s(i).accumsize = height(datatbl);

        % Get full group vector/column
        group_indices = repmat(i, [s(i).accumsize, 1]);
        group_names = repmat(s(i).name, [s(i).accumsize, 1]);

        % Get full sample vector/column
        sample_names = s(i).sample_names(datatbl.spec_idx);
        [~, ~, sample_indices] = unique(sample_names, "stable");

        labels = table(group_indices, group_names, sample_indices, sample_names,...
            VariableNames=["group_index", "group_name", "sample_index", "sample_name"]);

        % Horzcat tables
        s(i).tbl = [labels, datatbl];

    end

    tbl = vertcat(s.tbl);
    s = rmfield(s, 'tbl');

    data = tbl.data;

    % Check if spectral data has been selected
    if isempty(data)
        warning("No spectral data has been selected");
        return;
    end

    % Calculate PCA
    pcaresult = SpecData.calculate_pca_static(data, opts{:});
    pcaresult.CoefsBase = wavenum;
    
    % Provide source reference
    pcaresult.source = self;
    pcaresult.source_data = s;
    pcaresult.source_table = tbl;
    pcaresult.name = sprintf("PCAResult from %s", self.display_name);

    pcaresult.generate_description();

    % Cleaning and fixing
    % Masks have been assigned to copies of specdata, assign them back to
    % the originals
    for i = 1:numel(s)
        for spec_copy = s(i).specdata_prepared(:)'
            spec_orig = spec_copy.parent_container.get_data();
            spec_orig.set_mask(spec_copy.mask);
        end
    end

end


