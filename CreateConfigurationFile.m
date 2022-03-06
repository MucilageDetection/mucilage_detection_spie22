% Bahri ABACI
clear all, close all, clc;

%% set the directory of the sentinel data
configuration.SentinelDataFolder = 'E:\Dropbox\Dataset\satellite\sentinel2';

%% create directories
configuration.ModelOutputDirectory = 'outputs';
configuration.InputDirectory = 'data';
configuration.AssetsDirectory = 'assets';
configuration.LabelsFolder = fullfile(configuration.InputDirectory, 'labels');
configuration.PatchOutputFolder = fullfile(configuration.InputDirectory, 'sentinel2');
configuration.WaterMaskFolder = fullfile(configuration.InputDirectory, 'mask');
configuration.SentinelCroppedDatasetInformation = fullfile(configuration.InputDirectory, 'SentinelCroppedDatasetInformation.mat');
configuration.SentinelTrainValidationTestSets = fullfile(configuration.InputDirectory, 'SentinelTrainValidationTestSets.mat');
configuration.AllEvaluatedResults =  fullfile(configuration.ModelOutputDirectory, 'TestSetEvaluations.mat');

%% common size settings
configuration.WorkingResolution = 20;
if configuration.WorkingResolution == 10
    configuration.BandNames = {'B02', 'B03', 'B04', 'B08'};
elseif configuration.WorkingResolution == 20
    configuration.BandNames = {'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B11', 'B12'};
elseif configuration.WorkingResolution == 60
    configuration.BandNames = {'B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B09', 'B11', 'B12'};
end
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