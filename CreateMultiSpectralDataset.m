%% create image sets
clear all, close all, clc;
addpath(genpath('class'));
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

% eval on Sentinel and Prisma
for EvalMode = 1:2

    % set the filenames based on the selection
    if EvalMode == 1
        TrainValidationTestSets = configuration.sentinel.TrainValidationTestSets;
        LabelsFolder = configuration.sentinel.LabelsFolder;
        MaskFolder = configuration.sentinel.MaskFolder;
        ImageSets = {1:4, 5, 6:8};
    else
        TrainValidationTestSets = configuration.prisma.TrainValidationTestSets;
        LabelsFolder = configuration.prisma.LabelsFolder;
        MaskFolder = configuration.prisma.MaskFolder;
        ImageSets = {[], [], 1:2};
    end

    % check the existence of the current crop box
    if ~exist(TrainValidationTestSets, 'file')

        % get the labeled filenames
        LabeledFileNames = dir(fullfile(LabelsFolder, '*.png'));

        % create an empty array
        LabeledFiles = struct();

        % go for all sentinel data
        for i = 1:length(LabeledFileNames)

            [~,LabeledFileName,~] = fileparts(LabeledFileNames(i).name);

            LabeledFiles(i).fileName = LabeledFileName;

            % make the random crops using the label image
            if EvalMode == 1
                label = GetSentinelLabel(LabelsFolder, LabeledFiles(i).fileName, configuration.sentinel.WorkingResolution);
            else
                label = GetPrismaLabel(LabelsFolder, LabeledFiles(i).fileName);
            end

            % define crop region arrays
            LabeledFiles(i).cropRegion = zeros(configuration.SampleSize(3), 4);
            LabeledFiles(i).cropDataName = cell(configuration.SampleSize(3), 1);

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
                LabeledFiles(i).cropDataName{idx} = fullfile(configuration.PatchDataFolder, sprintf('%s_%d.mat', LabeledFileName, idx));
            end
        end

        %% define image sets
        TrainImageSet = LabeledFiles(ImageSets{1});
        ValidationImageSet = LabeledFiles(ImageSets{2});
        TestImageSet = LabeledFiles(ImageSets{3});

        % write the results
        save(TrainValidationTestSets, 'ImageSets', 'TrainImageSet', 'ValidationImageSet', 'TestImageSet');
    else
        fprintf('Previously created patch set found, cropping the original frames based on this set!\n');
        load(TrainValidationTestSets);
    end

    %% make the labels
    mkdir(configuration.PatchDataFolder);

    AllLabeledFiles = [TrainImageSet, ValidationImageSet, TestImageSet];
    for t = 1:length(AllLabeledFiles)

        if EvalMode == 1
            % make the random crops using the label image
            BandData = LoadSentinelData(configuration.SentinelDatasetFolder, AllLabeledFiles(t).fileName, configuration.sentinel.WorkingResolution, configuration.sentinel.BandNames);

            % get the data as double
            dataI = BandData;
            label = GetSentinelLabel(LabelsFolder, AllLabeledFiles(t).fileName, configuration.sentinel.WorkingResolution);
        else
            % make the random crops using the label image
            BandData = LoadPrismaData(configuration.PrismaDatasetFolder, AllLabeledFiles(t).fileName);

            % get the data as double
            dataI = GetSentinelBandEquaivelant(BandData, configuration.prisma.BandWavelengths, configuration.sentinel.BandSRFs);
            label = GetPrismaLabel(LabelsFolder, AllLabeledFiles(t).fileName);
        end

        % crop each sample and save them
        for idx = 1:length(AllLabeledFiles(t).cropDataName)

            % set the crop region
            CR = AllLabeledFiles(t).cropRegion(idx, :);

            % crop the label
            dataICropped = dataI(CR(1):CR(2), CR(3):CR(4), :);
            labelCropped = label(CR(1):CR(2), CR(3):CR(4));

            % save the dataI and labels
            save(AllLabeledFiles(t).cropDataName{idx}, 'dataICropped', 'labelCropped');
        end
    end
end