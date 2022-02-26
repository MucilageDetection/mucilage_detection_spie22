%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%% load the dataset
load(configuration.SentinelPixelSampledData);

%% get the classes
C0 = TrainingClass == 0;
C1 = TrainingClass == 1;

% make output directory
mkdir('assets');

% generate automated subplot
close all;
for b = 1:length(configuration.BandNames)
    figure,
    
    x = linspace(0,0.2, 30);
    
    % get the histogram
    counts0 = hist(TrainingSamples(C0, b), x);
    counts1 = hist(TrainingSamples(C1, b), x);
    counts = [counts0 ./ sum(counts0); counts1 ./ sum(counts1)]';
    bar(x, counts, 'BarWidth', 1.0);
    ylim([0 0.3]);
    grid on;
    grid minor;
    legend('Su','Müsilaj');
    title(configuration.BandNames{b});
    drawnow;
    saveas(gcf,sprintf('assets/histogram_%s_manual.eps', configuration.BandNames{b}));
end

%% plot the band statistics
BandMeans0 = mean(TrainingSamples(C0, :), 1);
BandMeans1 = mean(TrainingSamples(C1, :), 1);

BandStd0 = std(TrainingSamples(C0, :), 1);
BandStd1 = std(TrainingSamples(C1, :), 1);

figure, hold on;
grid on;
ax = gca();
errorbar(ax, 1:length(configuration.BandNames), BandMeans0, BandStd0, '-s','MarkerSize',10,...
    'MarkerEdgeColor','blue','MarkerFaceColor',[0.4 0.4 0.8], 'color', [0.2 0.2 1.0], 'LineWidth', 2);
errorbar(ax, 1:length(configuration.BandNames), BandMeans1, BandStd1, '-s','MarkerSize',10,...
    'MarkerEdgeColor','red','MarkerFaceColor',[0.8 0.4 0.4], 'color', [1.0 0.2 0.2], 'LineWidth', 2);
xticks(1:length(configuration.BandNames));
ax.XTickLabel = configuration.BandNames;
legend('Su','Müsilaj');

saveas(gcf,sprintf('assets/distribution_manual.eps'));