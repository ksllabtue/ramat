classdef ImageData < DataItem
    %IMAGEDATA 
    
    properties
        data;
    end
    
    properties (Dependent)
        XSize;
        YSize;
        ZSize;
        DataSize;
    end
    
    properties (SetAccess = private)
        Type = "ImageData";
    end
    
    methods
        function self = ImageData(name, data)
            %IMAGEDATA Construct an instance of this class
            %   Detailed explanation goes here
            
            arguments
                name string = "";
                data double = [];
            end
            
            self.name = name;
            self.data = data;
            
        end
        
        function xres = get.XSize(self)
            xres = size(self.data, 1);
        end
        
        function yres = get.YSize(self)
            yres = size(self.data, 2);
        end
        
        function zres = get.ZSize(self)
            % TO BE IMPLEMENTED
            zres = 1;
        end
        
        function datares = get.DataSize(self)
            datares = self.XSize * self.YSize * self.ZSize;
        end

        function icon = get_icon(self)
            %GET_ICON Overrides <DataItem>.icon dependent property.
            icon = "TDImage.png";
        end

        function [ax, f] = plot(self, kwargs)
            %PLOT

            arguments
                self;
                kwargs.?PlotOptions;
                kwargs.Axes = [];
            end

            % Cannot plot more than one image simultaneously
            if numel(self) > 1, return; end

            % Call plot at superclass, to properly set axes
            [ax, f] = self.plot_start(Axes=kwargs.Axes);

            % plot imagedata
            if numel(size(self.data)) == 3
                d = uint8(self.data);
                image(ax, d);
            else
                imagesc(ax, self.data);
            end

            % Set-Up Axes
            ax.DataAspectRatio = [1 1 1];
            ax.XDir = 'normal';
            ax.YDir = 'normal';
        end
        
    end
end
