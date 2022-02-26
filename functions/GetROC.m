function [TP, FP, FN, TN] = GetROC(label, predictions, bins)
    
    % make the thresholds uniformly distributed
    thresholds = linspace(0, 1, bins - 2);
    thresholds = [-1, thresholds, 2];

    % Calculating the sensibility and specificity of each threshold
    TP = zeros(size(thresholds,1),size(predictions,2));
    FP = zeros(size(thresholds,1),size(predictions,2));
    FN = zeros(size(thresholds,1),size(predictions,2));
    TN = zeros(size(thresholds,1),size(predictions,2));
    
    % get the positive and negative samples
    class0 = predictions(label <= 0.5, :);
    class1 = predictions(label >  0.5, :);
        
    % compute ROC for each threshold
    for i = 1:length(thresholds)
        % for each algorithm
        for c = 1:size(predictions,2)
            % compute the confusion matrix
            TP(i,c) = length(find(class1(:,c) >= thresholds(i)));
            FP(i,c) = length(find(class0(:,c) >= thresholds(i)));
            FN(i,c) = length(find(class1(:,c) <  thresholds(i)));
            TN(i,c) = length(find(class0(:,c) <  thresholds(i)));
        end
    end
end