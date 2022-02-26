%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelTrainValidationTestSets, 'TestImageSet');

%% get the test set
[TestImages,  TestLabels]  = GetImageSet(TestImageSet);

%% get UNet model
load(configuration.UNetTrainedNetwork);
UNetTestPredictions = GetUNetPredictions(TestImages, UNetNetwork);

%% get Linear Regressor model
load(configuration.LinearRegressorTrainedNetwork);
LinearRegressorTestPredictions = GetRandomForestPredictions(TestImages, LinearRegressorNetwork);

%% get Random Forest model
load(configuration.RandomForestTrainedNetwork);
RandomForestTestPredictions = GetRandomForestPredictions(TestImages, RandomForestNetwork);

%% get Vescovi predictions
VescoviIndexTestPredictions = GetVescoviPredictions(TestImages);

%% get the results
AllLabels = [];
AllPredictions = [];
for idx = 1:size(TestLabels, 3)

    TestLabel = reshape(TestLabels(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    UNetPrediction = reshape(UNetTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    LinearRegressorPrediction = reshape(LinearRegressorTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    RandomForestPrediction = reshape(RandomForestTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    VescoviIndexPredictions = reshape(VescoviIndexTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    
    % save the result into array
    AllLabels = [AllLabels; TestLabel];
    AllPredictions = [AllPredictions; [UNetPrediction, LinearRegressorPrediction, RandomForestPrediction, VescoviIndexPredictions]];
end

%% compute the ROC
[TP, FP, FN, TN] = GetROC(AllLabels, AllPredictions, 100);

%% display results
TPR = TP ./ (TP + FN);
FPR = FP ./ (FP + TN);

AUC = zeros(size(TPR, 2), 1);
for c = 1:size(TPR, 2)
    AUC(c) = abs(trapz(FPR(:,c),TPR(:,c)));
end

FigH = figure('Position', get(0, 'Screensize'));
plot(FPR, TPR, 'LineWidth', 3);
ax=gca;
ax.FontSize = 16;

xlabel('False Positive Rate','FontName', 'Courier', 'FontWeight', 'b')
ylabel('True Positive Rate','FontName', 'Courier', 'FontWeight', 'b')
grid minor;
legend(...
    sprintf('UNet              (AUC: %5.3f)', AUC(1)),...
    sprintf('Linear Regressor  (AUC: %5.3f)', AUC(2)),...
    sprintf('Random Forest     (AUC: %5.3f)', AUC(3)),...
    sprintf('Vescovi Index     (AUC: %5.3f)', AUC(4)),...
    'FontName', 'Courier', 'FontWeight', 'b', 'Location', 'SouthEast');
saveas(FigH, 'results','epsc');