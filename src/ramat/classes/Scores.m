classdef Scores < DataItem
    %SCORES

    properties
        data struct = [];
        parent_pca;
        pcaxes;
    end

    properties (SetAccess = private)
        Type = "Scores";
    end

    properties (SetAccess = private, GetAccess = private)
        format_list = ["csv";"mat";"xlsx"];
    end

    methods
        function self = Scores(scores, pcax, grouping, names)
            %SCORES Create instance based on PCA scores

            arguments
                scores double;
                pcax uint32;
                grouping uint32;
                names string;
            end

            % Take scores belonging to the given pc axis
            scores = scores(:, pcax);

            % Accumulate by grouping into a struct
            scores = accumarray(grouping, scores, [], @(x) {x});
            names = cellstr(names);
            data = cell2struct([names, scores], {'names', 'scores'}, 2);

            self.data = data;
            self.pcaxes = pcax;

        end

        function t = table(self)
            %TABLE Output data as table

            t = struct2table(self.data);
        end

        function plot(self)
            swarmchart()
        end
    end
end