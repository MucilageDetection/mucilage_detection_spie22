% return TCI image from the given bands
function TCI = GetTCIFromBands(TestImages, BandNames)

    R = TestImages(:,:,GetBandIndex('B04', BandNames),:);
    G = TestImages(:,:,GetBandIndex('B03', BandNames),:);
    B = TestImages(:,:,GetBandIndex('B02', BandNames),:);
    
    % create TCI in double
    TCID = cat(3, R, G, B);
    
    ReflectanceMax = 0.25;
    TCI = interp1([0 ReflectanceMax], [0 1], min(TCID, ReflectanceMax));
end