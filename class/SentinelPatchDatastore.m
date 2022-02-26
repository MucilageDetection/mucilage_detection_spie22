classdef SentinelPatchDatastore < matlab.io.Datastore & matlab.io.datastore.MiniBatchable

    properties
        labeledFiles;
        allSampleNames;
        augmentations;

        MiniBatchSize;

        currentIDX;
        indices;
    end

    properties(SetAccess = protected)
        NumObservations;
    end

    properties(Access = private)
    end


    methods

        function ds = SentinelPatchDatastore(labeledFiles, augmentation, miniBatchSize)

            % get the filenames
            ds.labeledFiles = labeledFiles;
            ds.augmentations = augmentation;

            % create num observations
            ds.allSampleNames = vertcat(ds.labeledFiles.cropDataName);

            % Initialize datastore properties.
            ds.MiniBatchSize = miniBatchSize;
            ds.NumObservations = length(ds.allSampleNames) * length(ds.augmentations);

            % create indices
            ds.indices = randperm(ds.NumObservations);
            ds.currentIDX = 1;
        end

        % check that we can read at least one more batch
        function tf = hasdata(ds)
            tf = ds.currentIDX < ds.NumObservations;
        end

        % read one mini batch of data
        function [dataTable,info] = read(ds)
            info = struct;

            % get the filenames
            nextIDX = min(ds.currentIDX + ds.MiniBatchSize - 1, ds.NumObservations);

            % decode the index into sample name and augmentation
            [pathIdx, aIdx] = ind2sub([length(ds.allSampleNames), length(ds.augmentations)], ds.indices(ds.currentIDX:nextIDX));

            % fill the cells
            dataI = cell(length(pathIdx), 1);
            label = cell(length(pathIdx), 1);
            
            for i = 1:length(pathIdx)
                [dataI{i}, label{i}] = PreProcessData(ds, pathIdx(i), aIdx(i));
            end

            % create table
            dataTable = table(dataI, label);

            % move the index to the next sample
            ds.currentIDX = nextIDX + 1;
        end

        function [dataI, label] = PreProcessData(ds, pathIdx, aIdx)

            % load data and label
            load(ds.allSampleNames{pathIdx});

            % make the label categorical
            labelCropped = categorical(labelCropped);

            % apply transform
            if strcmp(ds.augmentations{aIdx}, 'original')
                % do nothing
                dataI = dataICropped;
                label = labelCropped;
            elseif strcmp(ds.augmentations{aIdx}, 'hflip')
                % horizontal flip
                dataI = fliplr(dataICropped);
                label = fliplr(labelCropped);
            elseif strcmp(ds.augmentations{aIdx}, 'vflip')
                dataI = flipud(dataICropped);
                label = flipud(labelCropped);
            elseif strcmp(ds.augmentations{aIdx}, 'rot90')
                dataI = rot90(dataICropped);
                label = rot90(labelCropped);
            elseif strcmp(ds.augmentations{aIdx}, 'rot180')
                dataI = rot90(dataICropped,2);
                label = rot90(labelCropped,2);
            else
                fprintf('unknown augmenattion method %s!\n', ds.augmentations{aIdx});
            end
        end

        % set the read sample to zero
        function reset(ds)
            ds.currentIDX = 1;
            ds.indices = randperm(ds.NumObservations);
        end
    end

    methods (Hidden = true)
        % Determine percentage of data read from datastore
        function frac = progress(ds)
            frac = (ds.currentIDX) / ds.numObservations;
        end
    end

end % end class definition