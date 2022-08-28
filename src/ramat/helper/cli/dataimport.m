function dataimport()
    
    global prj;
    
    data = importRaman();
    
    prj.append_data(data);
    
end