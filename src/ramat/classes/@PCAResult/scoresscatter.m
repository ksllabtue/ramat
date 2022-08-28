function scoresscatter(pcaresult, pcax, options)
%SCORESSCATTER
%   Draw a scatter plot of the scores of the PCA Data along 2 principal
%   components (2D PCA)
%       pcaresult:  PCAResult() object
%       pcax:       2x1 integer array with the principal component axis numbers

    arguments
        pcaresult PCAResult;
        pcax uint8 = [1 2];
        options.Axes = []; % Handle to Axes, if empty a new figure will be created
        options.ErrorEllipse logical = false;
        options.CenteredAxes logical = true;
    end

    if isempty(pcaresult.source_data)
        % We need a grouping table to create a legend.
        
        num_spectra = size(pcaresult.Score, 1);
        pcaresult.source_data.name = "Ungrouped";
        pcaresult.source_data.accumsize = num_spectra;

    end
        
    groupLengths = vertcat(pcaresult.source_data.accumsize);
    nGroups = numel(pcaresult.source_data);
    
    % Define axes
    if isempty(options.Axes)
        f = figure;
        ax = axes('Parent',f);
    else
        if ( class(options.Axes) == "matlab.graphics.axis.Axes" || class(options.Axes) == "matlab.ui.control.UIAxes")
            ax = options.Axes;

            % Get parent figure
            f = get_parent_figure(ax);
            
            % Clear axes
            cla(ax);

            % Reset axes mode
            ax.XLimMode = 'auto';
            ax.YLimMode = 'auto';

        else
            warning("Invalid Axes Handle");
            return;
        end
    end

    % Make sure we don't have a cursor for this kind of plot
    unassign_spectral_cursor(f);
    
    % Get standard MATLAB plot colors
    co = get(ax,'ColorOrder');
    hold(ax, 'on');
    
    % Initialize graphics placeholder array
    s = gobjects(nGroups, 1);
    
    j = 1; % Score Index

    % Go through groups
    for i = 1:nGroups
        l = groupLengths(i);
        
        % Color for current item
        coidx = mod(i - 1, 6 ) + 1;
        color = co(coidx, :);

        % Plot scatter for every group
        % Invert Y-axis for compatibility with PCA function of ORIGIN.
        s(i) = scatter(ax, ...
            pcaresult.Score(j:l+j-1, pcax(1)), ...  % x-axis
            -pcaresult.Score(j:l+j-1, pcax(2)), ... % inv. y-axis
            45, ...                                 % size
            color, ...                              % color
            'filled');                              % marker type

        % Format Tooltips
        s(i).DataTipTemplate.DataTipRows(1).Label = sprintf("PC %d: ",pcax(1));
        s(i).DataTipTemplate.DataTipRows(2).Label = sprintf("PC %d: ",pcax(2));

        % Append Data Source reference
        if isfield(pcaresult.source_data, 'specdata')
            % Add handle to specdata
            s(i).UserData = pcaresult.source_data(i).specdata;
            
            % Create array of names for tooltips
            scattertags = vertcat(s(i).UserData.get_tags());

            % Add information to data tooltips
            s(i).DataTipTemplate.DataTipRows(end + 1) = dataTipTextRow("Spectrum: ", scattertags);

        end
        
        % Plot confidence ellipses
        if (options.ErrorEllipse)
            error_ellipse( ...
                pcaresult.Score(j:l+j-1, pcax(1)), ...
                -pcaresult.Score(j:l+j-1, pcax(2)), ...
                color, ...
                Axes=ax);
        end
        
        % Fast-forward in scores array by group length.
        j = j + l;
    end

    % Set Axes
    xlabelText = sprintf('PC%u: %.2g%%', pcax(1), pcaresult.Variance(pcax(1)));
    ylabelText = sprintf('PC%u: %.2g%%', pcax(2), pcaresult.Variance(pcax(2)));
    xlabel(ax, xlabelText,'FontWeight','bold');
    ylabel(ax, ylabelText,'FontWeight','bold');
    set(ax,'FontSize',14);
    ax.Box = 'on';

    % Make background transparent
    f.Color = [1 1 1];
    ax.Color = "none";

    % Position of axes
    if options.CenteredAxes
        ax.XAxisLocation = 'origin';
        ax.YAxisLocation = 'origin';
    else
        ax.XAxisLocation = 'bottom';
        ax.YAxisLocation = 'left';
    end
    
    % Make plot box square
    if (class(ax) == "matlab.ui.control.UIAxes")
        % For App Designer
        ax.PlotBoxAspectRatio = [1 1 1];
    elseif class(ax) == "matlab.graphics.axis.Axes"
        % For MATLAB >=2020a
        ax.PlotBoxAspectRatio = [1 1 1];
    else
        % For MATLAB <2020a
        ax.pbaspect = [1 1 1];
    end

    % Set Legend
    groupNames = vertcat(pcaresult.source_data.name);
    leg = legend(ax, s,groupNames);
    leg.Location = 'northeastoutside';


end

