function adjustedData = bgs_builtinBackAdj(x, y, options)
    % BGS_BUILTINBACKADJ Default MATLAB Background adjustment
    %   Detailed explanation goes here
    
    arguments
        x;
        y;
        options.WindowSize = 200;
        options.StepSize = 200;
        options.RegressionMethod = 'pchip';
        options.EstimationMethod = 'quantile';
        options.QuantileValue = 0.10;
    end
    
    adjustedData = msbackadj(x, y, ...
        WindowSize=options.WindowSize, ...
        StepSize=options.StepSize, ...
        RegressionMethod=options.RegressionMethod, ...
        EstimationMethod=options.EstimationMethod, ...
        QuantileValue=options.QuantileValue);
    
end

