function [ sorted ] = rankFitBackground( population, fitChunks, allCutIndex, wasCut, unshiftedChunks )
%==========================================================================
% This function will rank the different variable combinations
% in the population based on the chi squared. It will
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

% Get the number of total chunks
numChunks = length(allCutIndex) - 1;

% Get the number of variables and individuals in
% the population
[nInds, numVars] = size(population);

%--------------------------------------------------------------------------
% Put chunks into separate variables

% Set up loop variables
countFit = 0;
countLinear = 0;
i = 1;
    
while i <= numChunks
    countFit = countFit + 1;
    eval(sprintf('fitChunk%d = fitChunks{:,i};', countFit));
    eval(sprintf('unshiftedChunk%d = unshiftedChunks{:,i};', countFit));
    i = i + 1;
    if wasCut(countFit)
        countLinear = countLinear + 1;
        eval(sprintf('linearChunk%d = fitChunks{:,i};', countLinear));
        eval(sprintf('unshiftedLinearChunk%d = unshiftedChunks{:,i};', countLinear));
        i = i + 1;
    end
end

%--------------------------------------------------------------------------
% Check to make sure number of variables matches what
% you would expect
if numVars ~= (4*(countFit+1) + 2*countLinear)
    error('Number of variables does not match expectation.');
end

%--------------------------------------------------------------------------
% Get background coefficients
a1B = population(:,1); 
a2B = population(:,2); 
betaB = population(:,3); 
tauB = population(:,4); 

%--------------------------------------------------------------------------
% Get other nonlinear coefficients 

% Preallocate for speed
a1 = zeros(nInds,countFit);
a2 = zeros(nInds,countFit);
beta = zeros(nInds,countFit);
tau = zeros(nInds,countFit);

% Populate coefficients
count = 0;
for i = 5:4:4*(countFit+1)
    count = count + 1;
    a1(:,count) = population(:,i);
    a2(:,count) = population(:,i+1);
    beta(:,count) = population(:,i+2);
    tau(:,count) = population(:,i+3);
end

%--------------------------------------------------------------------------
% Get linear coefficients

% Preallocate for speed
m = zeros(nInds,countLinear);
b = zeros(nInds,countLinear);

% Set up loop variables
count = 0;
start = 4*(countFit+1) + 1;
finish = 4*(countFit+1) + 2*countLinear;

% Populate coefficients
for i = start:2:finish
    count = count + 1;
    m(:,count) = population(:,i);
    b(:,count) = population(:,i+1);
end

%--------------------------------------------------------------------------
% Try to fit each combo in your population
chiSquared = zeros(nInds,1);
for i = 1:nInds
    for j = 1:countFit
        eval(sprintf('yFit = (a1(i,j) - a2(i,j)*exp(-(fitChunk%d(:,1)/tau(i,j)).^beta(i,j))) + (a1B(i) - a2B(i)*exp(-(fitChunk%d(:,1)/tauB(i)).^betaB(i)));', j, j))
        eval(sprintf('chiSquared(i) = chiSquared(i) + sum((yFit - fitChunk%d(:,2)).^2)/length(fitChunk%d(:,1));', j, j));
    end
    
    for j = 1:countLinear
        eval(sprintf('yFit = (m(i,j)*linearChunk%d(:,1) + b(i,j)) + (a1B(i) - a2B(i)*exp(-(linearChunk%d(:,1)/tauB(i)).^betaB(i)));', j, j));
        eval(sprintf('chiSquared(i) = chiSquared(i) + sum((yFit - linearChunk%d(:,2)).^2)/length(linearChunk%d(:,1));', j, j));
    end    
end
        
%--------------------------------------------------------------------------
% Sort by chiSquared
[~, index] = sort(chiSquared);

sorted = zeros(size(population));
for i = 1:length(population)
    sorted(i,:) = population(index(i),:);
end

end

