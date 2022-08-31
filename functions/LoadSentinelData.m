% Bahri ABACI
%     SentinelDataFolder = 'D:\dataset\sentinel2';
%     SentinelZipFileName = 'S2A_MSIL2A_20210519T084601_N0300_R107_T35TPE_20210519T115101';
%     Resolution = 20;
%     BandNames = {'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B11', 'B12'};
function [BandData, ContentMetaData] = LoadSentinelData(SentinelZipDataFolder, SentinelZipFileName, Resolution, BandNames)
        
    % set the resolution folder
    InputResolutionFolder = sprintf('R%dm', Resolution);

    % unzip the files into temp folder
    SentinelContent = unzip(fullfile(SentinelZipDataFolder,[SentinelZipFileName, '.zip']), 'temp');
    
    % read the metadata of the file
    MetaDataFileName = SentinelContent(contains(SentinelContent, 'MTD_TL.xml'));
    ContentMetaData = readstruct(MetaDataFileName{1});

    % grep the necessary files
    SentinelContentForCurrentResolution = SentinelContent(contains(SentinelContent, InputResolutionFolder));

    % create empty data array
    BandSize = 10980 * 10 / Resolution;
    BandData = zeros(BandSize, BandSize, length(BandNames), 'uint16');

    % pass over the all bands
    for j = 1:length(BandNames)
        BandData(:,:,j) = imread(SentinelContentForCurrentResolution{contains(SentinelContentForCurrentResolution, BandNames{j})});
    end
    
    % normalize reflectance
    % TODO: use metadata values
    % 10000: str2double(ContentMetaData.n1_General_Info.Product_Image_Characteristics.QUANTIFICATION_VALUES_LIST.BOA_QUANTIFICATION_VALUE.Text)
    % 1000:  ContentMetaData.n1_General_Info.Product_Image_Characteristics.BOA_ADD_OFFSET_VALUES_LIST.BOA_ADD_OFFSET(i)  
    ProcessingBaseline = str2double(SentinelZipFileName(29:32));
    if ProcessingBaseline >= 400
        invalidIdx = BandData == 0;
        BandData = double(BandData - 1000) ./ 10000;
        BandData(invalidIdx) = 0;
    else
        BandData = double(BandData) ./ 10000;
    end
    
    % delete the temp directory
    status = rmdir('temp', 's');
    if ~status
        fprintf('temp folder cannot be removed, remove it manually!\n');
    end
end