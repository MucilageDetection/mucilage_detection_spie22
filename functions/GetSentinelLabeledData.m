function labeledFiles = GetSentinelLabeledData(sentinelDataFolder, labelFolder, outputFolder, tiles, resolution, sampleSize)
    
    % make the output directory
    mkdir(outputFolder);

    % get the all samples
    sentinelFileDir = GetSentinelFileNames(sentinelDataFolder, tiles, resolution);

    % create an empty array
    labeledFiles = [];

    % go for all sentinel data
    for i = 1:length(sentinelFileDir)
        
        % get the address of the manually labeled mask
        labelFileName = SentinelFolderNameToFileName(sentinelFileDir(i).name,'_TCI_10m.png');
        labelFullFileName = fullfile(labelFolder, labelFileName);
        
        % if the label file exist for the current sample, add it
        if isfile(labelFullFileName)
            currentData.dataPath = fullfile(sentinelFileDir(i).folder, sprintf('%s_MATDATA', sentinelFileDir(i).tile), sprintf('%s_%dm.mat', sentinelFileDir(i).name, resolution));
            currentData.labelPath = labelFullFileName;
            currentData.cropRegion = zeros(sampleSize(3), 4);
            currentData.cropDataName = cell(sampleSize(3), 1);

            % make the random crops using the label image
            load(currentData.dataPath);
            dataI = double(BandData) ./ 10000;
            label = GetSentinelLabel(currentData.labelPath, resolution);
        
            % get positive class (green)
            positiveIdx = find(label > 0);
            sampleIdx = positiveIdx(randperm(length(positiveIdx), sampleSize(3)));
            
            % crop each sample and save them
            for idx = 1:sampleSize(3)

                % now crop and insert into data
                [r,c] = ind2sub(size(label), sampleIdx(idx));
                [r1,r2, c1,c2] = GetCropRegion(size(label), r,c, [sampleSize(1), sampleSize(2)]);
                
                % set the crop region
                currentData.cropRegion(idx, :) = [r1, r2, c1, c2];
                currentData.cropDataName{idx} = fullfile(outputFolder, sprintf('%s_%d.mat', sentinelFileDir(i).name, idx));

                % crop the label
                dataICropped = dataI(r1:r2, c1:c2, :);
                labelCropped = label(r1:r2, c1:c2);

                % save the dataI and labels
                save(currentData.cropDataName{idx}, 'dataICropped', 'labelCropped');

            end
            
            % add the data at the end of the list
            labeledFiles = [labeledFiles; currentData];
        end

    end
end