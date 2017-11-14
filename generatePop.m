function [ population ] = generatePop( bounds, nInds, coefs )
%==========================================================================
% This function will try to fit the given chunk to a stretched
% exponential curve using the given boundaries for points 
% (bounds). The numbers in bounds correspond to the boundaries
% for a1, a2, beta, and tau, respectively. 
%
% The function will randomly generate starting points and a cut
% point (if first chunk and user wants to cut) and rank the
% combination based on r-squared. The function will choose the
% best fit and return the results.
%
% Functions called:
%           rand - MATLAB function to generate random numbers
%           mutreal - GA toolbox function to mutate 
%                     population
%
% Called by functions:
%           cutGA - use GA to find best spot to cut linear
%           GAFitBackground - fits all of the chunks together
%                             along with a background
%                             stretched exponential function
%           waitbar - MATLAB function used to give user an 
%                     update of progress
%
% Input data:
%           bounds - given bounds for the population
%
% Output data:
%           population - randomly generated population
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Get number of individuals from bounds
[~, nVars] = size(bounds);

% Initialize population
population = zeros(nInds, nVars);

%--------------------------------------------------------------------------
% If you don't give starting coefficients
if nargin == 2
    % Populate population with random variables
    for i = 1:nVars
        population(:,i) = rand([nInds,1]).*(bounds(2,i) - bounds(1,i)) + bounds(1,i);
    end
    
%--------------------------------------------------------------------------
% If you give starting coefficients
elseif nargin == 3
    % Get random background coefficients within bounds
    
    % Prealloate for speed
    backgroundCoefs = zeros(1,4);
    
    % Populate random coefficients
    for i = 1:4
        backgroundCoefs(i) = rand([1,1]).*(bounds(2,i) - bounds(1,i)) + bounds(1,i);
    end

%--------------------------------------------------------------------------    
    % Populate other coefficients by mutating results
    % from MATLAB's basic fit
    population(1,:) = [backgroundCoefs coefs];
    for i = 2:nInds
        population(i,:) = mutreal(population(1,:), bounds, 0.9);
    end
    
%--------------------------------------------------------------------------    
% Check number of argumnets for errors
else
    if nargin < 2
        display('Not enough input arguments.');
    elseif nargin > 3
        display('Too many input arguments');
    end
end
end

