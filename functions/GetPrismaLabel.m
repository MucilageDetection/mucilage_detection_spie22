% Bahri ABACI
function [label] = GetPrismaLabel(labelFolder, labelFilename)
    label = imread(fullfile(labelFolder, [labelFilename, '.png']));
    label = rgb2gray(label) > 128;
end