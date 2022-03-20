%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

% load UNet model
load(configuration.UNetTrainedNetwork);

% load Linear Regressor model
load(configuration.LinearRegressorTrainedNetwork);

% load RandomForest model
load(configuration.RandomForestTrainedNetwork);
EvalOn = 'PRISMA';

if strcmp(EvalOn, 'SENTINEL')
    % make the random crops using the label image
    BandData = LoadSentinelData(configuration.SentinelDatasetFolder, 'S2A_MSIL2A_20210519T084601_N0300_R107_T35TPE_20210519T115101', configuration.sentinel.WorkingResolution, configuration.sentinel.BandNames);
    CropZone = {1:1680; 1:4200};
    WaterMask = rgb2gray(imread(fullfile(configuration.sentinel.MaskFolder, 'T35TPE_WaterMask_20m.png')));
elseif strcmp(EvalOn, 'PRISMA')
    % make the random crops using the label image
    BandData = LoadPrismaData(configuration.PrismaDatasetFolder, 'PRS_L2D_STD_20210519090410_20210519090414_0001');
    BandData = GetSentinelBandEquaivelant(BandData, configuration.prisma.BandWavelengths, configuration.sentinel.BandSRFs);
    CropZone = {1:size(BandData,1); 1:size(BandData,2)};
    WaterMask = rgb2gray(imread(fullfile(configuration.prisma.MaskFolder, 'PRS_L2D_STD_ISTANBUL.png')));
else
    fprintf('Unknown dataset for evaluation!\n');
    return;
end

% crop data
ImageData = BandData(CropZone{1}, CropZone{2},:);
TCI = GetTCIFromBands(ImageData, configuration.sentinel.BandNames);
WaterMaskCropped = WaterMask(CropZone{1}, CropZone{2}) > 128;

%% get the UNet result
UNetPredictor = @(bs) GetUNetPredictions(bs.data, UNetNetwork);
UNetPrediction = blockproc(ImageData, configuration.ImageSize, UNetPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
UNetPrediction = UNetPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);

%% get the Random Forest result
RandomForestPredictor = @(bs) GetRandomForestPredictions(bs.data, RandomForestNetwork);
RandomForestPrediction = blockproc(ImageData, configuration.ImageSize, RandomForestPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
RandomForestPrediction = RandomForestPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);

%% get the Linear Regressor result
LinearRegressorPredictor = @(bs) GetLinearRegressorPredictions(bs.data, LinearRegressorNetwork);
LinearRegressorPrediction = blockproc(ImageData, configuration.ImageSize, LinearRegressorPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
LinearRegressorPrediction = LinearRegressorPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);

%% get the Vescovi Index result
VescoviIndexPredictor = @(bs) GetVescoviPredictions(bs.data);
VescoviIndexPrediction = blockproc(ImageData, configuration.ImageSize, VescoviIndexPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
VescoviIndexPrediction = VescoviIndexPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);

%% create output images
UNetPredictionTCIOverlay = HighlightPredictionsOnImage(TCI, UNetPrediction, WaterMaskCropped);
LinearRegressorPredictionOverlay = HighlightPredictionsOnImage(TCI, LinearRegressorPrediction, WaterMaskCropped);
RandomForestPredictionTCIOverlay = HighlightPredictionsOnImage(TCI, RandomForestPrediction, WaterMaskCropped);
VescoviIndexPredictionTCIOverlay = HighlightPredictionsOnImage(TCI, VescoviIndexPrediction, WaterMaskCropped);

%% display result
I = [TCI; UNetPredictionTCIOverlay; RandomForestPredictionTCIOverlay; LinearRegressorPredictionOverlay; VescoviIndexPredictionTCIOverlay];
figure, imshow(I);
imwrite(I, 'mucilage.png');
