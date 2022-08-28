function updateScoresScatterPlot(app)
%UPDATESCORESSCATTERPLOT
%   TO-DO:
%   - Implement into single plot method

    pcx = app.PCXSpinner.Value;
    pcy = app.PCYSpinner.Value;

    pcares = app.prj.get_active_pca_result();
    if isempty(pcares), return; end

    ax = app.UIPreviewAxes;

    % Update preview
    pcares.scoresscatter([pcx pcy], ...
        Axes=ax, ...
        ErrorEllipse=app.PCAErrorEllipseCheckBox.Value);
end

