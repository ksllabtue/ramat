classdef PCAOptions
    properties
        use_range logical = false;
        range double = [600, 1800];
        algorithm = "svd";
        normalize logical = false;
        normalization_range double = [600, 1800];
        rand_subset logical = false;
        rand_num uint32 = 100;
        use_mask logical = false;
        create_mask logical = true;
        zero_to_nan logical = false;
        ignore_nan logical = true;      % Should really always be true
    end
end