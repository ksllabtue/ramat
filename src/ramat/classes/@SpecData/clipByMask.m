function out = clipByMask(self, binaryMask, options)
    %CLIP_BY_MASK Clips SpecData by a mask
    %   binaryMask should
    
    arguments
        self SpecData;
        binaryMask;
        options.Clip = true;
    end

    out = [];

    if isempty(binaryMask)
        out = self.Data;

    end

    multiplemasks = false;

    if (class(binaryMask) == "Mask" || iscell(binaryMask))
        if numel(binaryMask) > 1
            multiplemasks = true;
            
            % Providing multiple masks at once. Make sure mask can be unambigeously appended to spectral data
            if (numel(binaryMask) ~= numel(self))
                % Number of masks and spectral data do not correspond
                return

            end
        end
    end

    % Providing single mask
    if ~multiplemasks
        switch class(binaryMask)
            case "double"
                mask = getnanmask(binaryMask);
            case "single"
                mask = getnanmask(binaryMask);
            case "logical"
                mask = getnanmask(binaryMask);
            case "cell"
                mask = getnanmask(binaryMask{1});
            case "Mask"
                mask = getnanmask(binaryMask.Data);
        end
    end
    
        
    for i = 1 : numel(self)
        % For every instance of SpecData
        
        % Providing multiple masks
        if multiplemasks
            if class(binaryMask) == "Mask"
                % Mask Class provided
                mask = getnanmask( binaryMask(i).Data );

            elseif iscell(binaryMask)
                % Multiple masks stored within a cell array.
                mask = getnanmask( binaryMask{i} );

            end
        end
        
        data = self(i).Data;
        
        try
            data = data .* mask;
        catch
            error('Could not apply mask.');
        end
        
        % Overwrite data?
        if options.Clip == true
            self(i).Data = data;
        else
            out = data;
        end

    end

    function nanmask = getnanmask(mask)
        %GETNANMASK Converts mask to 1s and NaNs

        nanmask = double( mask );
        nanmask( mask == 0 ) = NaN;

    end
    
end

