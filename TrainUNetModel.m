%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));
addpath(genpath('class'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelTrainValidationTestSets, 'TrainImageSet', 'ValidationImageSet');

%% settings
DataAugmentationTypes = {'original';'hflip';'vflip';'rot90';'rot180'};
MiniBatchSize = 40;

%% create datastores
DSTrain      = SentinelPatchDatastore(TrainImageSet, DataAugmentationTypes, MiniBatchSize);
DSValidation = SentinelPatchDatastore(ValidationImageSet, DataAugmentationTypes, MiniBatchSize);

%% create unet network
[lConnections, ~] = unetLayers(configuration.InputSize, 2, 'NumOutputChannels', 8,'EncoderDepth', configuration.EncoderDepth, 'ConvolutionPadding', 'same');

% use focal loss for the output layer
% layer = focalLossLayer("Name","Focal Loss Layer");
layer = dicePixelClassificationLayer("Name","Dice Loss Layer");
lConnections = replaceLayer(lConnections, "Segmentation-Layer",layer);

%% set the training options
options = trainingOptions('adam', ...
    'LearnRateSchedule','piecewise',...
    'LearnRateDropPeriod',10,...
    'LearnRateDropFactor',0.5,...
    'InitialLearnRate',1e-3, ...
    'L2Regularization',0.001, ...
    'ValidationData',DSValidation,...
    'MaxEpochs',40, ...  
    'MiniBatchSize',MiniBatchSize, ...
    'Shuffle','never', ...
    'CheckpointPath', tempdir, ...
    'VerboseFrequency',50,...
    'Plots','training-progress',...
    'ValidationPatience', 2);

%% train the network
if ~isfile(configuration.UNetTrainedNetwork)
    fprintf('Training U-Net\n');
    
    % train model
    UNetNetwork = trainNetwork(DSTrain, lConnections, options);
    
    % save the model
    save(configuration.UNetTrainedNetwork, 'UNetNetwork');
    fprintf('Training finished, network parameters saved into %s\n', configuration.UNetTrainedNetwork);
else
    fprintf('Training not utilized since network already trained\n');
end