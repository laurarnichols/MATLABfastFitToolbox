function [ coefs, chiSquared, allCutIndex, unshiftedChunks, fitted ] = getFit( x, y, smoothX, smoothY, turningIndices, turningIndicesSmooth, loopNum, fitMethod, linearCutMethod ) %#ok<INUSL>
%==========================================================================
% This function takes the input data and fitting options, 
% splits the chunks, then calls the desired fitting function.
% Finally, all of the fitted chunks are put back together and 
% returned.
%
% Functions called:
%           getFitChunks - separates the chunks
%           basicFit - fits using basic MATLAB method
%           GAFitSingle - fits each chunk separately using
%                         a single stretched exponential
%                         function
%           fit - MATLAB function to fit using given option
%                 (only used for polynomial fit)
%           GAFitBackground - fits all of the chunks together
%                             along with a background
%                             stretched exponential function
%
% Called by functions:
%           fastFit - main interface for toolbox
%
% Input data:
%           x and y - data points
%           figNum - keeps track of what figure number to
%                    created when running on different data 
%                    back to back
%           fitMethod - choice of what fitting to use:
%                           1 = basic
%                           2 = single GA
%                           3 = background GA
%           chunkCutMethod - choice of how to separate cycles
%                           1 = manual
%                           2 = GAlinearCutMethod
%           loopNum - how many times to try to fit if using
%                     basic fitting method
%
% Output data:
%           coefs - vector holding fit coefficients
%           chiSquared - vector holding chi squared for each
%                        chunk
%           allCutIndex - array holding idices of all points
%                         cut along graph including turning
%                         points and linear cut points
%           unshiftedChunks - cell array holding each of the 
%                             original chunks
%           fitted - array holding all of the fitted lines
%
% Created by: Laura Nichols
% Creation date: 8 March 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Split up all of the chunks
[fitChunks, fitChunksSmooth, allCutIndex, allCutIndexSmooth, wasCut, unshiftedChunks, unshiftedChunksSmooth] = getFitChunks(x, y, smoothX, smoothY, turningIndices, turningIndicesSmooth, linearCutMethod);  %#ok<ASGLU>

clc
fprintf('All chunks are separated.')

%--------------------------------------------------------------------------
% Get the number of exponential chunks and number of total
% chunks including linear portions.
numStrExpChunks = length(turningIndices) - 1;
numChunks = length(allCutIndex) - 1;

%--------------------------------------------------------------------------
% Separate fit chunks into individual variables from the
% cell array returned by getFitChunks

% Set up loop variables
countFit = 0;
countLinear = 0;
i = 1;

% Separate chunks
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
% If using basic fit or single GA, chunks need to be fit
% If using background GA, get a base fit for nonlinear
% chunks
% individually
if fitMethod == 1 || fitMethod == 2 || fitMethod ==3
    % Fit stretched exponential chunks one at a time using 
    % chosen method
    for i = 1:countFit
        % Basic MATLAB fit
        if fitMethod == 1 || fitMethod == 3
            eval(sprintf('[coefs%d, chiSquared%d, fitresult%d] = basicFit(fitChunk%d(:,1), fitChunk%d(:,2), loopNum );', i, i, i, i, i));
        % GA fit single function
        elseif fitMethod == 2 
            % Set bounds for each chunk
            eval(sprintf('bounds%d = [fitChunk%d(1,2)/2 0 0; 1000 1 fitChunk%d(end,1)/2];', i, i, i));
            eval(sprintf('[coefs%d, chiSquared%d, fitresult%d] = GAFitSingle(fitChunk%d(:,1), fitChunk%d(:,2), bounds%d);', i, i, i, i, i, i));
        end
        
        % Begin coefficient and chi squared arrays if they 
        % are still empty
        if i == 1
            coefs = coefs1;
            chiSquared = chiSquared1;
        % Add to coefficient and chi squared arrays 
        else
            eval(sprintf('coefs = [coefs coefs%d];', i));
            eval(sprintf('chiSquared = [chiSquared chiSquared%d];', i));
        end
        
        % Tell user your progress
        if fitMethod ~= 3
            eval(sprintf('display(''%d/%d nonlinear chunks fit.'')', i, countFit));
        end
        
        % Evaluate fit functions at the x-values for the
        % given chunk to get an array of fitted x and y values
        eval(sprintf('fitted%d = [unshiftedChunk%d(:,1) fitresult%d(fitChunk%d(:,1))];', i, i, i, i));
    end
    
