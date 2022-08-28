classdef Cursor < handle
    %CURSOR (Data Class) Cursor for Large Area Scans
    
    properties
        x = 1;
        y = 1;
        size = 1;
        parent = [];
    end

    properties (Dependent)
        pgon;
        shape;
        binary_mask;
        mask_coords;
    end
    
    methods
        function self = Cursor(parent)
            %CURSOR Construct an instance of this class
            %   Arguments:
            %   - parent    (optional)  parent specdat object

            arguments
                parent SpecData = [];
            end

            % Set spectral data object as parent
            self.parent = parent;
        end

        function setx(self, xval)

            % Round to nearest integer
            xval = round(xval);

            if isempty(self.parent)
                self.x = xval;
            end

            % Constrain new value to boundaries of parent
            if xval < 1
                self.x = 1;
            elseif xval > self.parent.XSize
                self.x = self.parent.XSize;
            else
                self.x = xval;
            end

        end

        function sety(self, yval)

            % Round to nearest integer
            yval = round(yval);

            if isempty(self.parent)
                self.y = yval;
            end

            % Constrain new value to boundaries of parent
            if yval < 1
                self.y = 1;
            elseif yval > self.parent.YSize
                self.y = self.parent.YSize;
            else
                self.y = yval;
            end

        end

        function pgon = get.pgon(self)
            %PGON Get polyshape

            xcords = ([0 1 1 0] - .5) .* (2*self.size-1) + self.x;
            ycords = ([0 0 1 1] - .5) .* (2*self.size-1) + self.y;

            pgon = polyshape(xcords, ycords);
        end

        function shape = get.shape(self)
            %SHAPE Get shape matrix (for convolutions)

            dim = 2*self.size - 1;

            shape = ones(dim, dim);
        end

        function mask_shape = get.binary_mask(self)
            %GET_MASK Generates mask

            [row, col] = self.get_clipped_extents();

            mask = zeros(self.parent.YSize, self.parent.XSize);
            mask(row, col) = 1;

            mask_shape = logical(mask);
        end

        function mask_ext = get.mask_coords(self)
            [row, col] = self.get_clipped_extents();

            mask_ext.rows = [min(row), max(row)]; 
            mask_ext.cols = [min(col), max(col)];
        end

        function [row, col] = get_clipped_extents(self)
            %GET_CLIPPED_EXTENTS Crops masks to border of spectral data

            [row, col] = find(self.shape);
            row = row + self.y - self.size;
            col = col + self.x - self.size;

            row(row<1) = 1;
            row(row>self.parent.YSize) = self.parent.YSize;
            col(col<1) = 1;
            col(col>self.parent.XSize) = self.parent.XSize;

        end

        function increase(self, amount)
            %INCREASE Increase size of cursor

            arguments
                self Cursor;
                amount {mustBePositive, mustBeInteger} = 1;
            end

            if (self.size + amount > self.parent.XSize / 2 || self.size + amount > self.parent.YSize / 2)
                return;
            end

            self.size = self.size + amount;

        end

        function decrease(self, amount)
            %DECREASE Decrease size of cursor

            arguments
                self Cursor;
                amount {mustBePositive, mustBeInteger} = 1;
            end

            if (self.size - amount < 1)
                return;
            end

            self.size = self.size - amount;

        end


    end
end

