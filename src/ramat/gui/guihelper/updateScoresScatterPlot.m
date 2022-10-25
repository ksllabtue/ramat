function updateScoresScatterPlot(app)
%UPDATESCORESSCATTERPLOT
%   TO-DO:
%   - Implement into single plot method

    pcx = app.PCXSpinner.Value;
    pcy = app.PCYSpinner.Value;
    pcs = [pcx, pcy];

    error_ellipses = app.PCAErrorEllipseCheckBox.Value;


    pcares = app.prj.get_active_pca_result();
    if isempty(pcares), return; end

    ax = app.UIPreviewAxes;

    % Update preview
    pcares.plot(...
        Axes=ax, ...
        PCs=pcs, ...
        error_ellipses=error_ellipses);
end

