function plotPredictedLesionSizes( coregisteredImage, patient, directoryWithDWIROIs,predictedSizes)
    dirDWIROI = dir(directoryWithDWIROIs);
    %Parameters for intensity profile extraction.
    dtheta = 360/length(predictedSizes);
 
    foundROI = false;
    %Load ROI information for the lesion in the DWI
    for(k=1:length(dirDWIROI))
        if regexp(dirDWIROI(k).name,strcat('^',patient,'_.*'))
            index = k;
            foundROI = true;
            break
        end
    end
        
    %Could not find the ROI that defines the location of the lesion.
    %Skip this patient
    if ~foundROI
        fprintf(strcat('Could not find the DWI ROI file for patient'));
        return;
    end
            
        
    ROIPathName = strcat(directoryWithDWIROIs,'/',dirDWIROI(index).name);
    ROIs = load(ROIPathName);
        
    %Calculate the centroid
    centroid = calculateCentroid(ROIs);
    imagesc(coregisteredImage); 
    hold on;
    theta = 0;
    for k=1:length(predictedSizes)
        r = predictedSizes(k);
        endingCoordinate = centroid + [r*cos(deg2rad(theta)) r*sin(deg2rad(theta))];
        plot([centroid(1) endingCoordinate(1)],[centroid(2) endingCoordinate(2)],'g');
        theta = theta + dtheta;
    end
    
    %for k=1:length(predictedSizes)
    %    r =65;
    %    endingCoordinate = centroid + [r*cos(deg2rad(theta)) r*sin(deg2rad(theta))];
    %    plot([centroid(1) endingCoordinate(1)],[centroid(2) endingCoordinate(2)],'r');
    %    theta = theta + dtheta;
    %end
    
    
    hold off;
        
end

