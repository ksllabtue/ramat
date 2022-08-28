function updateDataPreview(app, data)
%UPDATEDATAPREVIEW Deprecated: Update the preview pane
%   Deprecated: use plot method of DataContainer instead
            
    if isempty(data)
        % Nothing has been selected

        return;
    end
    
    if ~(all( vertcat( data.dataType ) == "SpecData" ) || (numel(data) == 1 && data.dataType == "ImageData" ))
        % Non-uniform data types have been selected

        return;

    end
    

    % Get axes handles
    ax = app.UIPreviewAxes;
    cla(ax, 'reset');
    
    switch data(1).dataType
        case "SpecData"
            % Set-up Axes
            ax.PlotBoxAspectRatioMode = 'auto';
            ax.DataAspectRatioMode = 'auto';
%             ax.CameraUpVector = [0 1 0];
            ax.XLimMode = 'auto';
            ax.YLimMode = 'auto';
            ax.YDir = 'normal';
            ax.XTickMode = 'auto';
            ax.YTick = [];
            
            % Set Labels
            ax.XLabel.String = 'Raman Shift [cm^-^1]';

            % Hold for multiple data
            hold(ax, 'on');

            for i = 1:numel(data)
                dat = data(i);

                xdat = dat.Graph;
                ydat = dat.DataPreview;

                plot(ax, xdat, ydat);
            end

            % Release hold
            hold(ax, 'off');
            
        case "ImageData"
            % Plot first
            imagesc(ax, data.Data.Data );
            
            % Set-Up Axes
            ax.DataAspectRatio = [1 1 1];
            ax.XDir = 'normal';
            ax.YDir = 'normal';
            
%             ax.XTick = [];
%             ax.YTick = [];
%             ax.XAxis.Label.delete();
%             ax.YAxis.Label.delete();
% 
%             ax.XLim = [0.5, data.XSize + 0.5];
%             ax.YLim = [0.5, data.YSize + 0.5];

    end
            
end


