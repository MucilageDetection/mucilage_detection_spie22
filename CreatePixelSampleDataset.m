%% create image sets
clear all, close all, clc;
addpath(genpath('class'));
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelTrainValidationTestSets, 'TrainImageSet');

%% load image sets
[TrainImages, TrainLabels] = GetImageSet(TrainImageSet);
    
%% make training data
TrainImages = reshape(TrainImages, [size(TrainImages,1)*size(TrainImages,2), size(TrainImages,3), size(TrainImages, 4)]);
TrainLabels = reshape(TrainLabels, [size(TrainLabels,1)*size(TrainLabels,2), size(TrainImages,3)]);

TrainingSamples = [];
TrainingClass = [];
for s = 1:size(TrainImages, 3)
    MucilageIdx = find(TrainLabels(:,s) > 0.5);
    OtherIdx = find(TrainLabels(:,s) <= 0.5);
    
    % choose small number of samples
    OtherIdx = OtherIdx(randperm(length(OtherIdx), length(MucilageIdx)));

    % add positive samples
    TrainingSamples = [TrainingSamples; TrainImages(OtherIdx, :, s)];
    TrainingClass = [TrainingClass; zeros(length(OtherIdx), 1);];

    TrainingSamples = [TrainingSamples; TrainImages(MucilageIdx, :, s)];
    TrainingClass = [TrainingClass; ones(length(MucilageIdx), 1);];
end

% save the data
save(configuration.SentinelPixelSampledData, 'TrainingSamples', 'TrainingClass');