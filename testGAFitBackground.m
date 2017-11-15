function [ chiSquared, fitresult, chiSquaredLinear, fitresultLinear ] = testGAFitBackground( x, y, coefs, bounds, fitChunks, allCutIndex, wasCut, unshiftedChunks )
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
%           generatePop - generates random values for
%                         population within given bounds
%           waitbar - MATLAB function used to display
%                     progress bar
%           rankFitBackgroundGen - ranks and sorts the
%                                  population based on chi
%                                  squared; works for any
%                                  arbitrary number of chunks
%           rankFitBackground4 - ranks and sorts the
%                                population based on chi
%                                squared; works for 4 chunks
%           reclin - GA toolbox function to do linear
%                    recombination of parents
%           mutreal - GA toolbox function to mutate 
%                     population
%           cFit - MATLAB function to produce function for 
%                  evaluation; similar to output of fit
%                  function
%           getChiSquared - takes a function output from
%                           MATLAB's fit function and finds
%                           the chi squared given a data set
%
% Called by functions:
%           getFit - sends user information and turning 
%                    points, separates the chunks, and fits
%                    the data
%           reclin - GA toolbox function to do linear
%                    recombination of parents
%           mutreal - GA toolbox to mutate population
%
% Input data:
%           fitChunks, allCutIndex, wasCut, unshiftedChunks
%           x and y - data points
%           bounds - given bounds for each of the fit 
%                    variables
%           fitChunks - cell array containing separated 
%                       chunks already shifted to be fit
%           allCutIndex - vector containing 
%           wasCut - vector containing boolean values for
%                    whether each chunk was linearly cut
%           unshiftedChunks - cell array containing separated 
%                       chunks that are unshifted
%
% Output data:
%           chiSquared - array of chi squared values for 
%                        each nonlinear chunk
%           fitresult - function output from MATLAB's fit
%                       function for nonlinear chunks
%           chiSquaredLinear - array of chi squared values 
%                              for each linear chunk
%           fitresultLinear - function output from MATLAB's 
%                             fit function for linear chunks
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Get the number of total chunks
numChunks = length(allCutIndex) - 1;
numStrExpChunks = length(wasCut);

% Set up loop variables
countFit = 0;
countLinear = 0;
i = 1;
    
%--------------------------------------------------------------------------
% Break up chunks
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
% Set this value to 1 if you want to look at the 
% background
testing = 0;
time = 0;

% Make sure the bounds matrix is the right size
[numBounds, numVars] = size(bounds);
if numBounds ~= 2, error('Bounds must be a matrix with 2 rows'); end

% Get number of total chunks and variables
numChunks = length(allCutIndex) - 1;
numStrExpChunks = numChunks - sum(wasCut);

testPlot(1, x, y, 0, wasCut, unshiftedChunks, fitChunks, coefs, 1)

diff = 0.1*coefs;
chunkBounds = [coefs-diff; coefs+diff];

newBounds = [bounds(:,1:4) chunkBounds bounds(:,5:end)];
bounds = newBounds;

% Adjust bounds if needed
for i = 1:numStrExpChunks
    if coefs(4*(i-1)+2) < 0
        bounds(2,4*(i-1)+6) = 0;
    else
        bounds(1,4*(i-1)+6) = 0;
    end
end

%--------------------------------------------------------------------------
% Set parameters for optimization
nInds = 3000; 
nParents = floor(nInds*0.75);

%--------------------------------------------------------------------------
% Generate population
population = generatePop(bounds, nInds);

% Initialize loop variables
numGens = 3000;

% Give user progress
h = waitbar(0,'Running through generations');

%--------------------------------------------------------------------------
% Run through the generations
for gen = 1:numGens
    % Check to make sure variables are in bounds
    for i = 1:nInds
        for j = 1:numVars
            if population(i,j) > bounds(2,j)
                population(i,j) = bounds(2,j);
            elseif population(i,j) < bounds(1,j)
                population(i,j) = bounds(1,j);
            end
        end
    end
    
    % Rank the population based on chi squared for 
    if numChunks == 4
        % 4 chunks
        [population, newTime] = testrankFitBackground4(population, ...
                        fitChunks, unshiftedChunks, ...
                        allCutIndex, wasCut);
        time = time + newTime;
    else
        % Arbitrary number of chunks
        population = rankFitBackgroundGen(population, ...
                        smoothFitChunks, smoothUnshiftedChunks, ...
                        allCutIndex, wasCut);
    end
        
    % Select parents and breed
    topDogs = population(1:nParents, :);
    topDogKids = reclin(topDogs);
    solution = topDogs(1,:);
    
    % Mutate population
    mutTopDogs = mutreal(topDogs, bounds, 0.75);
 
    % Put kids in new population
    population(1:nParents, :) = mutTopDogs;
    population((nInds-nParents+1):nInds, :) = topDogKids;
    waitbar(gen/numGens)
