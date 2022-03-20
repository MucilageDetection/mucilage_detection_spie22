% Bahri ABACI
clear all, close all, clc;

%% set the directory of the sentinel data
configuration.SentinelDatasetFolder = 'D:\dataset\sentinel2';
configuration.PrismaDatasetFolder = 'D:\dataset\prisma';

%% create directories
configuration.ModelOutputDirectory = 'outputs';
configuration.AssetsDirectory = 'assets';
configuration.PatchDataFolder = fullfile(configuration.ModelOutputDirectory, 'patches');

%% common settings
configuration.SampleSize = [256 256 200];

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

%% SENTINEL
configuration.sentinel.DataFolder = 'data/sentinel2';
configuration.sentinel.LabelsFolder = fullfile(configuration.sentinel.DataFolder, 'labels');
configuration.sentinel.MaskFolder = fullfile(configuration.sentinel.DataFolder, 'mask');
configuration.sentinel.TrainValidationTestSets = fullfile(configuration.ModelOutputDirectory, 'SentinelTrainValidationTestSets.mat');

%% common size settings
configuration.sentinel.WorkingResolution = 20;

% load the SRF information
load(fullfile(configuration.sentinel.DataFolder, 'SRF.mat'));

% set the band informations
if configuration.sentinel.WorkingResolution == 10
    configuration.sentinel.BandNames = {'B02', 'B03', 'B04', 'B08'};
    configuration.sentinel.BandWavelengths = [490 560 665 842; 65 35 30 115];
    configuration.sentinel.BandSRFs = SRF_S2A(:, [1 3 4 5 9]);
elseif configuration.sentinel.WorkingResolution == 20
    configuration.sentinel.BandNames = {'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B11', 'B12'};
    configuration.sentinel.BandWavelengths = [490 560 665 705 740 783 865 1610 2190; 65 35 30 15 15 20 20 90 180];
    configuration.sentinel.BandSRFs = SRF_S2A(:, [1 3 4 5 6 7 8 10 13 14]);
elseif configuration.sentinel.WorkingResolution == 60
    configuration.sentinel.BandNames = {'B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B09', 'B11', 'B12'};
    configuration.sentinel.BandWavelengths = [443 490 560 665 705 740 783 865 945 1610 2190; 20 65 35 30 15 15 20 20 20 90 180];
    configuration.sentinel.BandSRFs = SRF_S2A(:, [1 2 3 4 5 6 7 8 10 11 13 14]);
end

% common settings that are determined after sentinel settings
configuration.InputSize = [configuration.SampleSize(1) configuration.SampleSize(2) length(configuration.sentinel.BandNames)];

%% PRISMA
configuration.prisma.DataFolder = 'data/prisma';
configuration.prisma.LabelsFolder = fullfile(configuration.prisma.DataFolder, 'labels');
configuration.prisma.MaskFolder = fullfile(configuration.prisma.DataFolder, 'mask');
configuration.prisma.TrainValidationTestSets = fullfile(configuration.ModelOutputDirectory, 'PrismaTrainValidationTestSets.mat');

% load the SRF information
load(fullfile(configuration.prisma.DataFolder, 'PrismaBandWavelengths.mat'));
configuration.prisma.BandWavelengths = BandWavelengths;

% save the configuration file
save('configuration', 'configuration');