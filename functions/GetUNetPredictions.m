function Predictions = GetUNetPredictions(TestImages, model)

    % create predictions array
    Predictions = zeros(size(TestImages,1), size(TestImages,2), size(TestImages,4));
    
    % make predictions for each sample
    for i = 1:size(Predictions,3)
        Prediction = predict(model, TestImages(:,:,:,i));
        Predictions(:,:,i) = squeeze(Prediction(:,:,2));
    end
    
    % prune unnecessary dimensions
    Predictions = squeeze(Predictions);
end