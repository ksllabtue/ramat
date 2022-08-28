function updateappmgr(app, options)
    %UPDATEMGR
    %   Updates GUI Data Managers
    
    arguments
        app;
        options.Parts = [1, 2, 3]; % Parts to update
    end
    
    
    %% Update Data Manager
    
    if any(options.Parts == 1)

        update_data_mgr_tree(app);
            
    end % END PART 1

    %% Update Analysis Subsets
    
    if any(options.Parts == 2)
    
        tree = app.SubsetTree;

        % Clear Tree
        a = tree.Children;
        a.delete;

        for i = 1:numel(app.prj.analyses)
            subset = app.prj.analyses(i);

            subsetnode = uitreenode(tree, ...
                "Text", subset.display_name, ...
                "NodeData", subset);
        end
        
    end % END PART 2

    %% Update Analysis Items
    
    if any(options.Parts == 3)

        update_analysis_mgr_tree(app);
        
    end % END PART 3
    
end