function [inputData, gndTruths, model ] = trainModel(profiles,finalFlairSize,trainingSetSize, modelType)

    gndTruths = [];
    inputData = [];
    for i=1:size(finalFlairSize,1)
        gndTruths = [gndTruths;finalFlairSize(i).finalFlairSize];
        currentPatient = finalFlairSize(i).patient;
        
           findIndexForPatient(currentPatient, profiles);    
        
        %Find corresponding patients input info
        for k=1:size(profiles,1)
            p = profiles(k).patient;
            if strcmp(p,currentPatient)
                %add to input data array
                inputData = [inputData;[profiles(k).dwiProfiles profiles(k).rCBVProfiles profiles(k).rCBFProfiles profiles(k).TTPProfiles]];
                foundPatient = true;
                break;
            end
        end
        
        if ~foundPatient
             fprintf('Failed to find patient: %s\n',currentPatient);
             return;
        end
    end
    
    
    numVectorDirections = size(profiles(1).dwiProfiles,1);
    trainingData = inputData(1:trainingSetSize*numVectorDirections,:);
    trainingDataLabels = gndTruths(1:trainingSetSize*numVectorDirections,:);
    
    % normalize trainingDataLabels (minValue, maxValue)
    % check for dwi, flair followup (min, max)
    % normalize each map individualy  
%    DWI = profiles(1:).dwiProfiles    
 %   DWI - min(DWI) ./ (max(DWI) - min(DWI))
    
    
    
    %Train using SRDAtrain
    if modelType == 0
          model = SRDAtrain(trainingData,trainingDataLabels);
    %Use SRKDAtrain
    else
          model = SRKDAtrain(trainingData,trainingDataLabels);
    end
end

