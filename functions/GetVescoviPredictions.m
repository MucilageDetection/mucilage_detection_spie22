function Predictions = GetVescoviPredictions(TestImages)
    
    % reshape data as Width*Height*SampleCount * BandLength
    TestImages1D = reshape(permute(TestImages, [1 2 4 3]), [], size(TestImages,3));

    %% compute vescovi score M = (0.5*(B('8A')+B('03')) - B('02')) ./ B('11');
    VescoviIndex = GetVescoviIndex(TestImages1D);
    
    %% make the index useful
    MucilageMinMax = [-2,0.45];
    VescoviIndex = min(max(MucilageMinMax(1), VescoviIndex), MucilageMinMax(2));
    Predictions = squeeze(interp1(MucilageMinMax, [0 1], VescoviIndex));
    
    % reshape predictions into 2d space
    Predictions = reshape(Predictions, [size(TestImages, 1), size(TestImages, 2), size(TestImages, 4)]);
end