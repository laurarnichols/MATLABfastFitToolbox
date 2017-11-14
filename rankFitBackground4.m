function [ sorted ] = rankFitBackground4( population, fitChunks, unshiftedChunks, allCutIndex, wasCut, lengthX ) 
%==========================================================================
% This function will rank the different variable combinations
% in the population based on the chi squared. It will
% then sort the population and return the sorted array.
%
% Functions called:
%           N/A
%
% Called by functions:
%           GAFitBackground - fits all of the chunks together
%                             along with a background
%                             stretched exponential function
%
% Input data:
%           population - contains all of the points within
%                        the bounds to be ranked and sorted
%           fitChunks - cell array of separated chunks that
%                       have been shifted to be fit
%           allCutIndex - vector containing indices of all 
%                         cut points including linear cuts
%           wasCut - vector containing boolean for if a 
%                    given nonlinear chunk has been cut
%           unshiftedChunks - cell array of separated chunks 
%                             that have not been shifted 
%
% Output data:
%           sorted - sorted population array based on chi
%                    squared
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

% Get background ceofficients
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

% Set up loop variable
count = 0;

% Populate coefficients
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
% Fit each combo in your population and get
% the chi squared

% Preallocate and predefine for speed
chiSquared = zeros(nInds,1);

x1Shifted = fitChunk1(:,1);
x2Shifted = fitChunk2(:,1);
x3Shifted = fitChunk3(:,1);
x4Shifted = fitChunk4(:,1);

x1 = unshiftedChunk1(:,1);
y1 = unshiftedChunk1(:,2);
x2 = unshiftedChunk2(:,1);
y2 = unshiftedChunk2(:,2);
x3 = unshiftedChunk3(:,1); %#ok<*NODEF>
y3 = unshiftedChunk3(:,2);
x4 = unshiftedChunk4(:,1);
y4 = unshiftedChunk4(:,2);

if countLinear == 4
    % Predefine linear portions for speed
    x5Shifted = linearChunk1(:,1);
    x6Shifted = linearChunk2(:,1);
    x7Shifted = linearChunk3(:,1);
    x8Shifted = linearChunk4(:,1);
    
    x5 = unshiftedLinearChunk1(:,1);
    y5 = unshiftedLinearChunk1(:,2);
    x6 = unshiftedLinearChunk2(:,1);
    y6 = unshiftedLinearChunk2(:,2);
    x7 = unshiftedLinearChunk3(:,1);
    y7 = unshiftedLinearChunk3(:,2);
    x8 = unshiftedLinearChunk4(:,1);
    y8 = unshiftedLinearChunk4(:,2);
    
    
%--------------------------------------------------------------------------
    % Fit nonlinear portion
    parfor i = 1:nInds
        % Get fit y values for each nonlinear chunk
        yFit1 = (a1(i,1) - a2(i,1)*exp(-(x1Shifted/tau(i,1)).^beta(i,1)))...
              + (a1B(i) - a2B(i)*exp(-(x1/tauB(i)).^betaB(i)));

        yFit2 = (a1(i,2) - a2(i,2)*exp(-(x2Shifted/tau(i,2)).^beta(i,2)))...
              + (a1B(i) - a2B(i)*exp(-(x2/tauB(i)).^betaB(i)));

        yFit3 = (a1(i,3) - a2(i,3)*exp(-(x3Shifted/tau(i,3)).^beta(i,3)))...
              + (a1B(i) - a2B(i)*exp(-(x3/tauB(i)).^betaB(i)));

        yFit4 = (a1(i,4) - a2(i,4)*exp(-(x4Shifted/tau(i,4)).^beta(i,4)))...
              + (a1B(i) - a2B(i)*exp(-(x4/tauB(i)).^betaB(i))); %#ok<PFBNS>

%--------------------------------------------------------------------------
        % Get fit y values for each linear chunk
        yFit5 = m(i,1)*x5Shifted + b(i,1) ...
              + (a1B(i) - a2B(i)*exp(-(x5/tauB(i)).^betaB(i)));

        yFit6 = m(i,2)*x6Shifted + b(i,2) ...
              + (a1B(i) - a2B(i)*exp(-(x6/tauB(i)).^betaB(i)));

        yFit7 = m(i,3)*x7Shifted + b(i,3) ...
              + (a1B(i) - a2B(i)*exp(-(x7/tauB(i)).^betaB(i)));

        yFit8 = m(i,3)*x8Shifted + b(i,3) ...
              + (a1B(i) - a2B(i)*exp(-(x8/tauB(i)).^betaB(i))); %#ok<PFBNS>

%--------------------------------------------------------------------------
        % Get chi squared values for each nonlinear chunk
        chiSquared(i) = chiSquared(i) + sum((yFit1 - y1).^2) ...
                      + sum((yFit2 - y2).^2) ...
                      + sum((yFit3 - y3).^2) ...
                      + sum((yFit4 - y4).^2) ...
                      + sum((yFit5 - y5).^2) ...
                      + sum((yFit6 - y6).^2) ...
                      + sum((yFit7 - y7).^2) ...
                      + sum((yFit8 - y8).^2);
    end
    
%--------------------------------------------------------------------------
else
    % Fit nonlinear portion
    for i = 1:nInds
        % Get fit y values for each nonlinear chunk
        yFit1 = (a1(i,1) - a2(i,1)*exp(-(x1Shifted/tau(i,1)).^beta(i,1)))...
              + (a1B(i) - a2B(i)*exp(-(x1/tauB(i)).^betaB(i)));

        yFit2 = (a1(i,2) - a2(i,2)*exp(-(x2Shifted/tau(i,2)).^beta(i,2)))...
              + (a1B(i) - a2B(i)*exp(-(x2/tauB(i)).^betaB(i)));

        yFit3 = (a1(i,3) - a2(i,3)*exp(-(x3Shifted/tau(i,3)).^beta(i,3)))...
              + (a1B(i) - a2B(i)*exp(-(x3/tauB(i)).^betaB(i)));

        yFit4 = (a1(i,4) - a2(i,4)*exp(-(x4Shifted/tau(i,4)).^beta(i,4)))...
              + (a1B(i) - a2B(i)*exp(-(x4/tauB(i)).^betaB(i))); %#ok<PFBNS>

%--------------------------------------------------------------------------
        % Get chi squared values for each chunk
        chiSquared(i) = chiSquared(i) + sum((yFit1 - y1).^2) ...
                      + sum((yFit2 - y2).^2) ...
                      + sum((yFit3 - y3).^2) ...
                      + sum((yFit4 - y4).^2);
    end

%--------------------------------------------------------------------------
    % Fit linear portion
    for j = 1:countLinear
        eval(sprintf(['yFit = (m(i,j)*linearChunk%d(:,1) + ' ...
                      'b(i,j)) + (a1B(i) - ' ...
                      'a2B(i)*exp(-(unshiftedLinearChunk%d(:,1)/' ...
                      'tauB(i)).^betaB(i)));'], j, j));
        eval(sprintf(['chiSquared(i) = chiSquared(i) + ' ...
                      'sum((yFit - linearChunk%d(:,2)).^2)/' ...
                      'length(linearChunk%d(:,1));'], j, j));
    end  
end        
    
%--------------------------------------------------------------------------
% Sort by chiSquared
[~, index] = sort(chiSquared);

% Preallocate for speed
sorted = zeros(size(population));

% Put in sorted array to return
for i = 1:length(population)
    sorted(i,:) = population(index(i),:);
end

end

