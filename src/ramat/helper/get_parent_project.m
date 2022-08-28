function prj = get_parent_project(self)
    %GET_PARENT_PROJECT Retrieve handle of top-level parent (a project)
    %   Traverses parent until project is found.
    
    prj = self;
    i = 0;
    limit = 20;

    while (class(prj) ~= "Project")
        prj = prj.parent;
        i = i + 1;
        if i > limit
            throw(MException('Ramat:UI',"Could not find figure"))
        end
    end
end
