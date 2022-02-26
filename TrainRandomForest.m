%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelPixelSampledData);

%% train the network
if ~isfile(configuration.RandomForestTrainedNetwork)
    fprintf('Training Random Forest model\n');
    
    % train model
    tree = templateTree('MaxNumSplits', 2);
    RandomForestNetwork = fitrensemble(TrainingSamples, TrainingClass, 'Method', 'Bag', 'Learners', tree, 'NumLearningCycles', 10);
    
    % save the model
    save(configuration.RandomForestTrainedNetwork, 'RandomForestNetwork');
    fprintf('Training finished, network parameters saved into %s\n', configuration.RandomForestTrainedNetwork);
else
    fprintf('Training not utilized since network already trained\n');
end
