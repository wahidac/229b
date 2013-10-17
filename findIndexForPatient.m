function [ index ] = findProfilesForPatient( patient, arrayOfPatients )
%FINDPROFILESFORPATIENT Summary of this function goes here
%   Detailed explanation goes here
       for k=1:size(arrayOfPatients,1)
           p = arrayOfPatients(k).patient;
           if strcmp(p,patient)
               %add to input data array
               foundPatient = true;
               index = k;
               break;
           end
       end
        
       if ~foundPatient
            fprintf('Failed to find patient: %s\n',currentPatient);
            index = -1;
       end
end

