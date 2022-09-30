function [ax, f] = plot_score_stats(self, pc, options)
%PLOT_SCORE_STATS Plot scores of single principal components
%   This function draws a boxplot of the scores of individual principal
%   components and will group samples together.

    arguments
        self PCAResult;
        pc uint8 = 1;
        options.?PlotOptions;
        options.Axes = []; % Handle to Axes, if empty a new figure will be created
        options.color_order = [];
        options.symbols = ["o", "square", "^", "v", "diamond"];
        options.use_symbols = false;
        options.per_sample = true;
        
    end

    if isempty(self.source_data)
        % We need a grouping table to create a legend.
        
        num_spectra = size(self.Score, 1);
        self.source_data.name = "Ungrouped";
        self.source_data.accumsize = num_spectra;
    end

    [ax, f] = self.plot_start(Axes=options.Axes);

    % Retrieve scores table
    [scores_tbl, scores_col] = self.get_scores_summary(pc=pc, per_sample=options.per_sample);

    sc = swarmchart(scores_tbl.group_index, scores_tbl.(scores_col));
    hold(ax,"on");
    boxplot(scores_tbl.(scores_col), scores_tbl.group_index, Labels=[self.source_data.name]);


end

