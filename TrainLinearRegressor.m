%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelTrainValidationTestSets, 'TrainImageSet');

%% get the pixel samples for training
[TrainingSamples, TrainingClasses] = GetPixelSamples(TrainImageSet);

%% train the network
if ~isfile(configuration.LinearRegressorTrainedNetwork)
    fprintf('Training Linear Regressor model\n');
    
    % train model
    LinearRegressorNetwork = fitrlinear(TrainingSamples, TrainingClasses, 'Learner', 'leastsquares', 'Lambda', 0.01);
    
    % save the model
    save(configuration.LinearRegressorTrainedNetwork, 'LinearRegressorNetwork');
    fprintf('Training finished, network parameters saved into %s\n', configuration.LinearRegressorTrainedNetwork);
else
    fprintf('Training not utilized since network already trained\n');
end
