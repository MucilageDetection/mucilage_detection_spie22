function bidx = GetBandIndex(BandName, BandNames)  
    bidx = cellfun(@(y) strcmp(y, BandName), BandNames, 'UniformOutput', 1);
end