function [ sorted ] = rankCut( x, y, population )
%==========================================================================
% This function will rank the different cut points based on
% the chi squared of the resulting linear portion. It will
% then sort the population and return the sorted array.
%
% Functions called:
%           getChiSquared - takes a function output from
%                           MATLAB's fit function and finds
%                           the chi squared given a data set
%
% Called by functions:
%           cutGA - use GA to find best spot to cut linear
%
% Input data:
%           x and y - data points
%           population - contains all of the points within
%                        the bounds to be ranked and sorted
%
% Output data:
%           sorted - sorted population array based on chi
%                    squared
%           chiSquared - array of chiSquared values
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Initialize variables to save time
chiSquared = zeros(length(population), 1);
cutPoint = zeros(length(population), 1);

% Define x and y for linear chunks
for i = 1:length(population)
    cutPoint(i) = floor(population(i)*length(x));

    x1{:,i} = x(cutPoint(i):end); %#ok<AGROW>
    y1{:,i} = y(cutPoint(i):end);  %#ok<AGROW>

end

%--------------------------------------------------------------------------
% In parallel, fit the linear portion to a line and get the
% chi squared to rank
parfor i = 1:length(population)
    x = x1{1,i};
    y = y1{1,i};

    [fitresult, ~] = fit(x, y, 'poly1');
    
    chiSquared(i) = getChiSquared(x, y, fitresult);
end
        
%--------------------------------------------------------------------------
% Sort by chi squared

[~, index] = sort(chiSquared);
sorted = zeros(size(population));

for i = 1:length(population)
    sorted(i,:) = population(index(i),:);
end

end