function opts_struct = get_processing_options(app)
    %GET_PROCESSING_OPTIONS Get GUI processing options selection
    %   If no app is provided, defaults are used.

    arguments
        app = [];
    end

    opts_struct.trim = false;
    opts_struct.trim_opts.start = 0;
    opts_struct.trim_opts.end = 0;

    if isempty(app)
        % Use defaults
        opts_struct.retain_original = false;
        opts_struct.normalize = false;
        opts_struct.remove_offset = false;
        opts_struct.remove_baseline = false;
        opts_struct.convert_to_wavenum = false;
        opts_struct.remove_baseline_opts = struct.empty();
%         opts_struct.trim = false;
%         opts_struct.trim_opts.start = 0;
%         opts_struct.trim_opts.end = 0;
        return;
    end
        
    % Get values from GUI
    opts_struct.retain_original = app.KeepOriginalCheckBox.Value;
    opts_struct.normalize = app.NormalizeCheckBox.Value;
    opts_struct.remove_offset = false;
    opts_struct.remove_baseline = app.BaselineCorrectionCheckBox.Value;
    opts_struct.convert_to_wavenum = app.ConverttoRelativeWavenumbersCheckBox.Value;
    opts_struct.remove_baseline_opts = struct.empty();
    
end