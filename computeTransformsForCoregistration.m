function [transforms, filesProcessed] = computeTransformsForCoregistration( directoryWithData )
%COMPUTETRANSFORMSFORCOREGISTRATION Returns a vector of cp2tforms
%   Load all the .mat files that represent patient data
%   and compute 3 affine transforms: one for flair1 to dwi,
%   one for flair3 to dwi, and one from pwi to dwi. 
%   Input:
%       directoryWithData: Path to directoy with the .mat files that
%       correspond to patients (eg. '1.mat','2.mat',...)
%   Output:
%     transforms: Matrix of struct that represent transformations
%       computed by cp2tform. Dimensions = #patients x 3. For any row, the
%       first column is the flair1ToDwi affine transformation, the second
%       column is the flair3ToDwi affine transformation, and the third
%       column is the pwiToDwi affine transformation.
%     filesProcessed: Vector of .mat files processed
%               
    dirData = dir(directoryWithData);
    filesIndex = ~[dirData.isdir];
    transforms = [];
    filesProcessed = [];

    for(i=1:length(dirData))
        if filesIndex(i) %this is a file
            data = dirData(i);
            fileName = strcat(directoryWithData,'/',data.name);
            [path,name,ext] = fileparts(fileName);
            if strcmp(ext,'.mat') && ~isempty(str2num(name))
                load(fileName);
                flair1ToDwi = cp2tform(pt_flair1,pt_dwi,'affine');
                flair3ToDwi = cp2tform(pt_flair3,pt_dwi,'affine');
                pwiToDwi = cp2tform(pt_pwi,pt_dwi,'affine');
                tforms = [flair1ToDwi flair3ToDwi pwiToDwi];
                transforms = [transforms;tforms];
                filesProcessed = [filesProcessed;str2num(name)];
            end 
        end
    end
end

