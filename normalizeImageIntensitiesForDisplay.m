function [ dwi, flair1, flair3, rCBV, rCBF, TTP, img] = normalizeImageIntensitiesForDisplay( coregisteredImages )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    dwi = double(coregisteredImages.dwi);
    dwi = dwi/max(dwi(:));
    
    flair1 = double(coregisteredImages.coregisteredFlair1);
    flair1 = flair1/max(flair1(:));
    
    flair3 = double(coregisteredImages.coregisteredFlair3);
    flair3 = flair3/max(flair3(:));
    
    rCBV = double(coregisteredImages.coregisteredRCBV);
    rCBV = rCBV/max(rCBV(:));
    
    rCBF = double(coregisteredImages.coregisteredRCBF);
    rCBF = rCBF/max(rCBF(:));
    
    TTP = double(coregisteredImages.coregisteredTTP);
    TTP = TTP/max(TTP(:));
    
    img = [];
    img(:,:,1) = dwi;
    img(:,:,2) = flair3;
    img(:,:,3) = TTP;
    
end

