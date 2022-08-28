function plotSpectrum(varargin)


    if (nargin == 4)
        appHandle = varargin{4};
        ax = appHandle.UIAxes;
    elseif (nargin == 3)
        f = figure;
        ax = axes('Parent', f);
    end

    cla(ax, 'reset');

    groupingTable = varargin{1};
    dataTable = varargin{2};
    plotOptions = varargin{3};

    groupLengths = uint32(groupingTable.Fun_nSpectra);
    nGroups = height(groupingTable);

    shift = 0;
    if strcmp(plotOptions.Type, 'Stacked')
        shift = plotOptions.StackDistance;
    end

    % Get MATLAB colour palette
    co = ax.ColorOrder;

    hold(ax, 'on');

    j = 1;
    for i = 1:nGroups
        l = groupLengths(i);

        % Cycle through colour palette
        colorIndex = mod(i-1, length(co)) + 1;
        co_i = co(colorIndex, :);

        try
            xData = [dataTable.xData{j : l+j-1}];
            yData = [dataTable.yData{j : l+j-1}];
        catch
            warning('Could not concatenate data from group %i',i);
            xData = [0 0];
            yData = [0 0];
        end

        % Shift plots for stacked plot
        yData = yData - (i - 1)*shift;

        plot(ax, xData, yData, 'Color', co_i);

        j = j + l;
    end

    % Set Axes
    xlabelText = 'Raman Shift [cm^-^1]';
    ylabelText = 'Intensity [a.u.]';
    ax.XLabel.String = xlabelText;
    ax.YLabel.String = ylabelText;
    % xlabel(xlabelText,'FontWeight','bold');
    % ylabel(ylabelText,'FontWeight','bold');
    % set(ax,'FontSize',14);
    ax.XAxisLocation = 'bottom';
    ax.YAxisLocation = 'left';

    % Set Legend
    groupNames = groupingTable.GroupName;
    legend(ax,groupNames);

    hold(ax, 'off');

end