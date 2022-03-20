%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

% get the images and labels
load(configuration.sentinel.TrainValidationTestSets, 'TrainImageSet');
[TrainImages,  TrainLabels]  = GetImageSet(TrainImageSet);

% set the model names
ModelNames = {'U-Net', 'Random Forest', 'Linear Regressor', 'Vescovi Index'};

%% get UNet model
load(configuration.UNetTrainedNetwork);
UNetTestPredictions = GetUNetPredictions(TestImages, UNetNetwork);

%% get Linear Regressor model
load(configuration.LinearRegressorTrainedNetwork);
LinearRegressorTestPredictions = GetLinearRegressorPredictions(TestImages, LinearRegressorNetwork);

%% get Random Forest model
load(configuration.RandomForestTrainedNetwork);
RandomForestTestPredictions = GetRandomForestPredictions(TestImages, RandomForestNetwork);

%% get Vescovi predictions
VescoviIndexTestPredictions = GetVescoviPredictions(TestImages);

%% get the results
AllLabelsCell = cell(size(TestLabels, 3), 1);
AllPredictionsCell = cell(size(TestLabels, 3), length(ModelNames));

for idx = 1:size(TestLabels, 3)

    % get the labels
    TestLabel = reshape(TestLabels(configuration.OutputRange, configuration.OutputRange, idx), [], 1);

    % get predictions of different models
    AllPredictionsCell{idx, 1} = reshape(UNetTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    AllPredictionsCell{idx, 2} = reshape(RandomForestTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    AllPredictionsCell{idx, 3} = reshape(LinearRegressorTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    AllPredictionsCell{idx, 4} = reshape(VescoviIndexTestPredictions(configuration.OutputRange, configuration.OutputRange, idx), [], 1);
    
    % save the result into array
    AllLabelsCell{idx} = TestLabel;
end

%% compute the ROC
[TP, FP, FN, TN, thresholds] = GetROC(cell2mat(AllLabelsCell), cell2mat(AllPredictionsCell), 100);

%% display results
TPR = TP ./ (TP + FN);
FPR = FP ./ (FP + TN);

% print TPR at fixed FPR
FalsePositiveRate = 0.05;
TruePositiveRate = zeros(1,length(ModelNames));
Thresholds = zeros(1,length(ModelNames));
for mm = 1:length(ModelNames)
    % get uniques
    [fpr, fprIDX, ~] = unique(FPR(:,mm));
    tpr = TPR(fprIDX,mm);
    thres = thresholds(fprIDX);
    TruePositiveRate(mm) = interp1(fpr, tpr, FalsePositiveRate);
    Thresholds(mm) = interp1(fpr, thres, FalsePositiveRate);
    fprintf('Model: %s, TPR at FPR: %5.3f / %5.3f Threshold: %5.4f\n', ModelNames{mm}, TruePositiveRate(mm), FalsePositiveRate, Thresholds(mm));
end

% save the thresholds
save(configuration.ModelThresholdsMat, 'ModelNames', 'FalsePositiveRate', 'TruePositiveRate', 'Thresholds');