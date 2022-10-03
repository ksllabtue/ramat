function [dataset, groups] = parse_excel(filepath, options)
    
    arguments
        filepath string = "";
        options.?ImportOptions;
        options.spec_col int32 = [];
        options.group_col int32 = [];
        options.sample_col int32 = [];
        options.data_col int32 = [];
        options.group_by_group logical = true;
        options.group_by_sample logical = true;
        options.combine_spectra logical = true;
        options.dimensions int32 = [];
    end

    if options.group_by_sample, options.group_by_group = true; end
    
    %%
    out("Parsing Excel spreadsheet. This might take a while...");

    opts = detectImportOptions(filepath);
    tbl = readtable(filepath, opts, "UseExcel", false);
    %%
    % Get wavenumbers
    out("Extracting wavenumbers.");
    wavenum = table2array(tbl(1,options.data_col:end));
    
    %% Get grouping   
    tbl(1,:) = [];
    tbl = mergevars(tbl,options.data_col:width(tbl));
    
    % Omit non-grouping and non-data
    group_cols = [options.spec_col options.group_col options.sample_col];
    tbl = tbl(:,[group_cols, end]);
    tbl.Properties.VariableNames = ["Spectrum", "Group", "Sample", "Data"];

    num_rows_total = height(tbl);
    out("Found " + string(num_rows_total) + " rows.");
    out("");

    %%
    uni_groups = unique(categorical(tbl.Group), "stable");
    uni_samples = unique(categorical(tbl.Sample), "stable");

    out("Found " + string(numel(uni_groups)) + " groups:");
    disp(uni_groups);

    out("Found " + string(numel(uni_samples)) + " samples:");
    disp(uni_samples);

    prj = Project;
    dataset = DataContainer.empty();
    groups = Group.empty();

    row_progress = 0;
    
    for uni_group = uni_groups(:)'
    
        groupname = string(uni_group);
    
        if options.group_by_group
            group = prj.add_group(groupname);
            groups(end+1) = group;
        end
        
        for uni_sample = uni_samples(:)'

            samplename = string(uni_sample);

            if options.group_by_sample
                sample_group = group.add_child_group(samplename);
            end

            % Get corresponding rows from data table
            rows = bitand(tbl.Group == groupname, tbl.Sample == samplename);
            num_rows = sum(rows);
            sample_tbl = tbl(rows,:);

            dc = DataContainer.empty();

            if options.combine_spectra
                % Create single spectral object for all spectra in this
                % sample
                dat = transpose(sample_tbl.Data);
                specdat = SpecData(samplename, wavenum, dat, dimensions=options.dimensions);

                % Pack into datacontainer
                dc(end+1) = DataContainer(samplename);
                dc.append_child(specdat);
            else
                for i = 1:num_rows
                    dat = sample_tbl.Data(i,:);
                    specdat = SpecData(samplename, wavenum, dat, dimensions=options.dimensions);

                    % Pack into datacontainer
                    dc(end+1) = DataContainer(samplename);
                    dc.append_child(specdat);
                end
            end
    
            dataset = [dataset(:); dc(:)];
            
            if options.group_by_sample
                target_group = sample_group;
            else
                target_group = group;
            end

            target_group.add_children(dc);

            row_progress = row_progress + num_rows;
            out(sprintf("% 5.0f%%%%", 100*(row_progress/num_rows_total)));
        end
    end

end