classdef ExportOptions
    properties
        direction string = "vertical";
        include_wavenum logical = true;
        rand_subset logical = false;    % Select random subset of data
        rand_num uint32 = 100;          % Number of randomly selected spectra
        zero_to_nan logical = false;
        ignore_nan logical = true;
    end
end