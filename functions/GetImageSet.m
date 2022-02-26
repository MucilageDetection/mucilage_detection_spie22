% Bahri ABACI
function [Images, Labels] = GetImageSet(ImageNames)

    % get the name of all files
    AllFileNames = vertcat(ImageNames.cropDataName);

    % read the first sample
    load(AllFileNames{1});
    
    % allocate memory for the patches
    Images = zeros(size(dataICropped,1), size(dataICropped,2), size(dataICropped,3), length(AllFileNames));
    Labels = zeros(size(labelCropped,1), size(labelCropped,2), length(AllFileNames));

    % for each image
    for i = 1:length(AllFileNames)
        load(AllFileNames{i});
        
        % set the images and labels
        Images(:,:,:,i) = dataICropped;
        Labels(:,:,i) = labelCropped;
    end
end