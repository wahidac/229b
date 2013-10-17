function [ normalizedInputData,maxMinVals ] = normalizeInputData( inputData,samplesPerProfile )
%Normalize input data so it is suitable to be used in SRKDA. Return max and
%min values used to normalize so we can map back to original values
numCols = size(inputData,2);
normalizedInputData = [];
maxMinVals = [];

for(i=1:(numCols/samplesPerProfile))
    offset = (i-1)*samplesPerProfile + 1;
    profilesToNormalize = inputData(:,offset:offset+samplesPerProfile-1);
    maxVal = max(profilesToNormalize(:));
    minVal = min(profilesToNormalize(:));
    
    %Normalize
    profilesToNormalize = (profilesToNormalize - minVal) ./ (maxVal - minVal);
    normalizedInputData = [normalizedInputData profilesToNormalize];
    maxMinVals = [maxMinVals;[maxVal minVal]];
end

end

