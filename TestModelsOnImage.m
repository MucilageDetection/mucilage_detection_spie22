%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% select the files
[fileNames, filePath] = uigetfile("*.zip", "MultiSelect","on");

% single file selected
if ~iscell(fileNames)
    fileNames = {fileNames};
end

% make the output directory
if ~isempty(fileNames)
    mkdir('visual_results');

    % load the common configuration settings
    load('configuration.mat');
    
    % load UNet model
    load(configuration.UNetTrainedNetwork);
    
    % load Linear Regressor model
    load(configuration.LinearRegressorTrainedNetwork);
    
    % load RandomForest model
    load(configuration.RandomForestTrainedNetwork);
end

% pass through all the selected files
for f = 1:length(fileNames)
    
    % strip the zip extension
    [~, fileName] = fileparts(fileNames{f});

    % get the first three letters
    fileID = fileName(1:3);

    if strcmp(fileID, 'S2A') || strcmp(fileID, 'S2B')
        % make the random crops using the label image
        BandData = LoadSentinelData(filePath, fileName, configuration.sentinel.WorkingResolution, configuration.sentinel.BandNames);
        CropZone = {1:1680; 1:4200};
        WaterMask = rgb2gray(imread(fullfile(configuration.sentinel.MaskFolder, sprintf('%s_WaterMask_20m.png',fileName(39:44)))));
    elseif strcmp(fileID, 'PRS')
        % make the random crops using the label image
        BandData = LoadPrismaData(filePath, fileName);
        BandData = GetSentinelBandEquaivelant(BandData, configuration.prisma.BandWavelengths, configuration.sentinel.BandSRFs);
        CropZone = {1:size(BandData,1); 1:size(BandData,2)};

        % no way to understand region from the name
        if contains(fileName, '20210513090102')
            WaterMask = rgb2gray(imread(fullfile(configuration.prisma.MaskFolder, 'PRS_L2D_STD_BURSA.png')));
        else
            WaterMask = rgb2gray(imread(fullfile(configuration.prisma.MaskFolder, 'PRS_L2D_STD_ISTANBUL.png')));
        end
    else
        fprintf('Unknown dataset for evaluation!\n');
        return;
    end

    % crop data
    ImageData = BandData(CropZone{1}, CropZone{2},:);
    TCI = GetTCIFromBands(ImageData, configuration.sentinel.BandNames);
    WaterMask(sum(ImageData, 3) == 0) = 0;
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
    figure(1), imshow(I);

    %% write the outputs
    imwrite(TCI, sprintf('visual_results/%s_0_tci.png', fileName));
    imwrite(UNetPredictionTCIOverlay, sprintf('visual_results/%s_1_unet.png', fileName));
    imwrite(RandomForestPredictionTCIOverlay, sprintf('visual_results/%s_2_random_forest.png', fileName));
    imwrite(LinearRegressorPredictionOverlay, sprintf('visual_results/%s_3_linear_regression.png', fileName));
    imwrite(VescoviIndexPredictionTCIOverlay, sprintf('visual_results/%s_4_vescovi.png', fileName));

end
