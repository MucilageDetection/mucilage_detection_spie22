% Bahri ABACI
clear all, close all, clc;

%% set the directory of the sentinel data
configuration.SentinelDataFolder = 'E:\Dropbox\Dataset\satellite\sentinel2';

%% create directories
configuration.ModelOutputDirectory = 'outputs';
configuration.LabelsFolder = 'data';
configuration.PatchOutputFolder = fullfile(configuration.SentinelDataFolder, 'ImagePatches');
configuration.SentinelCroppedDatasetInformation = fullfile(configuration.ModelOutputDirectory, 'SentinelCroppedDatasetInformation.mat');
configuration.SentinelTrainValidationTestSets = fullfile(configuration.ModelOutputDirectory, 'SentinelTrainValidationTestSets.mat');
configuration.SentinelPixelSampledData = fullfile(configuration.ModelOutputDirectory, 'SentinelPixelSampledData.mat');

%% common size settings
configuration.WorkingResolution = 20;
configuration.BandNames = {'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B11', 'B12'};
configuration.SampleSize = [256 256 200];
configuration.InputSize = [configuration.SampleSize(1) configuration.SampleSize(2) length(configuration.BandNames)];

% Unet setting but effect all other models
configuration.EncoderDepth = 3;
configuration.ImageSize = [168 168];
configuration.BorderSize = [44 44];
configuration.OutputRange = 45:212;

%% linear model settings
configuration.LinearRegressorTrainedNetwork = fullfile(configuration.ModelOutputDirectory, 'LinearRegressorTrainedNetwork.mat');

%% random forest settings
configuration.RandomForestTrainedNetwork = fullfile(configuration.ModelOutputDirectory, 'RandomForestTrainedNetwork.mat');

%% unet settings
configuration.UNetTrainedNetwork = fullfile(configuration.ModelOutputDirectory, 'UNetTrainedNetwork.mat');

% save the configuration file
save('configuration', 'configuration');