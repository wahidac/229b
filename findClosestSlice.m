function [ closestSliceNum, dwiSliceNum ] = findClosestSlice(ROIFileName,ref_dwi,ref_other,other_size_series )
%FINDCLOSESTSLICE Find the slice in an image that is closest to the slice
%in the DWI image for which the lesion was found. 
%
%   Input:
%       ROIFileName: The ROIFileName.
%
%       ref_dwi: The slice that was used to mark points on the DWI for
%       coregistration
%
%       ref_other: The slice on the other image that corresponds to the
%       slice that ref_dwi refers to. By observing the offset of the two, we
%       can calculate where the lesion is in the other image.
%
%       other_size_series: How many slices are in the series the other
%       image belongs to
%
%   Output:
%       closestSliceNum: The closest slice number to the dwi slice number
%       we are interested. The DWI slice number of interest is specified in
%       ROIFileName
%
        dwiSliceNum = regexp(ROIFileName,'_','split');
        dwiSliceNum = dwiSliceNum(2);
        match = regexp(dwiSliceNum,'[0-9]+','match');
        match = match{1}{1};
        %Slice for which the segmented region is defined
        dwiSliceNum = str2num(match);
        
        offsetBetweenImages = ref_dwi - ref_other;
        offsetBetweenImages = int16(offsetBetweenImages);
        closestSliceNum = dwiSliceNum - offsetBetweenImages;
        
        if closestSliceNum < 1 || closestSliceNum > other_size_series
            error('Slice is out of bounds!');
            closestSliceNum = -1;
        end           
end

