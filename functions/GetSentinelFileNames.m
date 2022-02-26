function out = GetSentinelFileNames(folderName, tileNames, resolution)
    
    % create output as empty array
    out = [];
    resID = sprintf('_%dm', resolution);
    
    % get the filenames for all tiles
    for t = 1:length(tileNames)
        % get the folder dir
        folderSubDir = dir(fullfile(folderName, sprintf('%s_%s',tileNames{t}, 'MATDATA')));

        % get the filenames
        for i = 1:length(folderSubDir)
            [~,name,~] = fileparts(folderSubDir(i).name);
            if contains(name, resID)
                onames = strsplit(name, resID);
                current.name = onames{1};
                current.folder = folderName;
                current.tile = tileNames{t};
                
                % push valid data
                out = [out, current];
            end
        end
    end
end