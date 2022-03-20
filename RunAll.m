clear all, close all, clc;

% create config file
CreateConfigurationFile;

% create datasets
CreateMultiSpectralDataset;

% train algorithms
TrainLinearRegressor;
TrainRandomForest;
TrainUNetModel;

% evaluate the results
EvaluateResults;