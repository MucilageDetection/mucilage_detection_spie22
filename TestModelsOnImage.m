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

% load one data
CropZone = {1:1680; 1:4200};
WaterMask = rgb2gray(imread(fullfile(configuration.WaterMaskFolder, 'T35TPE_WaterMask_20m.png')));
load('E:\Dropbox\Dataset\satellite\sentinel2\35TPE_MATDATA\S2A_MSIL2A_20210519T084601_N0300_R107_T35TPE_20210519T115101_20m.mat');
ImageData = double(BandData(CropZone{1}, CropZone{2},:)) ./ 10000;

%% get the UNet result
UNetPredictor = @(bs) GetUNetPredictions(bs.data, UNetNetwork);
UNetPrediction = blockproc(ImageData, configuration.ImageSize, UNetPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);

%% get the Linear Regressor result
LinearRegressorPredictor = @(bs) GetLinearRegressorPredictions(bs.data, LinearRegressorNetwork);
LinearRegressorPrediction = blockproc(ImageData, configuration.ImageSize, LinearRegressorPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);

%% get the Random Forest result
RandomForestPredictor = @(bs) GetRandomForestPredictions(bs.data, RandomForestNetwork);
RandomForestPrediction = blockproc(ImageData, configuration.ImageSize, RandomForestPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);

%% get the Vescovi Index result
VescoviIndexPredictor = @(bs) GetVescoviPredictions(bs.data);
VescoviIndexPrediction = blockproc(ImageData, configuration.ImageSize, VescoviIndexPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);

% create output images
TCICropped = im2double(TCI(CropZone{1}, CropZone{2},:));
WaterMaskCropped = WaterMask(CropZone{1}, CropZone{2}) > 128;
UNetPredictionTCIOverlay = HighlightPredictionsOnImage(TCICropped, UNetPrediction, WaterMaskCropped);
LinearRegressorPredictionOverlay = HighlightPredictionsOnImage(TCICropped, LinearRegressorPrediction, WaterMaskCropped);
RandomForestPredictionTCIOverlay = HighlightPredictionsOnImage(TCICropped, RandomForestPrediction, WaterMaskCropped);
VescoviIndexPredictionTCIOverlay = HighlightPredictionsOnImage(TCICropped, VescoviIndexPrediction, WaterMaskCropped);

%% display result
I = [TCICropped; UNetPredictionTCIOverlay; LinearRegressorPredictionOverlay; RandomForestPredictionTCIOverlay; VescoviIndexPredictionTCIOverlay];
figure, imshow(I);
imwrite(I, 'mucilage.png');

