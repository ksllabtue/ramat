function [scorestable, scores_data_col] = get_scores_summary(self, options)
    %GET_SCORES_SUMMARY Summarize scores in tabular format per sample
    
    arguments
        self PCAResult;
        options.per_sample logical = false;
        options.pc int8 = 1;
        options.optimized_for_prism = false;
        options.ask_pc = false;
    end

    % Ask for user input?
    if options.ask_pc
        options = ask_pc(options);
    end

    % Label corresponding to table column name
    pclabel = "PC-" + string(options.pc);

    % Get entire scores table
    scorestable = self.scores_table;
    scores_data_col = pclabel;

    % Average by sample
    if options.per_sample
        scorestable = grpstats(scorestable,["group_index","group_name","sample_index","sample_name"],"mean", DataVars=pclabel);
        scores_data_col = string(scorestable.Properties.VariableNames(end));
    end

    % Optimize output for direct use in GraphPad Prism
    if options.optimized_for_prism
        scorestable = PCAResult.tall_to_wide(scorestable, column=scores_data_col);
    end

    % User input
    function options = ask_pc(options)
        % Ask additional information on what pc to export

        % Ask prompt
        prompt = {'Enter principal component number:'};
        dlgtitle = 'Principal Component';
        dims = [1 70];
        definput = {'1'};
        answer = inputdlg(prompt,dlgtitle,dims,definput);

        % Parse input
        pc = str2num(answer{1});
        fprintf("Entered principal component: " + num2str(pc) + "\n");

        % Parse input
        if isempty(pc), return; end
        if numel(pc) ~= 1, return; end

        options.pc = pc;
    end

end

