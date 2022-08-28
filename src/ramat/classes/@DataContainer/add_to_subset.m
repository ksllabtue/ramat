function add_to_subset(self, subsetHandle, new_group_name)
    %ADD_TO_SUBSET
    % Adds the current dataset to an existing analysis subset

    arguments
        self;
        subsetHandle Analysis;
        new_group_name string = "";
    end

    if (new_group_name == "")
        new_group_name = self(1).parent.name;
    end
    
    subsetHandle.append_data(self, new_group_name);
end

