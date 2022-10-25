classdef PCAResult < DataItem
    %PCARESULT Contains results of PCA
    %
    %   Parent Class: DataItem
    %
    %   Properties inherited from parent class "DataItem":
    %       name                string
    %       description         string
    %       parent_container    Container
    %       Type                string  (private)
        
    properties
        Coefs double;                           % Coefficients
        Score double;                           % Scores
        Variance double;

        % Source Reference
        source Analysis = Analysis.empty();
        source_data struct = struct();
        source_opts struct = struct();
        source_table table;

        % Other info
        CoefsBase double = [0 1];               % Spectral Base for loadings plot of the coefficients
        DataSizes;
        dataType = "PCA";
    end

    % List of exportable formats
    properties (SetAccess = private, GetAccess = private)
        format_list = ["csv";"mat";"xlsx"];
    end

    properties (SetAccess=private)
        Type = "PCA";
    end
    
    properties (Dependent)
        NumGroups;
        NumDataPoints;
        Range;
        scores_table;

        % Source reference
        source_group_indices uint32;
        source_sample_indices uint32;
    end
    
    methods
        function self = PCAResult(coefsbase, coefs, score, variance, parent)
            %PCARESULT Construct an instance of this class

            arguments
                coefsbase double;
                coefs double;
                score double;
                variance double;
                parent AnalysisResultContainer = AnalysisResultContainer.empty();
            end
            
            self.name = "";
            self.parent_container = parent;
            
            self.CoefsBase = coefsbase;
            self.Coefs = coefs;
            self.Score = score;
            self.Variance = variance;
                        
        end
        
        % Method Signatures
        [ax, f] = scoresscatter(self, pcax);
        [ax, f] = plot_score_stats(self, pc);
        [t, sc] = get_scores_summary(self);
        plotLoadings(self, pcax);
        
        % Methods
        function desc = generate_description(self)
            % Generate a simple description of the PCA analysis

            desc = vertcat(...
                sprintf( "Name:   %s", self.name ), ...
                sprintf( "Generated from: %s", self.source.display_name), ...
                sprintf( "Range:  %.1f - %.1f", self.Range(1), self.Range(2) ), ...
                sprintf( "Groups: %.0f", self.NumGroups ), ...
                sprintf( "Points: %.0f", self.NumDataPoints ) );

        end

        function recalculate(self)
            %RECALCULATE Recalculates PCA from linked analysis

            % Retrieve original options
            options = rmfield(self.source_opts, ["invert_pcs", "ask_user_input"]);
            opts = unpack(options);

            new_pca_result = self.source.compute_pca(opts{:});
            self.update(new_pca_result);
        end

        function update(self, new_pcares)
            %UPDATE Updates properties with new PCAResult, provided by
            %new_pcares

            arguments
                self PCAResult;
                new_pcares PCAResult;
            end

            self.Coefs = new_pcares.Coefs;
            self.CoefsBase = new_pcares.CoefsBase;
            self.Score = new_pcares.Score;
            self.Variance = new_pcares.Variance;
            self.source_data = new_pcares.source_data;

        end
        
        function numgroups = get.NumGroups(self)
            % Get the number of groups
            numgroups = length(self.source_data);
        end
        
        function numdatapoints = get.NumDataPoints(self)
            % Get the number of data points
            sizes = size(self.Score);
            numdatapoints = sizes(1);
        end
        
        function range = get.Range(self)
            % Get the number of data points
            range = [min(self.CoefsBase), max(self.CoefsBase)];
        end

        function group_indices = get.source_group_indices(self)
            %SOURCE_GROUPING This should be faster, TODO
            [~, ~, group_indices] = unique(vertcat(self.source_data.group_names), "stable");
        end

        function sample_indices = get.source_sample_indices(self)
            [~, ~, sample_indices] = unique(vertcat(self.source_data.sample_names), "stable");
        end

        function t = get.scores_table(self)
            %GET_SCORES_SUMMARY Summarize scores in tabular format
        
            % PC labels
            pclabels = "PC-" + string(1:size(self.Score,2));
        
            % Convert scores to table
            scores = array2table(self.Score, VariableNames=pclabels);

            % Meta labels from master table
            labels = self.source_table(:, [5 1 2 3 4]);
            labels.Properties.VariableNames = ["spec_name", "group_index", "group_name", "sample_index", "sample_name"];
        
            % Horzcat tables
            t = [labels, scores];
        
        end

        function [ax, f] = plot(self, kwargs)
            %PLOT Default plotting function of PCAResult

            arguments
                self;
                kwargs.?PlotOptions;
                kwargs.Axes = [];
                kwargs.PCs uint8 = [1 2];
                kwargs.error_ellipses logical = false;
                kwargs.centered_axes logical = false;
                kwargs.color_order = [];
            end

            ax = [];

            pcax = kwargs.PCs;
            options = unpack(kwargs);

            % Call scatter function by default
            [ax, f] = self.scoresscatter(pcax, options{:});

        end

        function loadings = add_loadings_spectrum(self, pcax)
            %ADD_LOADINGS_SPECTRUM Generate a loadings spectrum and add it
            %to the parent container

            arguments
                self;
                pcax uint8 = 1;
            end
            
            loadings = self.gen_loadings_spectrum(pcax);
            self.append_sibling(loadings);
        end

        function plot_loadings_spectrum(self, pcax)
            %PLOPT_LOADINGS_SPECTRUM Plot / preview loadings spectrum,
            %without adding it to the parent container

            arguments
                self;
                pcax uint8 = 1;
            end

            specsimple = self.gen_loadings_spectrum(pcax);
            specsimple.plot();
            specsimple.delete();
        end


        function specsimple = gen_loadings_spectrum(self, pcax)
            %GEN_LOADINGS_SPECTRUM Generate a loadings spectrum
            %   Outputs a SpectrumSimple object.

            arguments
                self
                pcax uint8 = 1;
            end

            xdat = self.CoefsBase;
            ydat = self.Coefs(:, pcax);

            specsimple = SpectrumSimple( ...
                xdat, "cm-1", ...
                ydat, "a.u.", ...
                self);

            specsimple.name = "Loadings PC" + string(pcax(:)');
            specsimple.legend_entries = "PC" + string(pcax(:));

        end

        function add_context_actions(self, cm, node, app)
            %ADD_CONTEXT_ACTIONS Retrieve all (possible) actions for this
            %data item that should be displayed in the context menu
            %   This function adds menu items to the context menu, which
            %   link to specific context actions for this data item.
            %
            arguments
                self;
                cm matlab.ui.container.ContextMenu;
                node matlab.ui.container.TreeNode;
                app ramatguiapp;
            end

            % Add parent actions of DataItem
            add_context_actions@DataItem(self, cm, node, app);

            menu_item = uimenu(cm, Text="Print data table", MenuSelectedFcn=@(~,~) print_data_table(self));

            % Add specific context actions for PCAResult
            menu_item = uimenu(cm, Text="Brushing / Masking ...");

            ax = app.UIPreviewAxes;
            brushed = self.get_gui_brushed_data(ax);

            uimenu(menu_item, Text="Output brushed data as table", MenuSelectedFcn=@(~,~) self.dump_brushed(brushed));
            uimenu(menu_item, Text="Remove brushed data from mask", MenuSelectedFcn=@(~,~) self.remove_by_index_from_mask(brushed));
            uimenu(menu_item, Text="Plot brushed data locations in mask (can open multiple windows)", MenuSelectedFcn=@(~,~) self.plot_brushed(brushed));

            menu_item = uimenu(cm, Text="Export Scores ...");

            uimenu(menu_item, Text="All scores", MenuSelectedFcn=@(~,~) self.export_scores());
            uimenu(menu_item, Text="All scores (averaged per sample/replicate)", MenuSelectedFcn=@(~,~) self.export_scores(per_sample=true));
            uimenu(menu_item, Text="Scores to GraphPad Prism", MenuSelectedFcn= @(~,~) self.export_scores(optimized_for_prism=true, ask_pc=true));
            uimenu(menu_item, Text="Scores to GraphPad Prism (averaged per sample/replicate)", MenuSelectedFcn= @(~,~) self.export_scores(optimized_for_prism=true, per_sample=true, ask_pc=true));

            menu_item = uimenu(cm, Text="Print Scores ...");
            
            uimenu(menu_item, Text="All scores", MenuSelectedFcn=@(~,~) print_scores(self));
            uimenu(menu_item, Text="All scores (averaged per sample/replicate)", MenuSelectedFcn=@(~,~) print_scores(self, per_sample=true));
            uimenu(menu_item, Text="Scores to GraphPad Prism", MenuSelectedFcn= @(~,~) print_scores(self, optimized_for_prism=true, ask_pc=true));
            uimenu(menu_item, Text="Scores to GraphPad Prism (averaged per sample/replicate)", MenuSelectedFcn= @(~,~) print_scores(self, optimized_for_prism=true, per_sample=true, ask_pc=true));

            uimenu(cm, Text="Export ...", MenuSelectedFcn=@(~,~) ExportOptionsDialog(self));

            function print_data_table(self)
                table = self.source_table;
                dump_selection(table);
            end
            
            function print_scores(self, varargin)
                table = self.get_scores_summary(varargin{:});
                dump_selection(table);
            end

            function preview(~, ~, self, opts)
                self.preview_peak_table(min_prominence=opts.min_prom, negative_peaks=opts.neg_peaks);
            end

            function extract(~, ~, self, app, opts)
                self.add_peak_table(min_prominence=opts.min_prom, negative_peaks=opts.neg_peaks);
                update_data_items_tree(app, self.parent_container);
            end

        end

        function brushed = get_gui_brushed_data(self, ax)

            arguments
                self;
                ax = [];    % axes
            end

            scat = findobj(ax.Children, "Type", "Scatter");
            scat = flipud(scat);
            brushed = get(scat, "BrushData");
            brushed = find(horzcat(brushed{:}));

        end

        function dump_brushed(self, idx)
            if isempty(idx), return; end
            dump_selection(self.source_table(idx, :));
        end

        function remove_by_index_from_mask(self, idx)

            if isempty(idx), return; end
            t = self.source_table(idx, :);
            numb = height(t);
            out("Removing " + num2str(numb) + " subspectra.");

            for i = 1:numb
                group = t.group_index(i);
                spec_idx = t.spec_idx(i);
                subspec_idx = t.subspec_idx(i);

                self.source_data(group).specdata(spec_idx).mask_by_index(subspec_idx);
            end
        end

        function plot_brushed(self, idx)
            tbl = self.source_table(idx, :);
            [sds, ~, sdidx] = unique(tbl.reflink, "stable");

            for sd = sds(:)'
                ax = sd.mask.plot();
                ax.Children.CData = double(ax.Children.CData) .* 0.5;

                highlight_indices = tbl(tbl.reflink == sd, :).subspec_idx;
                ax.Children.CData(highlight_indices) = 2;
            end

        end

        function export_scores(self, options)
            %EXPORT Exports numerical data of specdata to specificied
            %output format

            arguments
                self;
                options.path string = "";
                options.format string = "";
                options.format_list string = self.format_list;
                options.pc int16 = 1;
                options.per_sample = false;
                options.ask_pc = false;
                options.optimized_for_prism = false;
            end

            % Prepare data
            export_table = self.get_scores_summary(pc=options.pc, optimized_for_prism=options.optimized_for_prism, per_sample=options.per_sample, ask_pc=options.ask_pc);

            % Ask for path
            if options.path == ""
                [file, path] = self(1).export_ui_dialog(format=options.format, format_list=self(1).format_list);
                options.path = fullfile(path, file);
            end

            % Make sure the entire file gets overwritten
            write_mode = "overwrite";
            if options.format == "xlsx", write_mode = "overwritesheet"; end

            % Write to file
            fprintf("\nWriting to file...\n");
            writetable(export_table, options.path, WriteMode=write_mode);
            fprintf("Finished.\n");
            
        end

        function format_list = get_export_formats(self)
            %GET_EXPORT_FORMATS Returns list of exportable formats.
            format_list = self.format_list;
        end
            
        
    end

    methods (Static)
        function wide_table = tall_to_wide(scores_tbl, options)
            %TALL_TO_WIDE Summary of this function goes here
            %   Detailed explanation goes here
        
            arguments
                scores_tbl table;
                options.column string = "";
            end
        
            number_of_groups = max(scores_tbl.group_index);
            number_of_samples = max(scores_tbl.sample_index);
            unique_group_indices = int32(unique(scores_tbl.group_index, "stable"));
            unique_group_names = string(unique(scores_tbl.group_name, "stable"));
        
            % Where is the scores data
            if options.column == ""
                options.column = string(scores_tbl.Properties.VariableNames(end));
            end
        
            % Preallocate array
            wide_table = nan(number_of_samples, number_of_groups);
        
            for group = unique_group_indices(:)'
                group_average_scores = scores_tbl.(options.column)(scores_tbl.group_index == group);
                wide_table(1:size(group_average_scores,1), group) = group_average_scores;
            end

            % Remove extra allocated nans
            wide_table(all(isnan(wide_table),2),:) = [];

            % Create table
            wide_table = array2table(wide_table, VariableNames=unique_group_names);

        end
    end
end

