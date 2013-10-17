function [ AllProfiles ] = extractProfilesFromAllImages( coregisteredImages, directoryWithMatData, directoryWithDWIROIs,pwiMatches )
%EXTRACTPROFILESFROMALLIMAGES Iterate through coregistered images and
%extract intensity profiles along vectors centered at the center of gravity
%of the DWI image lesion that expand radially outwards.
%   Input:
%        coregisteredImages: The coregistered images calculated in
%        coregisterImages.
%    
%        directoryWithMatData:Path to directory with the .mat files that
%        correspond to patients (eg. '1.mat','2.mat',...)
%
%        directoryWithDWIROIs: Directory of DWI ROIs. Used to calculate    
%        the centroid of the dwi lesion for each image.   
%
%        pwiMatches: Matrix to determine for a given set of pwi slices,
%        which folder in the directoryWithMatData contains the
%        derived rCBF,rCBV,and TTP images.
%
%   Output:
%        AllProfiles: Matrix of the extracted profiles.

    dirMatData = dir(directoryWithMatData);
    dirDWIROI = dir(directoryWithDWIROIs);
    AllProfiles = [];
    %Parameters for intensity profile extraction.
    vectorLength = 65;
    dtheta = 5;
    numberPointsForEachProfile = 65;
  
    
    for(i=1:length(coregisteredImages))
        patient = num2str(coregisteredImages(i).name);
        dataPathName = strcat(directoryWithMatData,'/',patient);

        %Load .mat file corresponding to this patient
        load(dataPathName);
        
        foundROI = false;
        %Load ROI information for the lesion in the DWI
        for(k=1:length(dirDWIROI))
            if regexp(dirDWIROI(k).name,strcat('^',patient,'_.*'))
                index = k;
                foundROI = true;
                break;
            end
        end
        
        %Could not find the ROI that defines the location of the lesion.
        %Skip this patient
        if ~foundROI
            fprintf(strcat('Could not find the DWI ROI file for patient ',patient,'. Skipping to next patient.\n'));
            continue;
        end
            
        
        ROIPathName = strcat(directoryWithDWIROIs,'/',dirDWIROI(index).name);
        ROIs = load(ROIPathName);
        
        %Calculate the centroid of the lesion
        centroid = calculateCentroid(ROIs);
        
        
        %Calculate intensity profiles for the dwi.
        closestSliceNum = findClosestSlice(ROIPathName,ref_dwi,ref_dwi,size(dwi,3));
        [xCoordEval, yCoordEval, dwiProfiles] = extractIntensityProfiles(dwi(:,:,closestSliceNum), [centroid(1) centroid(2)],vectorLength,dtheta,numberPointsForEachProfile);

        
        % Now we need to extract intensity profiles from flair1 and flair3
        % (i.e. flair upon patient admittance and followup flair
        % respectively)
        
        coregisteredImage = coregisteredImages(i).coregisteredFlair1;
        [xCoordEval, yCoordEval, flair1Profiles] = extractIntensityProfiles(coregisteredImage, [centroid(1) centroid(2)],vectorLength,dtheta,numberPointsForEachProfile);
        
        %repeat for flair3
        coregisteredImage = coregisteredImages(i).coregisteredFlair3;
        [xCoordEval, yCoordEval, flair3Profiles] = extractIntensityProfiles(coregisteredImage, [centroid(1) centroid(2)],vectorLength,dtheta,numberPointsForEachProfile);
        
        
        %rCBV
        coregisteredImage = coregisteredImages(i).coregisteredRCBV;
        [xCoordEval, yCoordEval, rCBVProfiles] = extractIntensityProfiles(coregisteredImage, [centroid(1) centroid(2)],vectorLength,dtheta,numberPointsForEachProfile);
        
        %rCBF
        coregisteredImage = coregisteredImages(i).coregisteredRCBF;
        [xCoordEval, yCoordEval, rCBFProfiles] = extractIntensityProfiles(coregisteredImage, [centroid(1) centroid(2)],vectorLength,dtheta,numberPointsForEachProfile);
             
   
        %TTP
        coregisteredImage = coregisteredImages(i).coregisteredTTP;
        [xCoordEval, yCoordEval, TTPProfiles] = extractIntensityProfiles(coregisteredImage, [centroid(1) centroid(2)],vectorLength,dtheta,numberPointsForEachProfile);
        
        profiles = struct();
        profiles.patient = coregisteredImages(i).name;
        profiles.dwiProfiles = dwiProfiles;
        profiles.flair1Profiles = flair1Profiles;
        profiles.flair3Profiles = flair3Profiles;
        profiles.rCBVProfiles = rCBVProfiles;
        profiles.rCBFProfiles = rCBFProfiles;
        profiles.TTPProfiles = TTPProfiles;
        AllProfiles = [AllProfiles;profiles];
        fprintf('Successfully extracted profiles from patient %s\n',patient);
        
    end


end

