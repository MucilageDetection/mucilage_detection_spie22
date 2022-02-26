function [FileName, date] = SentinelFolderNameToFileName(folderName, taleString)

    % S2A_MSIL2A_20200815T085601_N0214_R007_T35TPF_20200815T120903
    % T35TPF_20200815T085601_AOT_10m
    date  = folderName(12:19);
    group = folderName(20:26);
    tile  = folderName(39:44);
    
    % create the filename
    FileName = sprintf('%s_%s%s', tile, date, group);
    
    % add the tale string if exist
    FileName = [FileName, taleString];
end