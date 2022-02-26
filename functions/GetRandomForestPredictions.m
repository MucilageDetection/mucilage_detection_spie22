function Predictions = GetRandomForestPredictions(TestImages, model)
    % create predictions array
    Predictions = zeros(size(TestImages,1), size(TestImages,2), size(TestImages,4));
    
    % make predictions for each sample
    for i = 1:size(Predictions,3)
        TestImage = reshape(TestImages(:,:,:,i), [size(TestImages,1) * size(TestImages,2), size(TestImages, 3)]);
        Predictions(:,:,i) = reshape(predict(model, TestImage), [size(TestImages,1), size(TestImages,2)]);
    end
    
    % prune unnecessary dimensions
    Predictions = squeeze(Predictions);
end