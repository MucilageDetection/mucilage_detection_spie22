function TCIOverlay = HighlightPredictionsOnImage(TCI, Prediction, Mask)
    
    CMapJet = jet(256);
    PredictionJet = reshape(CMapJet(uint8(255.*Prediction)+1,:), size(TCI));
    
    TCIOverlay = TCI;
    
    if isempty(Mask)
        Mask = true(size(Prediction));
    end

    ColorMask = cat(3,Mask,Mask,Mask);  
    TCIOverlay(ColorMask) = 0.1 * TCI(ColorMask) + 0.9 * PredictionJet(ColorMask);
end