function sentinelBandData = GetSentinelBandEquaivelant(bandData, bandWavelengths, sentinelSRFs)
    
    % get the sentinel responses for each band
    [~, ia] = intersect(sentinelSRFs(:,1), round(bandWavelengths));

    % get the sentinel equivalent by summing the all bands in range
    bandData1D = reshape(bandData, [size(bandData,1)*size(bandData,2), size(bandData,3)]);

    % norm of the sentinel
    norm = repmat(sum(sentinelSRFs(ia,2:end),1), [size(bandData1D,2),1]);

    % get the weighted summation
    sentinelBandData = reshape(bandData1D * (sentinelSRFs(ia,2:end) ./ norm), [size(bandData,1), size(bandData,2), size(sentinelSRFs,2)-1]);
end