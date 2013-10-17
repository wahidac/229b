function [ xcoordEvaluated, ycoordEvaluated, intensityProfiles ] = extractIntensityProfiles( image, startCoordinate, r, dtheta,N)
%EXTRACTINTENSITYPROFILES Extract intensity profiles from image
%   Given an image, a starting point startCoordinate, vector length r, and angle increment
%   dtheta, and number of points N to evaluate along each vector,
%   this function will calculate intensity profiles along vectors
%   with length r that start at startingCoordinate. The parameter dtheta
%   defines the orientation of successive vectors from which we will
%   extract intensity profiles from.

    %Increment theta by dtheta after each iteration to rotate the vector
    %along which we will extract our intensity profile
    theta = 0;
    intensityProfiles = [];
    %matrix of points 
    pointsEvaluated = []; 
    xcoordEvaluated = [];
    ycoordEvaluated = [];
    while theta < 360 
        %Rotate the vector of length r, centered at startingCoordinate
        %360 degrees
        endingCoordinate = startCoordinate + [r*cos(deg2rad(theta)) r*sin(deg2rad(theta))];
        [cx,cy,c] = improfile(image,[startCoordinate(1) endingCoordinate(1)],[startCoordinate(2) endingCoordinate(2)],N,'bicubic');
        %pointsEvaluated = 
        intensityProfiles = [intensityProfiles;c'];
        xcoordEvaluated = [xcoordEvaluated;cx'];
        ycoordEvaluated = [ycoordEvaluated;cy'];
        theta = theta + dtheta;
    end
end

