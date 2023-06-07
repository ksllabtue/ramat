classdef PeakMarker < handle
    
    properties
        x;
        y;
        neg;
        text;
        marker;
        dbg_box;
        parent;
        precision = 0;
        yshift = 0;
        fontsize = 14;
    end

    properties (Access=private)
        down_marker_symbol = "▼";
        up_marker_symbol = "▲";
        iter_limit = 100;
    end

    properties (Dependent)
        prev;
        next;
        bbox;
        left;
        right;
        top;
        bottom;
        label;
    end

    methods
        function self = PeakMarker(ax,x,y,neg,options)
            arguments
                ax;
                x;
                y;
                neg = false;
                options.fontsize = 11;
            end

            self.x = x;
            self.y = y;
            self.neg = neg;
            self.parent = ax;
            self.fontsize = options.fontsize;

            self.attach_to_axes();

            self.text = text(ax,x,y,self.gen_label());
            self.text.HorizontalAlignment = 'center';
            self.text.FontWeight = "bold";
            self.text.FontSize = self.fontsize;

%             self.dbg_box = rectangle(ax, Position=self.bbox, EdgeColor=[1 0 0]);

            % Draw marker symbol
            if self.neg, markersymbol = self.up_marker_symbol;
            else, markersymbol = self.down_marker_symbol; end

            markersymbol_str = [markersymbol; ""];
            if self.neg, markersymbol_str = flipud(markersymbol_str); end

            self.marker = text(ax,x,y, markersymbol_str);
            
            self.marker.HorizontalAlignment = 'center';
        end

        function attach_to_axes(self)
            ax = self.parent;

            ax.DeleteFcn = @(src,~) PeakMarker.delete_with_axes(src);
            if isfield(self.parent.UserData, "peakmarkers")
                self.parent.UserData.peakmarkers(end+1) = self;
                return;
            else
                self.parent.UserData.peakmarkers = self;
            end
        end


        function status = collide(self, other)
            arguments
                self PeakMarker;
                other PeakMarker;
            end

            % Reduce collision chance by reducing font size a bit
            self.text.FontSize = round(self.fontsize/2);
            other.text.FontSize = round(self.fontsize/2);

            status = (self.left < other.right && self.right > other.left && self.top > other.bottom && self.bottom < other.top );

            % Reset
            self.text.FontSize = self.fontsize;
            other.text.FontSize = other.fontsize;
        end

        function run_iter_collision_check(self, i)
            %RUN_ITER_COLLISION_CHECK

            arguments
                self
                i = 0;
            end

            if (i > 100), return; end

            if isempty(self.next), return; end

            if collide(self, self.next)
                self.update();
                self.next.update();

                self.x = [self.x; self.next.x];
                self.y = [self.y; self.next.y];
                self.next.remove();
                self.update();
            end

            if ~isempty(self.next), self.next.run_iter_collision_check(i + 1); end
        end


        function bbox = get.bbox(self)
            
            bbox = [0 0 0 0];

            if ~isvalid(self.text), return; end

            bbox = self.text.Extent;
            bbox(4) = bbox(4)/2;
            bbox(2) = max(self.y);
        end

        function left = get.left(self), left = self.bbox(1); end
        function right = get.right(self), right = self.bbox(1) + self.bbox(3); end
        function top = get.top(self), top = self.bbox(2) + self.bbox(4); end
        function bottom = get.bottom(self), bottom = max(self.y); end

        function label = get.label(self)
            label = self.gen_label();
        end

        function str = gen_label(self)
            % Preallocate string array
            annotation_string = strings(numel(self.x),1); i = 1;
            
            % List wavenumbers
            for wavnum = self.x(:)'
                annotation_string(i) = sprintf("%.*f", self.precision, wavnum); i = i+1;
            end
            str = [annotation_string; ""; repmat("",[numel(self.x),1])];

            if self.neg, str = flipud(str); end
        end

        function update(self)
            self.text.Position(1) = mean(self.x);
            self.text.Position(2) = max(self.y) + self.yshift;
            self.text.String = self.gen_label();
%             self.dbg_box.Position = self.bbox;
        end

        function fix_shift(self, stack_shift)
            
            arguments
                self
                stack_shift double = [];
            end

            if ~isempty(stack_shift), self.yshift = stack_shift; end

            self.text.Position(2) = self.y + self.yshift;
            self.marker.Position(2) = self.y + self.yshift;
                        
        end

        function prev = get.prev(self)
            prev = [];

            idx = self.get_idx();
            if idx > 1, prev = self.parent.UserData.peakmarkers(idx-1); end
        end

        function next = get.next(self)
            next = [];

            idx = self.get_idx();
            if idx == 0, return; end
            if idx < numel(self.parent.UserData.peakmarkers), next = self.parent.UserData.peakmarkers(idx+1); end
        end

        function idx = get_idx(self)
            idx = 0;
            if isempty(self.parent), return; end

            idx = find(self.parent.UserData.peakmarkers == self, 1);
        end

        function remove(self)
            idx = self.get_idx();

            if idx ~= 0, self.parent.UserData.peakmarkers(idx) = []; end

            self.delete();
        end

        function delete(self)

            for s = self(:)'
                s.text.delete();
%             self.dbg_box.delete();
%             self.marker.delete();
                s.delete();
            end
        end

    end

    methods (Static)
        function delete_with_axes(ax)
            
            if ~isfield(ax.UserData, "peakmarkers"), return; end

            ax.UserData.peakmarkers.delete();
            ax.UserData = rmfield(ax.UserData, "peakmarkers");

            
        end
    end

end