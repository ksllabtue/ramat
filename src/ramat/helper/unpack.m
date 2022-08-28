function cell_kwargs = unpack(kwargs)
    %UNPACK Provide pythonic kwargs unpacking
    %   Basically returns a cell array and ensures that no input can be
    %   unpacked as well.
    %   
    %   Usage:
    %   kwargs = unpack(kwargs);
    %   function(kwargs{:});

    if ~isempty(kwargs)
        cell_kwargs = namedargs2cell(kwargs);
    else
        cell_kwargs = cell.empty();
    end
end

