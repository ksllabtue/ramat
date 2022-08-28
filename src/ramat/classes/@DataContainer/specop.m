function specop(self, operation, kwargs)
    %SPECOP Perform spectral operation on spectral data of datacontainer
    %   Wrapper function for spectral operations on spectral data

    arguments
        self DataContainer;
        operation string = "";
        kwargs struct = [];
    end

    % Do python-like unpacking of kwargs
    kwargs = unpack(kwargs);

    num_dat = numel(self);

    if any(operation == ["sum"; "mean"; "multiply"; "subtract"])
        if ~all(self.dataType == "SpecData"), return; end

        

    end

    if any(operation == ["trim"; "normalize"])
        for i = 1:num_dat
    
            if isempty(self.Data)
                continue;
            end
    
            % Only perform operations on spectral data
            if (self(i).dataType ~= "SpecData")
                continue;
            end
    
            fprintf("Performing operation %s on %d/%d", operation, i, num_dat);
    
            switch operation
                case "trim"
                    self(i).Data.trimSpectrum(kwargs{:});
                case "normalize"
                    self(i).normalizeSpectrum(kwargs{2}, kwargs{4});
            end
    
        end
    end
end