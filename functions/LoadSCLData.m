function [ImageData, Im2Model] = LoadSCLData(FolderName, FileName)
    
    % read the metadata
    MetaData = readstruct(fullfile(FolderName, FileName), "FileType","xml");

    Im2Model = reshape(eval(strcat('[', MetaData.Geoposition.IMAGE_TO_MODEL_TRANSFORM, ']')), [2 3]);
    
    % create output image
    ImageData = zeros(MetaData.Raster_Dimensions.NROWS, MetaData.Raster_Dimensions.NCOLS, MetaData.Raster_Dimensions.NBANDS, 'single');

    for b = 1:size(ImageData, 3)
        bID = MetaData.Data_Access.Data_File(b).BAND_INDEX + 1;
        bName = strrep(MetaData.Data_Access.Data_File(b).DATA_FILE_PATH.hrefAttribute, 'hdr', 'img');
        
        % read the file into the imagedata container
        fID = fopen(fullfile(FolderName, bName));
        ImageData(:,:, bID) = fread(fID, [size(ImageData,2), size(ImageData,1)], "float32", 'b')';
        fclose(fID);
    end
end