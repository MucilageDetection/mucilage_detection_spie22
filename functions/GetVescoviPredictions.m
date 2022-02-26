function Predictions = GetVescoviPredictions(TestImages)
    
    %% compute vescovi score M = (0.5*(B('8A')+B('03')) - B('02')) ./ B('11');
    VescoviIndex = (0.5 * (TestImages(:,:,7,:) + TestImages(:,:,2,:)) - TestImages(:,:,1,:)) ./ TestImages(:,:,8,:);
    
    %% make the index useful
    MucilageMinMax = [-2,0.45];
    VescoviIndex = min(max(MucilageMinMax(1), VescoviIndex), MucilageMinMax(2));
    Predictions = squeeze(interp1(MucilageMinMax, [0 1], VescoviIndex));

end