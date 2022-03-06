%% Bahri ABACI
% Vescovi Index for Sentinel-2 20m resolution
function VescoviIndex = GetVescoviIndex(data)
    VescoviIndex = (0.5 * (data(:,7) + data(:,2)) - data(:,1)) ./ data(:,8);
end