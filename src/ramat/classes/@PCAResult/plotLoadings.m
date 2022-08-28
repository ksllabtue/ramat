function plotLoadings(self, pcax, options)
%PLOTLOADINGS Create Loadings plot
    
    arguments
        self;               % PCAResult Object
        pcax = 1;
        options.Axes = [];
    end

    f = figure;
    ax = axes('Parent',f);
    
    % Get standard MATLAB plot colors
    co = get(ax,'ColorOrder');
    hold(ax, 'on');
    
    % For every principal component
    for i = 1:length(pcax)
        % Color for current item
        coidx = mod(i - 1, 6 ) + 1;
        color = co(coidx, :);
        
        % Plot loadings for principal component
        plot(self.CoefsBase, ...
            self.Coefs(:,pcax(i)), ...
            LineStyle='-', ...
            Color=color);
            
        
    end

end