classdef ImportOptions
    properties
        type string = "wip";
        folder logical = false;
        gui = [];
        processing = get_processing_options;
        start_path = pwd;
        convert_widata logical = true;
        spec_col int32 = [];   % --- processing options for xls and ascii files
        group_col int32 = [];
        sample_col int32 = [];
        data_col int32 = [];
        group_by_group logical = true;
        group_by_sample logical = true;
        combine_spectra logical = true;
        dimensions int32 = [];
    end
end

