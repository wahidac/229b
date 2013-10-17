function [inputData] = undoInputDataNormalization( normalizedInputData, maxMinVals, samplesPerProfile )
    %Return input Data to original state before normalizing 
    numCols = size(normalizedInputData,2);
    inputData = [];

    for(i=1:(numCols/samplesPerProfile))
        offset = (i-1)*samplesPerProfile + 1;
        profiles = normalizedInputData(:,offset:offset+samplesPerProfile-1);
        maxVal = maxMinVals(i,1);
        minVal = maxMinVals(i,2);
        
        profiles = profiles*(maxVal - minVal) + minVal;
        inputData = [inputData profiles];
    end
    

end

