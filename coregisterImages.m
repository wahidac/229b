function [ coregisteredImages ] = coregisterImages( transforms, transform2PatientMap, directoryWithMatData, directoryWithDWIROIs, pwiMatches  )
%COREGISTERIMAGES Using transforms computed in
%computerTransformsForCoregistration, will coregister all images of
%interest so that intesity profiles can be properly extracted.
%   Input:
%       transforms: Affine transforms for coregistrations
%
%       transform2PatientMap: To tell what patient any given row in the
%           transforms matrix correponds to.
%
%       directoryWithMatData:Path to directoy with the .mat files that
%           correspond to patients (eg. '1.mat','2.mat',...)
%       
%       directoryWithDWIROIs: Directory of DWI ROIs. Used to calculate    
%       the centroid of the dwi lesion for each image.   
%
%       pwiMatches: Matrix to determine for a given set of pwi slices,
%        which folder in the directoryWithMatData contains the
%        derived rCBF,rCBV,and TTP images.
%
%   Output:
%       coregisteredImages: Matrix of all coregistered images found.
%
    matData = dir(directoryWithMatData);
    dirDWIROI = dir(directoryWithDWIROIs);
    coregisteredImages = [];

    for(i=1:length(transform2PatientMap))
        patient = num2str(transform2PatientMap(i));
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
        currentPatient = struct(); %Store all the coregistered images here
        currentPatient.name = patient;
        
        %Use imtransform to apply transforms 
        %to image slice that is closet to the dwi slice for which we 
        %calculated the location of the lesion. Calculate this 
        %image slice using findClosestSlice. Do this for flair1 first
        [closestSliceNum, dwiSliceNum] = findClosestSlice(ROIPathName,ref_dwi,ref_flair1,size(flair1,3));
        if closestSliceNum == -1
            %function could not find a corresponding image slice
            return;
        end
        
        currentPatient.dwi = uint16(dwi(:,:,dwiSliceNum));
        affineTransformation = transforms(i,1);
        outputImageWidth = size(dwi,2);   %Number of columns in the dwi image matrix
        outputImageHeight = size(dwi,1);  %Number of rows in the dwi image matrix
        coregisteredImage = imtransform(uint16(flair1(:,:,closestSliceNum)),affineTransformation,'bicubic','Xdata',[1 outputImageWidth],'Ydata',[1 outputImageHeight]);
        
        currentPatient.coregisteredFlair1 = coregisteredImage;
   
        
        %Repeat for flair3
        closestSliceNum = findClosestSlice(ROIPathName,ref_dwi,ref_flair3,size(flair3,3));
        if closestSliceNum == -1
            return;
        end
        affineTransformation = transforms(i,2);
        coregisteredImage = imtransform(uint16(flair3(:,:,closestSliceNum)),affineTransformation,'bicubic','Xdata',[1 outputImageWidth],'Ydata',[1 outputImageHeight]);

        currentPatient.coregisteredFlair3 = coregisteredImage;

        
        %For rCBF, rCBV, and TTP, refer to the pwiMatch matrix to see what folder
        %corresponds to this patient. Then, load in the images w/ Dicomread
        %and repeat the process.
        closestSliceNum = findClosestSlice(ROIPathName,ref_dwi,ref_pwi,size(pwi,3));
        if closestSliceNum == -1
            return;
        end
        
        folderWithPwiDerivedData = pwiMatches(str2num(patient));
        pwiDerivedDataPath = strcat(directoryWithMatData,'/',num2str(folderWithPwiDerivedData));
        dirPwiDerivedData = dir(pwiDerivedDataPath);
        
        foundFile = false;
        for(k=1:length(dirPwiDerivedData))
            if regexp(dirPwiDerivedData(k).name,strcat('^','rCBV_.*'))
                index = k;
                foundFile = true;
                break;
            end
        end
        if ~foundFile
            fprintf(strcat('Could not find the rCBV file for patient ',patient),'. Skipping to next patient.\n');
            continue;
        end
        
        rCBVPath = strcat(pwiDerivedDataPath,'/',dirPwiDerivedData(index).name);
        
        foundFile = false;
        for(k=1:length(dirPwiDerivedData))
            if regexp(dirPwiDerivedData(k).name,strcat('^','rCBF_.*'))
                index = k;
                foundFile = true;
                break;
            end
        end
        
        
        if ~foundFile
            fprintf(strcat('Could not find the rCBF file for patient ',patient,'. Skipping to next patient.\n'));
            continue;
        end

        rCBFPath = strcat(pwiDerivedDataPath,'/',dirPwiDerivedData(index).name);
        
        foundFile = false;
        for(k=1:length(dirPwiDerivedData))
            if regexp(dirPwiDerivedData(k).name,strcat('^','TTP_.*'))
                index = k;
                foundFile = true;
                break;
            end
        end
        
        if ~foundFile
            fprintf(strcat('Could not find the TTP file for patient ',patient,'. Skipping to next patient.\n'));
            continue;
        end

        TTPPath = strcat(pwiDerivedDataPath,'/',dirPwiDerivedData(index).name);
        
        %Load rCBV dicom files
        [volume_image,slice_data,image_meta_data] = dicom23D(rCBVPath);
        %Resize the image we're interested in
        resizedImage = imresize(uint16(volume_image(:,:,closestSliceNum)),'Scale',[image_meta_data.PhysicalAspectRatio(1) image_meta_data.PhysicalAspectRatio(2)]);
        %flip it
        resizedImage = flipdim(resizedImage,2);
        %Now that it is aligned w/ pwi, apply the pwi transform.
        affineTransformation = transforms(i,3);
        coregisteredImage = imtransform(resizedImage,affineTransformation,'bicubic','Xdata',[1 outputImageWidth],'Ydata',[1 outputImageHeight]);
        
        currentPatient.coregisteredRCBV = coregisteredImage;

        
        %Load the rCBF dicom files
        [volume_image,slice_data,image_meta_data] = dicom23D(rCBFPath);
        %Resize the image we're interested in
        resizedImage = imresize(uint16(volume_image(:,:,closestSliceNum)),'Scale',[image_meta_data.PhysicalAspectRatio(1) image_meta_data.PhysicalAspectRatio(2)]);
        %flip it
        resizedImage = flipdim(resizedImage,2);
        coregisteredImage = imtransform(resizedImage,affineTransformation,'bicubic','Xdata',[1 outputImageWidth],'Ydata',[1 outputImageHeight]);

        currentPatient.coregisteredRCBF = coregisteredImage;

   
        %Load the TTP dicom files
        [volume_image,slice_data,image_meta_data] = dicom23D(TTPPath);
        %Resize the image we're interested in
        resizedImage = imresize(uint16(volume_image(:,:,closestSliceNum)),'Scale',[image_meta_data.PhysicalAspectRatio(1) image_meta_data.PhysicalAspectRatio(2)]);
        %flip it
        resizedImage = flipdim(resizedImage,2);
        coregisteredImage = imtransform(resizedImage,affineTransformation,'bicubic','Xdata',[1 outputImageWidth],'Ydata',[1 outputImageHeight]);

        currentPatient.coregisteredTTP = coregisteredImage;
        coregisteredImages = [coregisteredImages;currentPatient];
        
        fprintf('Co-registered images for patient %s\n',patient);
        
    end
    

end