end

% Close the progress bar
close(h)
display('Final solution found.')
time
%--------------------------------------------------------------------------
% Seperate chunks from cell arrays into different
% variables

% Set loop variables
countFit = 0;
countLinear = 0;
i = 1;

% Get separated chunks into different variables
while i <= numChunks
    % Nonlinear
    countFit = countFit + 1;
    eval(sprintf('fitChunk%d = fitChunks{:,i};', countFit));
    eval(sprintf('startHeight(countFit) = fitChunk%d(1,2);', countFit));
    eval(sprintf('unshiftedChunk%d = unshiftedChunks{:,i};', countFit));
    i = i + 1;
    
    % Linear
    if wasCut(countFit)
        countLinear = countLinear + 1;
        eval(sprintf('linearChunk%d = fitChunks{:,i};', countLinear));
        eval(sprintf('unshiftedLinearChunk%d = unshiftedChunks{:,i};', countLinear));
        i = i + 1;
    end
end

%--------------------------------------------------------------------------
% Get fit functions to return

% Define nonlinear fit type
for i = 1:countFit
    ft{1,i} = fittype('(a1-a2*exp(-(t/tau)^beta)) + (a1B-a2B*exp(-(t/tauB)^betaB))', 'independent', 't', 'dependent', 'y' ); %#ok<AGROW>
end

% Define linear fit type
for i = 1:countLinear
    ftLin{1,i} = fittype( 'm*t + b + a1B - a2B*exp(-(t/tauB)^betaB)', 'independent', 't', 'dependent', 'y' );  %#ok<AGROW>
end

%--------------------------------------------------------------------------
% Define background coefficients
a1B = solution(1);
a2B = solution(2);
betaB = solution(3);
tauB = solution(4);

% If you want to look at what the background function 
% looks like
if testing
    testY = a1B-a2B*exp(-(x/tauB).^betaB);
    cla reset
    figure(1)
    hold
    plot(x,y)
    hold
    plot(x,testY)
    wait = input('Waiting.'); %#ok<NASGU>
end

%--------------------------------------------------------------------------
% Get coefficients for nonlinear chunks

% Preallocate for speed
a1 = zeros(1,countFit);
a2 = zeros(1,countFit);
beta = zeros(1,countFit);
tau = zeros(1,countFit);

% Set loop variable
count = 0;

% Populate nonlinear coefficients
for i = 5:4:4*(countFit+1)
    count = count + 1;
    a1(count) = solution(i);
    a2(count) = solution(i+1);
    beta(count) = solution(i+2);
    tau(count) = solution(i+3);
end

%--------------------------------------------------------------------------
% Get coefficients for linear chunks

% Preallocate for speed
m = zeros(1,countLinear);
b = zeros(1,countLinear);

% Set loop variables
count = 0;
start = 4*(countFit+1) + 1;
finish = 4*(countFit+1) + 2*countLinear;

% Populate linear coefficients
for i = start:2:finish
    count = count + 1;
    m(count) = solution(i);
    b(count) = solution(i+1);
end

%--------------------------------------------------------------------------
% Preallocate for speed
chiSquared = zeros(countFit,1);
chiSquaredLinear = zeros(countLinear,1);

% Generate functions to return and get the chi squared values
% for nonlinear chunks
for i = 1:countFit
    fitresult{1,i} = cfit(ft{1,i}, a1(i), a1B, a2(i), a2B, beta(i), betaB, tau(i), tauB); %#ok<AGROW>
    eval(sprintf('chiSquared(i) = getChiSquared(fitChunk%d(:,1), fitChunk%d(:,2), fitresult{1,i});', i, i));
end

% Generate functions to return and get the chi squared values
% for linear chunks
for i = 1:countLinear
    fitresultLinear{1,i} = cfit(ftLin{1,i}, a1B, a2B, b(i), betaB, m(i), tauB); %#ok<AGROW>
    eval(sprintf('chiSquaredLinear(i) = getChiSquared(linearChunk%d(:,1), linearChunk%d(:,2), fitresultLinear{1,i});', i, i));
end

% If you did not cut any chunks, set fitresultLinear to 0 so
% that something is returned
if countLinear == 0
    fitresultLinear = 0;
end
end
