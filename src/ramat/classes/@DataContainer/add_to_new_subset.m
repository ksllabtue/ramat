function subsetHandle = add_to_new_subset(self)
    %ADD_TO_NEW_SUBSET
    
    % Get Project
    prj = self(1).parent_project;
    
    % Add to new analysis subset
    subsetHandle = prj.add_analysis(self);
end

