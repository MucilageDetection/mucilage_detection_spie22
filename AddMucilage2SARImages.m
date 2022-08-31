%% Bahri ABACI
%% Add mucilage overlay from csv file
clear all, close all, clc;
addpath(genpath('functions'));
addpath(genpath('utils'));

%% define the name of the files
FolderName = "E:\Dropbox\Dataset\satellite\SentileSAR\";
FileName = "S1A_IW_SLC__1SDV_20210517T_split_IW1_Cal_deb_mrg_ML_mat_Spk_TC_Decomp.dim";
CSVFile = "S2B_MSIL2A_20210517T085559_N0300_R007_T35TPF_20210517T112912.csv";

%% read the SAR data
[ImageData, Im2Model] = LoadSCLData(FolderName, FileName);

%% LAT-LON to pixel locations
% read the locations
Coordinates = readtable(CSVFile);

% define the rotation function
fCoord2Pixel = @(lat,lon) round(inv([Im2Model; 0 0 1]) * [reshape(lon, 1,[]); reshape(lat, 1,[]); ones(1, length(lat))]);

% get the pixel locations on SAR image
SarPixels = fCoord2Pixel(Coordinates.latitude, Coordinates.longitude);
MucilagePixels = SarPixels(1:2, strcmp(Coordinates.label, 'mucilage'))';
WaterPixels = SarPixels(1:2,strcmp(Coordinates.label, 'water'))';

% find pixels overlapping with the image data
MucilageInsideIndex = (MucilagePixels(:,1) > 0) & (MucilagePixels(:,1) < size(ImageData,2)) & (MucilagePixels(:,2) > 0) & (MucilagePixels(:,2) < size(ImageData,1));
WaterInsideIndex = (WaterPixels(:,1) > 0) & (WaterPixels(:,1) < size(ImageData,2)) & (WaterPixels(:,2) > 0) & (WaterPixels(:,2) < size(ImageData,1));
MucilagePixels = MucilagePixels(MucilageInsideIndex, :);
WaterPixels = WaterPixels(WaterInsideIndex,:);
PointBBOX = minmax([MucilagePixels;WaterPixels]');

%% show the image
% make bounding box
CroppedImageData = ImageData(PointBBOX(2,1):PointBBOX(2,2), PointBBOX(1,1):PointBBOX(1,2), :);
WaterPixelsCropped = WaterPixels - [PointBBOX(1,1) PointBBOX(2,1)] + 1;
MucilagePixelsCropped = MucilagePixels - [PointBBOX(1,1) PointBBOX(2,1)] + 1;

% display the image and points
imshow(CroppedImageData, [0 1]);
hold on;

plot(WaterPixelsCropped(:,1), WaterPixelsCropped(:,2), 'b.');
plot(MucilagePixelsCropped(:,1), MucilagePixelsCropped(:,2), 'r.');
saveas(gcf, 'TPE_image','png');
%% make the stats
WaterSamples = zeros(size(WaterPixels,1), size(ImageData,3), 'single');
MucilageSamples = zeros(size(MucilagePixels,1), size(ImageData,3), 'single');

for w = 1:size(WaterSamples, 1)
    WaterSamples(w,:) = ImageData(WaterPixels(w,2),WaterPixels(w,1), :);
end
for m = 1:size(WaterSamples, 1)
    MucilageSamples(m,:) = ImageData(MucilagePixels(m,2),MucilagePixels(m,1), :);
end
Limits = [squeeze(min(min(ImageData))), squeeze(max(max(ImageData)))];

% plot the statistics
figure,
for b = 1:size(ImageData, 3)
    x = linspace(Limits(b,1),Limits(b,2), 30);

    % get the histogram
    counts0 = hist(WaterSamples(:,b), x);
    counts1 = hist(MucilageSamples(:,b), x);
    counts = [counts0 ./ sum(counts0); counts1 ./ sum(counts1)]';
    
    subplot(1, size(ImageData,3), b);
    bar(x, counts, 'BarWidth', 1.0);
    ylim([0 0.3]);
    grid on;
    grid minor;
    legend('Water','Mucilage');
    title(sprintf('Band %d', b));
    drawnow;
    saveas(gcf, 'TPE_distribution','png');
end



