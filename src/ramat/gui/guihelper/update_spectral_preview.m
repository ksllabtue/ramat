function update_spectral_preview(dc, ax)
    %UPDATE_SPECTRAL_PREVIEW

    arguments
        dc DataContainer = [];
        ax matlab.ui.control.UIAxes = [];
    end

    % Update the spectral preview, when axes are provided
    if ~isempty(ax)
        dc.plot(Axes=ax, Preview=true);
    end

end