% Bahri ABACI
function [label] = GetSentinelLabel(labelFolder, labelFilename, resolution)
    label = imread(fullfile(labelFolder, [labelFilename, '.png']));
    label = imresize(label, [109800, 109800] ./ resolution);
    label = rgb2gray(label) > 128;
end