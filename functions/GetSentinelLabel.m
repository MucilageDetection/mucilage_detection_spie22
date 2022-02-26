% Bahri ABACI
function [label] = GetSentinelLabel(labelFilename, resolution)
    label = imread(labelFilename);
    label = imresize(label, [109800, 109800] ./ resolution);
    label = rgb2gray(label) > 128;
end