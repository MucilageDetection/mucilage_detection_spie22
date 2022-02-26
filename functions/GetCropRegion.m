function [r1,r2,c1,c2] = GetCropRegion(siz, r, c, cropSize)
    
    % get the half crop size
    hCrop = round(cropSize / 2);
    
    r1 = r - hCrop(1);
    r2 = r1 + cropSize(1) - 1;
    
    c1 = c - hCrop(2);
    c2 = c1 + cropSize(2) - 1;
    
    % check that r in danger zone
    if r1 < 1
        r1 = 1;
        r2 = r1 + cropSize(1) - 1;
    elseif r2 > siz(1)
        r2 = siz(1);
        r1 = r2 - cropSize(1) + 1;
    end
    
    % check that c in danger zone
    if c1 < 1
        c1 = 1;
        c2 = c1 + cropSize(2) - 1;
    elseif c2 > siz(2)
        c2 = siz(2);
        c1 = c2 - cropSize(2) + 1;
    end
end