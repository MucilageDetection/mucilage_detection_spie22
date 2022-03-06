% Bahri ABACI
function [TrainingSamples, TrainingClasses] = GetPixelSamples(ImageNames)
    
    % control the random number generator outputs
    rng('default');

    % get the name of all files
    AllFileNames = vertcat(ImageNames.cropDataName);

    % create output file
    TrainingSamplesCell = cell(length(AllFileNames), 1);
    TrainingClassesCell = cell(length(AllFileNames), 1);

    % for each image
    for i = 1:length(AllFileNames)

        % load dataICropped and labelCropped
        load(AllFileNames{i});
        
        dataI1D = reshape(dataICropped, [size(dataICropped,1) * size(dataICropped,2), size(dataICropped,3)]);
        label1D = reshape(labelCropped, [size(dataICropped,1) * size(dataICropped,2), 1]);

        % set the images and labels
        MucilageIdx = find(label1D > 0.5);
        OtherIdx = find(label1D <= 0.5);
        
        % choose small number of samples
        OtherIdx = OtherIdx(randi(length(OtherIdx), 1,length(MucilageIdx)));
    
        % add positive and negtaive samples
        TrainingSamplesCell{i} = [dataI1D(OtherIdx, :); dataI1D(MucilageIdx, :)];
        TrainingClassesCell{i} = [zeros(length(OtherIdx), 1); ones(length(MucilageIdx), 1)];
    end
    
    % make output one dimensional array
    TrainingSamples = cell2mat(TrainingSamplesCell);
    TrainingClasses = cell2mat(TrainingClassesCell);
end