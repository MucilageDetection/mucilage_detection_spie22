%% create image sets
clear all, close all, clc;
addpath(genpath('class'));
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

% set the names
load(configuration.SentinelCroppedDatasetInformation);

%% define image sets
ImageSets = {1:4, 5, 6:8};
TrainImageSet = LabeledFiles(ImageSets{1});
ValidationImageSet = LabeledFiles(ImageSets{2});
TestImageSet = LabeledFiles(ImageSets{3});

% write the results
save(configuration.SentinelTrainValidationTestSets, 'ImageSets', 'TrainImageSet', 'ValidationImageSet', 'TestImageSet');