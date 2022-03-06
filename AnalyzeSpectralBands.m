%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelTrainValidationTestSets, 'TrainImageSet');

%% get the pixel samples for training
[TrainingSamples, TrainingClasses] = GetPixelSamples(TrainImageSet);

%% get the classes
MucilageSamples = TrainingSamples(TrainingClasses == 1, :);
WaterSamples    = TrainingSamples(TrainingClasses == 0, :);

% make output directory
mkdir('assets');

% generate automated subplot
close all;
for b = 1:length(configuration.BandNames)
    figure,
    
    x = linspace(0,0.2, 30);
    
    % get the histogram
    counts0 = hist(WaterSamples(:, b), x);
    counts1 = hist(MucilageSamples(:, b), x);
    counts = [counts0 ./ sum(counts0); counts1 ./ sum(counts1)]';
    bar(x, counts, 'BarWidth', 1.0);
    ylim([0 0.3]);
    grid on;
    grid minor;
    legend('Water','Mucilage');
    title(configuration.BandNames{b});
    drawnow;
    saveas(gcf,sprintf('assets/histogram_%s.eps', configuration.BandNames{b}), 'epsc');
end

%% plot the band statistics
BandMeans0 = mean(WaterSamples, 1);
BandMeans1 = mean(MucilageSamples, 1);

BandStd0 = std(WaterSamples, 1);
BandStd1 = std(MucilageSamples, 1);

figure, hold on;
grid on;
ax = gca();
errorbar(ax, 1:length(configuration.BandNames), BandMeans0, BandStd0, '-s','MarkerSize',10,...
    'MarkerEdgeColor','blue','MarkerFaceColor',[0.4 0.4 0.8], 'color', [0.2 0.2 1.0], 'LineWidth', 2);
errorbar(ax, 1:length(configuration.BandNames), BandMeans1, BandStd1, '-s','MarkerSize',10,...
    'MarkerEdgeColor','red','MarkerFaceColor',[0.8 0.4 0.4], 'color', [1.0 0.2 0.2], 'LineWidth', 2);
xticks(1:length(configuration.BandNames));
ax.XTickLabel = configuration.BandNames;
legend('Water','Mucilage');

saveas(gcf,sprintf('assets/water_mucilage_distribution.eps'), 'epsc');

%% plot the vescovi statistics
figure,
x = linspace(-2,0.5, 30);

% get the histogram
counts0 = hist(GetVescoviIndex(WaterSamples), x);
counts1 = hist(GetVescoviIndex(MucilageSamples), x);
counts = [counts0 ./ sum(counts0); counts1 ./ sum(counts1)]';
bar(x, counts, 'BarWidth', 1.0);
ylim([0 0.3]);
grid on;
grid minor;
legend('Water','Mucilage');
title('Vescovi Index Distribution');
drawnow;
saveas(gcf,sprintf('assets/histogram_vescovi.eps'), 'epsc');