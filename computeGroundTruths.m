function [ finalFlairSizes ] = computeGroundTruths(coregisteredImages, directoryWithDWIROIs, directoryWithFlair3ROIs, dtheta, vectorLength, transforms, transform2PatientMap)
%COMPUTEGROUNDTRUTHS Computer the final sizes of the lesions in the flair3
%images, which are the Flair followup images. These final sizes will be
%used as ground truths. For each segmented flair3 region that corresponds 
%to the segmented lesion in the dwi image for the same patient, this
%function will trace vectors radially outwards from the centroid of the 
%lesion in the dwi image and will see where they intersect the boundary of
%the flair3 lesion to calculate the magnitude of the vector.
%   
%   Input:
%       coregisteredImages: The coregistered images calculated in
%       coregisterImages.
%       
%       directoryWithDWIROIs: Directory of DWI ROIs. Used to calculate    
%       the centroid of the dwi lesion for each image.   
%
%       directoryWithFlair3ROIs: Directory of flair3 ROIs so we can
%       calculate the polygon that defines the actual lesion.
%
%       dtheta: Angle to rotate vectors we trace by.
%   
%       vectorLength: Max magnitude of the vectors traced.
%
%       transforms: Affine transforms for coregistrations
%
%       transform2PatientMap: To tell what patient any given row in the
%           transforms matrix correponds to.
%   Output:
%       finalFlairSizes: The flair3 sizes calculated


    dirFlair3ROI = dir(directoryWithFlair3ROIs);
    dirDWIROI = dir(directoryWithDWIROIs);
    finalFlairSizes = [];

    for(i=1:length(coregisteredImages))
        patient = coregisteredImages(i).name;
        
        
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
        
        %Calculate the centroid
        centroid = calculateCentroid(ROIs);
        
        
        
        foundROI = false;
        %Load ROI information for the lesion in the flair3 image
        for(k=1:length(dirFlair3ROI))
            if regexp(dirFlair3ROI(k).name,strcat('^',patient,'_.*'))
                index = k;
                foundROI = true;
                break;
            end
        end
        
        
        %Could not find the ROI that defines the location of the lesion.
        %Skip patient
        if ~foundROI
            fprintf(strcat('Could not find the Flair 3 ROI file for patient ',patient,'. Skipping to next patient.\n'));
            continue;
        end
        
        Flair3ROIPathName = strcat(directoryWithFlair3ROIs,'/',dirFlair3ROI(index).name);
        Flair3ROIs = load(Flair3ROIPathName);
        
        %Now that we've loaded the Flair3ROIs, align it with the dwi image
        findTransform = (transform2PatientMap == str2num(patient));
        indexWithTransform = 0;
        foundTransform = false;
        for k=1:length(findTransform)
            if findTransform(k) == 1
                foundTransform = true;
                indexWithTransform = k;
                break;
            end
        end
        
        if ~foundTransform
            fprintf(strcat('Could not find the transform for patient ',patient,'. Aborting!.\n'));
            return;
        end
        
        affineTransformation = transforms(indexWithTransform,2);
        alignedFlair3ROIs = [];
        for k=1:size(Flair3ROIs,1)
            alignedFlair3ROIs = [alignedFlair3ROIs;[Flair3ROIs(k,:) 1]*affineTransformation.tdata.T];
        end
        Flair3ROIs = alignedFlair3ROIs;
        
        
        %Use extractIntensityProfiles soley for the purpose of tracing out
        %vectors as the function already returns vectors that would be
        %traced out radially outwards from the centroid
        [xCoordEval, yCoordEval] = extractIntensityProfiles(coregisteredImages(i).coregisteredFlair3, [centroid(1) centroid(2)],vectorLength,dtheta,2);

        
        %Find the intersection points of vectors that span out from centroids with the polygon defined by
        %the flair 3 lesion.
        finalSizeForPatient = [];
        couldNotFindIntersection = false;
        for vectorAngle=1:(360/dtheta)
            temp = [];
            for k=1:size(xCoordEval,2)
                temp = [temp;xCoordEval(vectorAngle,k) yCoordEval(vectorAngle,k)];
            end 
            pts = intersectPolylines([Flair3ROIs(:,1:2);Flair3ROIs(1,1:2)],temp);
            %Just take the first intersection point
            if isempty(pts)
               % couldNotFindIntersection = true;
               % break;        
               % Take current length of vector
               minDist = vectorLength;
            else
               intersectionPoint = pts(1,:);
               minDist = minDistance(centroid,intersectionPoint);
            end
            finalSizeForPatient = [finalSizeForPatient;minDist];

        end
        
       % if couldNotFindIntersection
       %     fprintf('Could not find intersection for patient %s for degree %d. Continuing to next patient.\n',patient,vectorAngle);
       %     continue;
       % end
        
        temp = struct();
        temp.patient = patient;
        temp.finalFlairSize = finalSizeForPatient;
        finalFlairSizes = [finalFlairSizes;temp];
    end

end

