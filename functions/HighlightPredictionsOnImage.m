function TCIOverlay = HighlightPredictionsOnImage(TCI, Prediction, Mask)
    
    CMapJet = jet(256);
    PredictionJet = reshape(CMapJet(uint8(255.*Prediction)+1,:), size(TCI));
    ColorMask = cat(3,Mask,Mask,Mask);
    TCIOverlay = TCI;
    TCIOverlay(ColorMask) = 0.3 * TCI(ColorMask) + 0.7 * PredictionJet(ColorMask);

end