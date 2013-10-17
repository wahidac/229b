function [ output_args ] = validateGndTruthsAndInputData( inputData, gndTruths, FinalFlairSizes, AllProfiles )
%VALIDATEGNDTRUTHSANDINPUTDATA Summary of this function goes here
%   Detailed explanation goes here
    numVectorDirections = size(AllProfiles(1).dwiProfiles,1);
    for i=1:size(FinalFlairSizes,1)
        index = (i-1)*72;
        if index == 0
            index = 1;
        end
        
        patient = FinalFlairSizes(i).patient;
        
        
        for k=index:index+(numVectorDirections - 1)
           %Verify that this row is legit
           
           expectedRow = 
        end
 


end

