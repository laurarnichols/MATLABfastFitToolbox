function [ coefs, chiSquared, fitresult ] = GAFitSingle( x, y, bounds)
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
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Make sure the bounds matrix is the right size
[numBounds, numVars] = size(bounds);
if numBounds ~= 2, error('Bounds must be a matrix with 2 rows'); end
if numVars ~= 3, error('Bounds must have 3 columns (1 for each variable).'); end

%--------------------------------------------------------------------------
% Set parameters for optimization
nInds = 500; 
nParents = floor(nInds*0.75);

%--------------------------------------------------------------------------
% Generate population
population = generatePop(bounds, nInds);

%--------------------------------------------------------------------------
% Initialize loop variables
numGens = 20;

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
    
    population = rankFit(x, y, population);
        
    % Select parents and breed
    topDogs = population(1:nParents, :);
    topDogKids = reclin(topDogs);
    solution = topDogs(1,:);
    
    % Mutate population
    mutTopDogs = mutreal(topDogs, bounds, 0.75);
 
    % Put kids in new population
    population(1:nParents, :) = mutTopDogs;
    population((nInds-nParents+1):nInds, :) = topDogKids;
end

%--------------------------------------------------------------------------
% Fit using best parameters
startHeight = y(1);
ft = fittype( sprintf('a1-(a1-%d)*exp(-(t/tau)^beta)', startHeight), 'independent', 't', 'dependent', 'y' );

coefs = [ solution(1); solution(1) - startHeight; solution(2); solution(3)];

fitresult = cfit(ft, coefs(1), coefs(3), coefs(4));
chiSquared = getChiSquared(x, y, fitresult);

end

