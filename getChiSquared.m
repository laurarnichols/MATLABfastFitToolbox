function [ chiSquared ] = getChiSquared( x, y, fitresult )
%==========================================================================
% This function takes the function output from MATLAB's fit
% function and gets the chi squared for a given data set.
%
% Functions called:
%           N/A
%
% Called by functions:
%           rankCut - rank the cut points based on the chi
%                     squared of the resulting linear portion
%           GAFitBackground - fits all of the chunks together
%                             along with a background
%                             stretched exponential function
%
% Input data:
%           x and y - data points
%           fitresult - function result from MATLAB's fit
%                       function
%
% Output data:
%           chiSquared - array of chiSquared values
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Get y-values for the fit
yFit = fitresult(x);

% Get chi squared
chiSquared = sum((yFit - y).^2)/length(x);
end

