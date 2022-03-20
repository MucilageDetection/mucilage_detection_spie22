%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.sentinel.TrainValidationTestSets, 'TrainImageSet');

%% get the pixel samples for training
[TrainingSamples, TrainingClasses] = GetPixelSamples(TrainImageSet);

%% train the network
if ~isfile(configuration.RandomForestTrainedNetwork)
    fprintf('Training Random Forest model\n');
    
    % train model
    RandomForestNetwork = TreeBagger(10, TrainingSamples, TrainingClasses, 'Method', 'regression', 'MaxNumSplits', 16, 'MinLeafSize', 500);
    
    % save the model
    RandomForestNetwork = RandomForestNetwork.compact();
    save(configuration.RandomForestTrainedNetwork, 'RandomForestNetwork');
    fprintf('Training finished, network parameters saved into %s\n', configuration.RandomForestTrainedNetwork);
else
    fprintf('Training not utilized since network already trained\n');
end
