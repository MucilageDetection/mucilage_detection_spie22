% Bahri ABACI
%     PrismaDataFolder = 'D:\dataset\prisma';
%     PrismaZipFileName = 'PRS_L2D_STD_20210513090102_20210513090106_0001.zip';
function BandData = LoadPrismaData(PrismaZipDataFolder, PrismaZipFileName)
    
    % unzip the files into temp folder
    PrismaContent = unzip(fullfile(PrismaZipDataFolder,[PrismaZipFileName, '.zip']), 'temp');

    % grep the necessary files
    VNIR = h5read(PrismaContent{1}, '/HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/VNIR_Cube');
    SWIR = h5read(PrismaContent{1}, '/HDFEOS/SWATHS/PRS_L2D_HCO/Data Fields/SWIR_Cube');
    
    % create banddata
    VNIROrdered = flip(permute(VNIR, [3 1 2]), 3);
    SWIROrdered = flip(permute(SWIR, [3 1 2]), 3);

    BandData = cat(3, VNIROrdered, SWIROrdered);
    BandData = double(BandData) ./ 65536;

    % delete the temp directory
    status = rmdir('temp', 's');
    if ~status
        fprintf('temp folder cannot be removed, remove it manually!\n');
    end
end