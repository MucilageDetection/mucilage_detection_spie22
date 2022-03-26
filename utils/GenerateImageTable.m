%% Bahri ABACI
clear all, close all, clc;

FolderName = '../visual_results';
HeaderNames = {'tci', 'unet', 'random_forest', 'linear_regression', 'vescovi'};
ConvertTo = 'jpg';
ScaleWith = 0.25;
OutputDirectory = 'assets';

% get the list of all images
AllImages = dir([FolderName, '/*.png']);

% get the name and dates
AllNames = arrayfun(@(x) x.name, AllImages, 'UniformOutput', false);

% make the assets dir for the cınverted images
mkdir(OutputDirectory);

% get the filenames for each column
for c = 1:length(HeaderNames)
    % get the filenames
    CurrentColumnFileNames = AllNames(contains(AllNames, HeaderNames(c)));
    
    % get the dates and sort them
    AllDates = cellfun(@(x) x(12:19), CurrentColumnFileNames, 'UniformOutput', false);
    [AllDates, idx] = sort(AllDates);

    % save the sorted list
    CurrentNames = CurrentColumnFileNames(idx);

    for i = 1:length(CurrentNames)

        [~, CurrentName, CurrentExtension] = fileparts(CurrentNames{i});
        CurrentName = fullfile(OutputDirectory, sprintf('%s.%s', CurrentName, ConvertTo));
        
        % convert the file
        imwrite(imresize(imread(fullfile(FolderName, CurrentNames{i})), ScaleWith), CurrentName);

        ColumnFileNames{2*i - 1,c} = sprintf('%s-%s-%s', AllDates{i}(7:8), AllDates{i}(5:6), AllDates{i}(1:4));
        ColumnFileNames{2*i + 0,c} = sprintf('![%s](%s)', AllDates{i}, CurrentName);
    end
end

% make columnfilenames table
cell2md(ColumnFileNames, 'outfile', sprintf('table_%s.md', cell2mat(HeaderNames)), 'hdrnames', HeaderNames);
