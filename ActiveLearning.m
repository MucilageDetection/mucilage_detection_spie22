%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

% load RandomForest model
load(configuration.RandomForestTrainedNetwork);

% get all the labels
LabeledFileNames = dir(fullfile(configuration.sentinel.LabelsFolder, '*.png'));

% go for all sentinel data
for i = 1:length(LabeledFileNames)
    
    % 'S2A_MSIL2A_20210519T084601_N0300_R107_T35TPE_20210519T115101'
    [~,LabeledFileName,~] = fileparts(LabeledFileNames(i).name);

    % make the random crops using the label image
    ImageData = LoadSentinelData(configuration.SentinelDatasetFolder, LabeledFileName, configuration.sentinel.WorkingResolution, configuration.sentinel.BandNames);
    WaterMask = double(rgb2gray(imread(fullfile(configuration.sentinel.MaskFolder, sprintf('%s_WaterMask_20m.png',LabeledFileName(39:44))))) > 128);

    %% get the Random Forest result
    RandomForestPredictor = @(bs) GetRandomForestPredictions(bs.data, RandomForestNetwork);
    RandomForestPrediction = blockproc(ImageData, configuration.ImageSize, RandomForestPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
    RandomForestPrediction = RandomForestPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);
    
    % get the full size prediction and save the result
    LabelPrediction = imresize(RandomForestPrediction .* WaterMask, [10980 10980]);
    imwrite(LabelPrediction, fullfile(configuration.ModelOutputDirectory, sprintf('%s.png', LabeledFileName)));
end
