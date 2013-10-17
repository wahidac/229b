function [ centroid ] = calculateCentroid( points )
%CALCULATECENTROID Takes the average of the points to get the centroid
    numPoints = length(points);
    centroid = sum(points)/numPoints;
end

