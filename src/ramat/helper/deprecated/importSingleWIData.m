function dataObject = importSingleWIData(widO, kwargs)
    % IMPORTSINGLEWIDATA parses a WID object (widO) into RAMAT objects.

    arguments
        widO;
        kwargs.retain_original = false;
        kwargs.normalize = false;
        kwargs.remove_offset = false;
        kwargs.remove_baseline = false;
        kwargs.remove_baseline_opts struct = [];
    end

    % Python-like kwargs unpacking
    %kwargs = unpack(kwargs);
    
    % Create a DataContainer object
    dataObject = DataContainer();
    item_name = widO.Name;
    dataObject.Name = item_name;
    
    fprintf('\n%s\n', dataObject.DisplayName);
    
    % Append data item to data container based on data type
    switch widO.Type
        case 'TDGraph'
            
            % Display dimensions
            switch widO.SubType
                case 'Point'
                    fprintf('## Single Spectrum\n');
                case 'Image'
                    fprintf('## %i x %i Area Scan\n', widO.Info.XLength, widO.Info.YLength);
            end

            % Excitation wavelength
            excitation_wavlen = widO.Info.GraphInterpretation.Data.TDSpectralInterpretation.ExcitationWaveLength;

            % Convert to double and store in correct order
            data = double(widO.Data);
            data = permute(data, [2 1 3]);

            % Graph unit
            graph_unit = widO.Info.GraphUnit;
            
            %% RAW DATA
            
            % Keep copy of original data
            if kwargs.retain_original
                if any(kwargs.remove_offset, kwargs.remove_baseline, kwargs.normalize)

                    % Create SpecData instance
                    specdat = SpecData( ...
                        name=item_name, ...
                        graphbase=widO.Info.Graph, ...   
                        data=data, ...
                        graphunit=graph_unit, ...
                        dataunit=widO.Info.DataUnit);
                    
                    % Add additional info
                    specdat.ExcitationWavelength = excitation_wavlen;
                    specdat.Description = "Raw Data";
             
                    % Append raw (=as-is) spectral data to DataContainer
                    dataObject.appendDataItem(specdat);

                end
            end
            
            %% PROCESSED DATA
            % Process data
            
            % Convert graph units if necessary
            switch graph_unit
                case 'Raman Shift (rel. 1/cm)'
                    graph_data = widO.Info.Graph;
                case 'Nanometers (nm)'
                    graph_data = (1./excitation_wavlen - 1./ widO.Info.Graph) .* 1e7;
                otherwise
                    error('Could not read graph unit for %s', widO.Name);
            end
                        
            
            % Create SpecData Object
            specdat = SpecData( ...
                item_name, ...
                graph_data, ...
                data, ...
                graph_unit, ...
                widO.Info.DataUnit);
            
            specdat.ExcitationWavelength = excitation_wavlen;
            specdat.Description = "Imported Data";
            
            % Store meta information
            specdat.X = widO.Info.X;
            specdat.Y = widO.Info.Y;
            specdat.Z = widO.Info.Z;
            
            % Trim Data?
            % specdat_obj.trimData(trimStart, trimEnd)
            
            % Remove Offset
            if kwargs.remove_offset
                fprintf('-- Removing Offset ...\n');
                specdat.removeBaseline('constant');
            end
            
            % Remove Background
            if kwargs.remove_baseline
                fprintf('-- Removing Baseline ...\n');
                specdat = specdat.removeBaseline();
            end
            
            % Normalize Data
            if kwargs.normalize
                fprintf('-- Normalising Spectrum ...\n');
                specdat = specdat.normalizeSpectrum();
            end
            
            % Append SpecData to Data Container
            dataObject.appendDataItem(specdat);
            
        case 'TDText'
            fprintf('## Text File\n');
            
            textdat = TextData(item_name, widO.Data);
            textdat.Description = "Imported Text";
            
            % Append to data container
            dataObject.appendDataItem(textdat);
            
        case 'TDBitmap'
            fprintf('## Image\n');
            
            imgdat = ImageData(item_name, widO.Data);
            imgdat.Description = "Imported Image";
            
            % Append to data container
            dataObject.appendDataItem(imgdat);
            
    end
        
end

