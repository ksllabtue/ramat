function ax = plot(self, opts)
%PLOT Default plotting method, overloads default plot function.
%   This is the default method to plot data within the DataContainer. It
%   only takes the data container as necessary input argument, additional
%   keyword arguments provide plotting options and axis handles.
%
%   Examples:
%
%   PLOT(dc) plots data stored within the Data attribute against the values
%   stored in the Graph attribute in a new figure window. dc can either be
%   a single instance of DataContainer with dataType "SpecData" or
%   "ImageData", or it can be an array of DataContainers, whose dataType is
%   exclusively "SpecData".
%
%   PLOT(dc, Axes=ax) does the same as above, but uses the axes handle as
%   target.

    arguments
        self;                           % DataContainer
        opts.?PlotOptions
        opts.Axes = [];               % Axes Handle
    end

    ax = [];
    
    % Check if something has been selected
    if isempty(self), return; end

    % Check if non-uniform data types have been selected
    if ~self.is_homogeneous_array(), return; end

    % Parse options and pass to plotting method
    opts = namedargs2cell(opts);

    % Get data items
    dat = self.get_data();

    % Plot
    [ax, f] = dat.plot(opts{:});

    % Create cursor
    assign_spectral_cursor(f, ax);

end

