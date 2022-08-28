function pcaresult = groupedPCA(self, range)
    %GROUPEDPCA Compute PCA of spectral data in groups
    %   Detailed explanation goes here
       
    % Get handles of instances of DataContainer() within these groups.
    dch = vertcat(self.Children);
    
    % Get handles of instances of SpecData()
    data = dch.getDataHandles('SpecData');
    
    if nargin > 1
        pcaresult = data.calculatePCA(range);
    else
        pcaresult = data.calculatePCA();
    end
    
    % Calculate number of spectra for every group. Since NaN-spectra are
    % omitted by PCA, we need to exclude these.
    num_spectra = self.countGroupFlatDataSizes('omitnan');
    group_name = transpose( {self.Name} );
    
    G = table(group_name, num_spectra);
    pcaresult.Groups = G;
    
end

