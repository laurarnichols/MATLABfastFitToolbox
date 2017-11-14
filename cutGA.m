function [ cutIndex ] = cutGA( x, y )
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
%           generatePop - generate a population for GA based
%                         on given bounds
%           rankCut - rank the cut points based on the chi
%                     squared of the resulting linear portion
%           reclin - GA toolbox function to do linear
%                    recombination of parents
%           mutreal - GA toolbox to mutate population
%
% Called by functions:
%           getCutPoints - cut linear portions if applicable
%
% Input data:
%           x and y - data points
%
% Output data:
%           cutIndex - linear cut points
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Set parameters for optimization
nInds = 500; 
nParents = floor(nInds*0.75);
numVars = 1;
bounds = [0.2; 0.8];

%--------------------------------------------------------------------------
% Generate population
population = generatePop(bounds);

%--------------------------------------------------------------------------
% Initialize loop variables
numGens = 10;

for gen = 1:numGens
    for i = 1:nInds
        for j = 1:numVars
            if population(i,j) > bounds(2,j)
                population(i,j) = bounds(2,j);
            elseif population(i,j) < bounds(1,j)
                population(i,j) = bounds(1,j);
            end
        end
    end
    
    population = rankCut(x, y, population);
    
    % Select parents and breed
    topDogs = population(1:nParents, :);
    topDogKids = reclin(topDogs);
    
    if gen > 2
        epsilon = abs(topDogs(1,:) - solution);
        if epsilon < 1e-3 
            break
        end
    end    
    
    solution = topDogs(1,:);
    
    % Mutate population
    mutTopDogs = mutreal(topDogs, bounds, 0.75);
 
    % Put kids in new population
    population(1:nParents, :) = mutTopDogs;
    population((nInds-nParents+1):nInds, :) = topDogKids;
end

%--------------------------------------------------------------------------
% Get cut index from GA solution
cutIndex = floor(solution*length(x));

end