%--------------------------------------------------------------------------    
    % Fit linear chunks, if any
    if fitMethod ~= 3
        linearCoefs = [];
        for i = 1:countLinear
            % Use basic MATLAB polynomial fit
            eval(sprintf('[fitResultLinear, ~] = fit(linearChunk%d(:,1), linearChunk%d(:,2), ''poly1'');', i, i));

            % Get m and b from fit results
            m = fitResultLinear.p1;
            b = fitResultLinear.p2;
            linearCoefs = [linearCoefs m b]; %#ok<AGROW>

            % Put chi squared and fitted functions in arrays
            % to return
            eval(sprintf('chiSquaredLinear%d = getChiSquared(linearChunk%d(:,1), linearChunk%d(:,1), fitResultLinear);', i, i, i));
            eval(sprintf('fittedLinear%d = [unshiftedLinearChunk%d(:,1) fitResultLinear(linearChunk%d(:,1))];', i, i, i));
        end

        % Update user on progress
        fprintf('All linear portions are fit.')
    end
end

%--------------------------------------------------------------------------
% If using GAFitBackground, all chunks must be fit together
if fitMethod == 3 
    % Did the experimentalists wait for the first cycle to 
    % get linear before starting the next cycle
    letGetLinear = 1;
    
    % If they let it get linear first, the relaxation time
    % will be a smaller fraction of the total test time
    if letGetLinear == 1
        boundsBackground = [0 -max(y)/4 0 0; 50 0 1 x(end)/8]; 
    % If they didn't, it will be a larger fraction
    else
        boundsBackground = [0 -max(y)/4 0 0; 50 0 1 x(end)/4]; 
    end
    
    boundsNonLin = boundsBackground;
%--------------------------------------------------------------------------
    % Create boundaries for linear curves, if any
    boundsLinear = [];
    if countLinear > 1
        boundsM = [-1; 1];
        boundsB = [0; 50];
        boundsLinear = [boundsM boundsB];
    end
    
    for i = 2:countLinear
        boundsLinear = [boundsLinear boundsM boundsB]; %#ok<AGROW>
    end
    
%--------------------------------------------------------------------------
    % Tell user you are about to start fitting process
    fprintf('\nStarting the fitting process. \n');
    
%--------------------------------------------------------------------------
    % Put bounds together and send to GAFitBackground
    bounds = [boundsNonLin boundsLinear];
    tic;
    [chiSquared, fitresult, chiSquaredLinear, fitresultLinear] = testGAFitBackground(smoothX, smoothY, coefs, bounds, fitChunksSmooth, allCutIndexSmooth, wasCut, unshiftedChunksSmooth);
    toc
%-------------------------------------------------------------------------- 
    % Put all of the fit results in arrays
    
    % Nonlinear
    for i = 1:countFit
        fitresult1 = fitresult{1,i}; %#ok<NASGU>
        eval(sprintf('fitted%d = [unshiftedChunk%d(:,1) fitresult1(fitChunk%d(:,1))];', i, i, i));
    end
    
    % Linear
    for i = 1:countLinear
        fitresultLinear1 = fitresultLinear{1,i}; %#ok<NASGU>
        eval(sprintf('fittedLinear%d = [unshiftedLinearChunk%d(:,1) fitresultLinear1(linearChunk%d(:,1))];', i, i, i));
    end
end

%--------------------------------------------------------------------------
% Put all together before returning

% Initialize loop variables
fitted = {};
allFit = [];
numLin = 0;
count = 0;

% Put nonlinear and linear fits together
for i = 1:numStrExpChunks
    count = count + 1;
    eval(sprintf('allFit = [allFit; fitted%d];', i));
    eval(sprintf('fitted{1,count} = fitted%d;', i));
    if wasCut(i)
        count = count + 1;
        numLin = numLin + 1;
        eval(sprintf('allFit = [allFit; fittedLinear%d];', numLin));
        eval(sprintf('fitted{1,count} = fittedLinear%d;', numLin));
    end       
end

%--------------------------------------------------------------------------
% Put coefficients back in expected form for other functions

% % Clear coefs but save info
% temp = coefs;
% clear coefs
% 
% % Calculate number of rows in new matrix
% rowsNeeded = (length(temp) - 2*countLinear)/4;
% 
% % Preallocate for speed
% coefs = zeros(rowsNeeded,4);
% 
% % Put in rows
% for i = 1:rowsNeeded
%     coefs(i,:) = temp((4*(i-1)+1):(4*(i-1)+5));
% end

%--------------------------------------------------------------------------
% Plot and quit for debugging
testPlot(2, x, y, allFit)

if fitMethod == 3
    error('Quitting for debugging.');
end 
end



