function [ sorted, time ] = rankFitBackground4( population, fitChunks, unshiftedChunks, allCutIndex, wasCut, lengthX ) 
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

if countFit ~= 4
    error(['You are in the specific ranking function for 4 chunks, but you have ' int2str(countFit) ' chunks.\n');
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
% Populate coefficients
a1_1 = population(:,5);
a2_1 = population(:,6);
beta_1 = population(:,7);
tau_1 = population(:,8);
a1_2 = population(:,9);
a2_2 = population(:,10);
beta_2 = population(:,11);
tau_2 = population(:,12);
a1_3 = population(:,13);
a2_3 = population(:,14);
beta_3 = population(:,15);
tau_3 = population(:,16);
a1_4 = population(:,17);
a2_4 = population(:,18);
beta_4 = population(:,19);
tau_4 = population(:,20);

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
        yFit1 = (a1_1(i) - a2_1(i)*exp(-(x1Shifted/tau_1(i)).^beta_1(i)))...
              + (a1B(i) - a2B(i)*exp(-(x1/tauB(i)).^betaB(i)));

        yFit2 = (a1_2(i) - a2_2(i)*exp(-(x2Shifted/tau_2(i)).^beta_2(i)))...
              + (a1B(i) - a2B(i)*exp(-(x2/tauB(i)).^betaB(i)));

        yFit3 = (a1_3(i) - a2_3(i)*exp(-(x3Shifted/tau_3(i)).^beta_3(i)))...
              + (a1B(i) - a2B(i)*exp(-(x3/tauB(i)).^betaB(i)));

        yFit4 = (a1_4(i) - a2_4(i)*exp(-(x4Shifted/tau_4(i)).^beta_4(i)))...
              + (a1B(i) - a2B(i)*exp(-(x4/tauB(i)).^betaB(i))); 

%--------------------------------------------------------------------------
        % Get fit y values for each linear chunk
        yFit5 = m(i,1)*x5Shifted + b(i,1) ...
              + (a1B(i) - a2B(i)*exp(-(x5/tauB(i)).^betaB(i)));

        yFit6 = m(i,2)*x6Shifted + b(i,2) ...
              + (a1B(i) - a2B(i)*exp(-(x6/tauB(i)).^betaB(i)));

        yFit7 = m(i,3)*x7Shifted + b(i,3) ...
              + (a1B(i) - a2B(i)*exp(-(x7/tauB(i)).^betaB(i)));

        yFit8 = m(i,3)*x8Shifted + b(i,3) ...
              + (a1B(i) - a2B(i)*exp(-(x8/tauB(i)).^betaB(i))); 

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
    start = tic;
    % Fit nonlinear portion
    parfor i = 1:nInds
        % Get fit y values for each nonlinear chunk
        yFit1 = (a1_1(i) - a2_1(i)*exp(-(x1Shifted/tau_1(i)).^beta_1(i)))...
              + (a1B(i) - a2B(i)*exp(-(x1/tauB(i)).^betaB(i)));

        yFit2 = (a1_2(i) - a2_2(i)*exp(-(x2Shifted/tau_2(i)).^beta_2(i)))...
              + (a1B(i) - a2B(i)*exp(-(x2/tauB(i)).^betaB(i)));

        yFit3 = (a1_3(i) - a2_3(i)*exp(-(x3Shifted/tau_3(i)).^beta_3(i)))...
              + (a1B(i) - a2B(i)*exp(-(x3/tauB(i)).^betaB(i)));

        yFit4 = (a1_4(i) - a2_4(i)*exp(-(x4Shifted/tau_4(i)).^beta_4(i)))...
              + (a1B(i) - a2B(i)*exp(-(x4/tauB(i)).^betaB(i))); 

%--------------------------------------------------------------------------
        % Get chi squared values for each chunk
        chiSquared(i) = chiSquared(i) + sum((yFit1 - y1).^2) ...
                      + sum((yFit2 - y2).^2) ...
                      + sum((yFit3 - y3).^2) ...
                      + sum((yFit4 - y4).^2);
    end
    time = toc(start);

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
