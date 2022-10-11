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
        options.normalize logical = false;
        options.normalization_range double = [];
        options.rand_subset logical = false;
        options.rand_num uint32 = 100;
        options.ask_prompt logical = true;
    end
    
    pcaresult = PCAResult.empty;

    % Create copy of analysis as struct
    s = self.struct(selection = true, specdata = true, accumsize = true);

    if options.ask_prompt
        options = ask_selection(options);
    end

    % Corret accumsize of random selection, very hacky
    % to do: fix
    if options.rand_subset
        for i = 1:numel(s)
            non_nan_size = s(i).specdata.get_non_nan_datasize(zero_to_nan=true);
            rand_sub_req = options.rand_num*ones([numel(s(i).specdata), 1]);
            rand_sub_req(rand_sub_req > non_nan_size) = non_nan_size(rand_sub_req > non_nan_size);
            s(i).accumsize = sum(rand_sub_req);
        end
    end

    specdata = vertcat(s.specdata);

    % Check if spectral data has been selected
    if isempty(specdata)
        warning("No spectral data has been selected");
        return;
    end

    % Calculate PCA
    pcaresult = specdata.calculatePCA( ...
        range = options.Range, ...
        algorithm = options.algorithm, ...
        normalize = options.normalize, ...
        normalization_range = options.normalization_range, ...
        rand_subset=options.rand_subset, ...
        rand_num=options.rand_num, ...
        ask_user_input=options.ask_prompt);

    % Provide source reference
    pcaresult.source = self;
    pcaresult.source_data = s;
    pcaresult.name = sprintf("PCAResult from %s", self.display_name);

    function options = ask_selection(options)
        % Ask additional information on normalization

        % Ask prompt
        prompt = {'Do you want to select a subset? Enter the amount of spectra per measurement. Leave empty for no selection.'};
        dlgtitle = 'Subset';
        dims = [1 70];
        definput = {'0'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);

        % Parse input
        num = int32(str2double(answer{1}));
        fprintf("Entered subset: " + num2str(num) + "\n");

        % Parse input
        if num == 0, return; end
        if numel(num) ~= 1, return; end

        options.rand_subset = true;
        options.rand_num = num;

    end

end


