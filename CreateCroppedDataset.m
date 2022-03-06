%% create image sets
clear all, close all, clc;
addpath(genpath('class'));
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% make the labels
mkdir(configuration.PatchOutputFolder);

% get the labeled filenames
LabeledFileNames = dir(fullfile(configuration.LabelsFolder, '*.png'));

% create an empty array
LabeledFiles(length(LabeledFileNames)) = struct();

% go for all sentinel data
for i = 1:length(LabeledFileNames)
    
    [~,LabeledFileName,~] = fileparts(LabeledFileNames(i).name);
    ZipFileName = sprintf('%s.zip',LabeledFileName);

    LabeledFiles(i).dataPath = fullfile(configuration.SentinelDataFolder, ZipFileName);
    LabeledFiles(i).labelPath = fullfile(LabeledFileNames(i).folder, LabeledFileNames(i).name);
    LabeledFiles(i).cropRegion = zeros(configuration.SampleSize(3), 4);
    LabeledFiles(i).cropDataName = cell(configuration.SampleSize(3), 1);

    % make the random crops using the label image
    [BandData, ~, ~] = LoadSentinelData(configuration.SentinelDataFolder, ZipFileName, configuration.WorkingResolution, configuration.BandNames);
    
    % get the data as double
    dataI = double(BandData) ./ 10000;
    label = GetSentinelLabel(LabeledFiles(i).labelPath, configuration.WorkingResolution);

    % get positive class (green)
    positiveIdx = find(label > 0);
    sampleIdx = positiveIdx(randperm(length(positiveIdx), configuration.SampleSize(3)));
    
    % crop each sample and save them
    for idx = 1:configuration.SampleSize(3)

        % now crop and insert into data
        [r,c] = ind2sub(size(label), sampleIdx(idx));
        [r1,r2, c1,c2] = GetCropRegion(size(label), r,c, [configuration.SampleSize(1), configuration.SampleSize(2)]);
        
        % set the crop region
        LabeledFiles(i).cropRegion(idx, :) = [r1, r2, c1, c2];
        LabeledFiles(i).cropDataName{idx} = fullfile(configuration.PatchOutputFolder, sprintf('%s_%d.mat', LabeledFileName, idx));

        % crop the label
        dataICropped = dataI(r1:r2, c1:c2, :);
        labelCropped = label(r1:r2, c1:c2);
        
        % save the dataI and labels
        save(LabeledFiles(i).cropDataName{idx}, 'dataICropped', 'labelCropped');
    end
end

% save the result
save(configuration.SentinelCroppedDatasetInformation, 'LabeledFiles');
