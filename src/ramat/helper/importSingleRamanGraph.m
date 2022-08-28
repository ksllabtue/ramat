function out = importSingleRamanGraph(varargin)
%IMPORTSINGLERAMANGRAPH
%   Import single Raman Data Item that has been exported with the Matlab
%   exporter from WITEC
%
%   To-do:
%   - move corrections to separate functions
%   - make excitation wavelength variable

filename = varargin{1};
consoleOutput = true;

% GUI handle for the output stream has been given.
if (nargin == 2)
    app = varargin{2};
    consoleOutput = false;
end

%% LOAD DATA FILE
data = load(filename);
fields = fieldnames(data);
data = data.(fields{1,1});
name = data.name;

% Update on progress
writeBuffer = sprintf('Imported: %s',name);
if (consoleOutput == true)
    fprintf('%s', writeBuffer);
else
    app.StatusTextArea.Value = [app.StatusTextArea.Value; writeBuffer];
    drawnow;
end
        
[nSpectra, wavResolution] = size(data.data);

writeBuffer = sprintf('\t N = %d\n',nSpectra);
if (consoleOutput == true)
    fprintf('%s', writeBuffer);
else
    app.StatusTextArea.Value = [app.StatusTextArea.Value; writeBuffer];
    drawnow;
end

% Default excitation wavelength
wavExcitation = 532.154;


%% CORRECT X-AXIS

xDataRaw = data.axisscale{2,1}';

% Convert to Wavenumbers
xUnits = data.axisscale{2,2};
writeBuffer = sprintf('X UNITS: %s\n',xUnits);
if (consoleOutput == true)
    fprintf('%s', writeBuffer);
else
    app.StatusTextArea.Value = [app.StatusTextArea.Value; writeBuffer];
    drawnow;
end

if strcmp(xUnits,'nm')
    xData = (1./wavExcitation - 1./xDataRaw) .* 1e7;
    writeBuffer = sprintf('x units converted to relative wavenumbers (1/cm)\n');
    if (consoleOutput == true)
        fprintf('%s', writeBuffer);
    else
        app.StatusTextArea.Value = [app.StatusTextArea.Value; writeBuffer];
        drawnow;
    end

end
if strcmp(xUnits,'rel. 1/cm')
    xData = xDataRaw;
end
if strcmp(xUnits,'1/cm')
    warning('X UNITS ARE ABSOLUTE WAVENUMBERS. Could lead to inverted graphs.');
    
    if (consoleOutput == false)
        writeBuffer = 'X UNITS ARE ABSOLUTE WAVENUMBERS. Could lead to inverted graphs.';
        app.StatusTextArea.Value = sprintf('%s%s', app.StatusTextArea.Value{:},writeBuffer);
        drawnow;
    end
    
end

%% DATA CORRECTION

yDataRaw = double(data.data');

% OMIT FIRST PART?
xData = xData(107:942,:);
yDataRaw = yDataRaw(107:942,:);
wavResolution = 836;

% --- let trim function handle this

yData = yDataRaw - repmat(min(yDataRaw),wavResolution,1);

% Remove Baseline and Normalize Spectrum
yData = msbackadj(repmat(xData,1,nSpectra),yData, ...
    'WindowSize', 200, ...
    'StepSize', 200, ...
    'RegressionMethod', 'pchip', ...
    'EstimationMethod', 'quantile', ...
    'QuantileValue', 0.10);
yData = yData ./ sum(yData);

%% Create DataContainer object

out = DataContainer();

out.name = name;
out.xUnits = xUnits;
out.xDataRaw = xDataRaw;
out.yDataRaw = yDataRaw;
out.nSpectra = nSpectra;
out.imageSize = data.imagesize;
out.imageAxisScale = data.imageaxisscale;

out.addSpecData('Raw Data', xDataRaw, yDataRaw);
out.addSpecData('Corrected', xData, yData);

end