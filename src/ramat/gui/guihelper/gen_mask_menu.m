function gen_mask_menu(specdat, cm)
    
    arguments
        specdat SpecData;
        cm matlab.ui.container.ContextMenu;
    end
  
    mm = uimenu(cm, Text="Masking...");

    uimenu(mm, Text="<Unset mask>", MenuSelectedFcn=@(~,~) setmask(specdat, []));
    uimenu(mm, Text="<Add random selection mask>", MenuSelectedFcn=@(~,~) specdat.add_random_mask(100, ask_input=true));

    % get masks
    dataitems = specdat.parent_container.children;
    masks = dataitems.filter_data_type("Mask");
    if isempty(masks), return; end

    for mask = masks(:)'
        uimenu(mm, Text="Mask", MenuSelectedFcn=@(~,~) setmask(specdat, mask));
    end

    function setmask(spec, mask)
        if isempty(mask)
            spec.unset_mask();
        else
            spec.set_mask(mask);
        end
    end

end