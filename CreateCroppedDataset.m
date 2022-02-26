%% create image sets
clear all, close all, clc;
addpath(genpath('class'));
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% make the labels
LabeledFiles = GetSentinelLabeledData(configuration.SentinelDataFolder, configuration.LabelsFolder, configuration.PatchOutputFolder, {'35TPF', '35TPE'}, configuration.WorkingResolution, configuration.SampleSize);
save(configuration.SentinelCroppedDatasetInformation, 'LabeledFiles');
