% Bahri ABACI
%     SentinelDataFolder = 'E:\Dropbox\Dataset\satellite\sentinel2';
%     SentinelZipFileName = 'S2A_MSIL2A_20210519T084601_N0300_R107_T35TPE_20210519T115101.zip';
%     Resolution = 20;
%     BandNames = {'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B8A', 'B11', 'B12'};
function [BandData, TCI, SCL] = LoadSentinelData(SentinelDataFolder, SentinelZipFileName, Resolution, BandNames)
        
    % set the resolution folder
    InputResolutionFolder = sprintf('R%dm', Resolution);

    % unzip the files into temp folder
    SentinelContent = unzip(fullfile(SentinelDataFolder, SentinelZipFileName(40:44), SentinelZipFileName), 'temp');
    
    % grep the necessary files
    SentinelContentForCurrentResolution = SentinelContent(contains(SentinelContent, InputResolutionFolder));

    % create empty data array
    BandSize = 10980 * 10 / Resolution;
    BandData = zeros(BandSize, BandSize, length(BandNames), 'uint16');

    % pass over the all bands
    for j = 1:length(BandNames)
        BandData(:,:,j) = imread(SentinelContentForCurrentResolution{contains(SentinelContentForCurrentResolution, BandNames{j})});
    end
    
    % read the TCI band
    TCI = imread(SentinelContentForCurrentResolution{contains(SentinelContentForCurrentResolution, 'TCI')});
    
    % read the SCL band
    if Resolution > 10
        SCL = imread(SentinelContentForCurrentResolution{contains(SentinelContentForCurrentResolution, 'SCL')});    
    else
        SCL = [];
    end
    
    % delete the temp directory
    rmdir('temp', 's');
end