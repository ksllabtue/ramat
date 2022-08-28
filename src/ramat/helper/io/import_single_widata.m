function datacon = import_single_widata(widO, kwargs)
    % IMPORT_SINGLE_WIDATA parses a WID object (widO) into RAMAT objects.

    arguments
        widO;
        kwargs.retain_original = false;
        kwargs.normalize = false;
        kwargs.remove_offset = false;
        kwargs.remove_baseline = false;
        kwargs.remove_baseline_opts struct = [];
        kwargs.gui = [];
        kwargs.processing = get_processing_options;
    end

    % Python-like kwargs unpacking
    %kwargs = unpack(kwargs);
    
    % Create a DataContainer object
    datacon = DataContainer();
    item_name = widO.Name;
    datacon.name = item_name;
    
    out(sprintf('\n%s', datacon.display_name), gui=kwargs.gui);
    
    % Append data item to data container based on data type
    switch widO.Type
        case 'TDGraph'
            
            % Display dimensions
            switch widO.SubType
                case 'Point'
                    out(sprintf('## Single Spectrum'), gui=kwargs.gui);
                case 'Image'
                    out(sprintf('## %i x %i Area Scan', widO.Info.XLength, widO.Info.YLength), gui=kwargs.gui);
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
            if kwargs.processing.retain_original
                if any(kwargs.processing.remove_offset, kwargs.processing.remove_baseline, kwargs.processing.normalize)

                    % Create SpecData instance
                    specdat = SpecData( ...
                        name=item_name, ...
                        graphbase=widO.Info.Graph, ...   
                        data=data, ...
                        graphunit=graph_unit, ...
                        dataunit=widO.Info.DataUnit);
                    
                    % Add additional info
                    specdat.excitation_wavelength = excitation_wavlen;
                    specdat.description = "Raw Data";
             
                    % Append raw (=as-is) spectral data to DataContainer
                    datacon.append_child(specdat);

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
            
            specdat.excitation_wavelength = excitation_wavlen;
            specdat.description = "Imported Data";
            
            % Store meta information
            specdat.x = widO.Info.X;
            specdat.y = widO.Info.Y;
            specdat.z = widO.Info.Z;
            
            % Trim Data?
            if kwargs.processing.trim
                out('-- Removing Offset ...', gui=kwargs.gui);
                specdat.trimSpectrum( ...
                    kwargs.processing.trim_opts.start, ...
                    kwargs.processing.trim_opts.end, ...
                    copy=false);
            end
            
            % Remove Offset
            if kwargs.processing.remove_offset
                out('-- Removing Offset ...', gui=kwargs.gui);
                specdat.remove_baseline('constant');
            end
            
            % Remove Background
            if kwargs.processing.remove_baseline
                out('-- Removing Baseline ...', gui=kwargs.gui);
                specdat.remove_baseline();
            end
            
            % Normalize Data
            if kwargs.processing.normalize
                out('-- Normalising Spectrum ...', gui=kwargs.gui);
                specdat.normalize_spectrum();
            end
            
            % Append SpecData to Data Container
            datacon.append_child(specdat);
            
        case 'TDText'
            out('## Text File', gui=kwargs.gui);
            
            textdat = TextData(item_name, widO.Data);
            textdat.description = "Imported Text";
            
            % Append to data container
            datacon.append_child(textdat);
            
        case 'TDBitmap'
            out('## Image', gui=kwargs.gui);
            
            imgdat = ImageData(item_name, widO.Data);
            imgdat.description = "Imported Image";
            
            % Append to data container
            datacon.append_child(imgdat);
            
    end
        
end

