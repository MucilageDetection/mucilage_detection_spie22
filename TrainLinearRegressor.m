%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelPixelSampledData);

%% train the network
if ~isfile(configuration.LinearRegressorTrainedNetwork)
    fprintf('Training Linear Regressor model\n');
    
    % train model
    LinearRegressorNetwork = fitlm(TrainingSamples, TrainingClass);
    
    % save the model
    save(configuration.LinearRegressorTrainedNetwork, 'LinearRegressorNetwork');
    fprintf('Training finished, network parameters saved into %s\n', configuration.LinearRegressorTrainedNetwork);
else
    fprintf('Training not utilized since network already trained\n');
end
