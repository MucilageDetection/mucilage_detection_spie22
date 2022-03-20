%% Bahri ABACI
clear all, close all, clc;
addpath(genpath('functions'));

% load the common configuration settings
load('configuration.mat');

%%
AllBands = configuration.sentinel.BandSRFs(:,1);
PrismaBands = configuration.prisma.BandWavelengths;
SentinelBands = configuration.sentinel.BandSRFs(:,2:end);
ColorOrderCustom = hsv(size(SentinelBands,2)+1);

% plot the bands
FigH = figure('Position', [100 100 1400 310]);
hold on;
bar(PrismaBands, ones(size(PrismaBands)), 'FaceColor', [0.4 0.4 0.4]);
ha = area(AllBands, SentinelBands, 'LineWidth',2, 'EdgeAlpha',0, 'FaceAlpha',0.7);
xlim([AllBands(1), AllBands(end)]);

ax=gca;
ax.FontSize = 14;
xlabel('Wavelength (nm)','FontName', 'Courier', 'FontWeight', 'b')
ylabel('Spectral Response','FontName', 'Courier', 'FontWeight', 'b')
legend(['PRISMA', configuration.sentinel.BandNames], 'FontName', 'Courier', 'FontWeight', 'b', 'Location', 'SouthEast');
set(ax,'ColorOrder',ColorOrderCustom);
set(gca,'LooseInset',get(gca,'TightInset'));
saveas(FigH, fullfile(configuration.AssetsDirectory, 'bands.eps'),'epsc');


