%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));
addpath(genpath('utils'));

% select the files
[fileName, filePath] = uigetfile("D:\dataset\sentinel2\*.zip");

if isempty(fileName)
    disp('no file selected!');
    return;
end

% load the common configuration settings
load('configuration.mat');

% load UNet model
load(configuration.UNetTrainedNetwork);

% load RandomForest model
load(configuration.RandomForestTrainedNetwork);

% strip the zip extension
[~, fileName] = fileparts(fileName);

% get the first three letters
fileID = fileName(1:3);

if strcmp(fileID, 'S2A') || strcmp(fileID, 'S2B')
    % make the random crops using the label image
    [BandData, MetaData] = LoadSentinelData(filePath, fileName, configuration.sentinel.WorkingResolution, configuration.sentinel.BandNames);
    CropZone = {1:size(BandData,1); 1:size(BandData,2)};
    WaterMask = rgb2gray(imread(fullfile(configuration.sentinel.MaskFolder, sprintf('%s_WaterMask_20m.png',fileName(39:44)))));
elseif strcmp(fileID, 'PRS')
    disp('PRISMA data no supported!');
    return;
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
% UNetPredictor = @(bs) GetUNetPredictions(bs.data, UNetNetwork);
% UNetPrediction = blockproc(ImageData, configuration.ImageSize, UNetPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
% UNetPrediction = UNetPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);
% UNetPredictionTCIOverlay = HighlightPredictionsOnImage(TCI, UNetPrediction, WaterMaskCropped);

%% get the Random Forest result
RandomForestPredictor = @(bs) GetRandomForestPredictions(bs.data, RandomForestNetwork);
RandomForestPrediction = blockproc(ImageData, configuration.ImageSize, RandomForestPredictor, 'BorderSize', configuration.BorderSize, 'PadPartialBlocks', true);
RandomForestPrediction = RandomForestPrediction(1:size(ImageData,1), 1:size(ImageData,2), :);
RandomForestPredictionTCIOverlay = HighlightPredictionsOnImage(TCI, RandomForestPrediction, WaterMaskCropped);

% make the final mucilage decision based on the algorithm thresholds and
% water mask
FinalPrediction = WaterMaskCropped .* RandomForestPrediction > 0.5151;
% FinalPrediction = WaterMaskCropped .* UNetPrediction > 0.1194;

% number of mucilage sample size
MAX_SAMPLE = 2000;

% get mucilage and water pixels
[MucilagePixelsY,  MucilagePixelsX] = find(FinalPrediction);
[WaterPixelsY,  WaterPixelsX] = find(~FinalPrediction & WaterMaskCropped);

% sample water indexes from the all water pixels
SampledMucilageIdx = randi(length(MucilagePixelsX), 1,MAX_SAMPLE);
MucilagePixelsX = MucilagePixelsX(SampledMucilageIdx);
MucilagePixelsY = MucilagePixelsY(SampledMucilageIdx);

% sample water indexes from the all water pixels
SampledWaterIdx = randi(length(WaterPixelsX), 1,length(MucilagePixelsX));
WaterPixelsX = WaterPixelsX(SampledWaterIdx);
WaterPixelsY = WaterPixelsY(SampledWaterIdx);

%% extract geolocations
GeopositionsAllResolution = MetaData.n1_Geometric_Info.Tile_Geocoding.Geoposition;
Geoposition = GeopositionsAllResolution([GeopositionsAllResolution.resolutionAttribute] == configuration.sentinel.WorkingResolution);

% calculate the UTM coordinates for the given resolution
UTMZone = str2double(extractAfter(MetaData.n1_Geometric_Info.Tile_Geocoding.HORIZONTAL_CS_CODE, ':'));
ProjectionCRS = projcrs(UTMZone);
MucilageUTMX = Geoposition.ULX + MucilagePixelsX * Geoposition.XDIM;
MucilageUTMY = Geoposition.ULY + MucilagePixelsY * Geoposition.YDIM;
WaterUTMX = Geoposition.ULX + WaterPixelsX * Geoposition.XDIM;
WaterUTMY = Geoposition.ULY + WaterPixelsY * Geoposition.YDIM;

% calculate the Lat,Lon coordinates based on the WGS84 ellipsoid
[MucilageLat, MucilageLon] = projinv(ProjectionCRS, MucilageUTMX, MucilageUTMY);
[WaterLat, WaterLon] = projinv(ProjectionCRS, WaterUTMX, WaterUTMY);

% write as CSV file
MucilageLabel = repmat("mucilage", length(MucilagePixelsX), 1);
WaterLabel = repmat("water", length(WaterPixelsX), 1);

ExportData = array2table([[MucilageLat, MucilageLon, MucilageLabel]; [WaterLat, WaterLon, WaterLabel]]);
ExportData.Properties.VariableNames(1:3) = {'latitude','longitude','label'};
writetable(ExportData,sprintf('%s.csv', fileName), 'Delimiter','\t');

%% display result
figure(1),
I = [TCI];
imshow(I);
hold on;
plot(MucilagePixelsX, MucilagePixelsY, 'r.');
plot(WaterPixelsX, WaterPixelsY, 'b.');