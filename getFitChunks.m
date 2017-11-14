function [ fitChunks, fitChunksSmooth, allCutIndex, allCutIndexSmooth, wasCut, unshiftedChunks, unshiftedChunksSmooth ] = getFitChunks( x, y, smoothX, smoothY, turningIndices, turningIndicesSmooth, linearCutMethod ) %#ok<STOUT>
%==========================================================================
% This function takes the turning points and separates the 
% chunks of data into different variables. It will also call
% getCutPoints to cut linear portions of the graph if that 
% option is selected.
%
% Functions called:
%           getCutPoints - cut linear portions if applicable
%
% Called by functions:
%           getFit - sends user information and turning 
%                    points, separates the chunks, and fits
%                    the data
%
% Input data:
%           x and y - data points
%           turningIndices - array holding indices of turning
%                            points
%           linearCutMethod - how to cut linear parts
%                             1 = none
%                             2 = manual
%                             2 = GA
%
% Output data:
%           fitChunks - cell array of fit chunks
%           allCutIndex - all indices of cut points including
%                         any linear cut points
%           wasCut - boolean vector for if a section has been
%                    linearly cut
%           unshiftedChunks - cell array of unshifted chunks
%
% Created by: Laura Nichols
% Creation date: 19 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Set to 1 if you would like to plot the chunks 
% over the original data
testing = 0;

%--------------------------------------------------------------------------

% Set number of chunks
numStrExpChunks = length(turningIndices) - 1;

% Default total number of chunks is just the number of
% stretched exponential chunks
numChunks = numStrExpChunks;

% wasCut defaults to zero or no
wasCut = zeros(numStrExpChunks,1);

%--------------------------------------------------------------------------

% Manually get points to cut linear portions if option is
% selected
if linearCutMethod ~= 1
    [cutIndex, cutIndexSmooth] = getCutPoints(x, y, smoothX, numStrExpChunks, linearCutMethod, turningIndices); 
    
    % Get information from returned indices
    countCut = length(cutIndex);
    numChunks = numStrExpChunks + countCut;
    
    % Determine if each chunk was cut
    count = 1;
    for i=2:numStrExpChunks+1
        if (cutIndex(count) > turningIndices(i-1)) && (cutIndex(count) < turningIndices(i))
            count = count + 1;
            wasCut(i-1) = 1;
        end
    end
    
%--------------------------------------------------------------------------    
    % Get all turning indices in one array
    
    % Set loop variables
    temp = turningIndices;
    tempSmooth = turningIndicesSmooth;
    count1 = 0;
    count2 = 0;
    
    % Put indices in array in order
    for i=1:numStrExpChunks
        count1 = count1 + 1;
        turningIndices(count1) = temp(i);
        turningIndicesSmooth(count1) = tempSmooth(i);
        if wasCut(i)
            count1 = count1 + 1;
            count2 = count2 + 1;
            turningIndices(count1) = cutIndex(count2);
            turningIndicesSmooth(count1) = cutIndexSmooth(count2);
        end
    end
    
    turningIndices(numChunks+1) = temp(end);
    turningIndicesSmooth(numChunks+1) = tempSmooth(end);
end

allCutIndex = turningIndices;
allCutIndexSmooth = turningIndicesSmooth;

%--------------------------------------------------------------------------
% Slightly shift values so that there is no overlap for 
% fitting
shift = floor(0.0025*length(x));
shiftSmooth = floor(0.0025*length(smoothX));
front = zeros(numChunks,1);
back = zeros(numChunks,1);
frontSmooth = front;
backSmooth = back;
for i = 1:(length(turningIndices) - 1)
    front(i) = turningIndices(i) + shift;
    back(i) = turningIndices(i+1) - shift;
    frontSmooth(i) = turningIndicesSmooth(i) + shiftSmooth;
    backSmooth(i) = turningIndicesSmooth(i+1) - shiftSmooth;
end

% Put all data in single array
data = [x y]; %#ok<NASGU>
dataSmooth = [smoothX' smoothY']; 

%--------------------------------------------------------------------------
% Separate chunks
for i=1:numChunks
    eval(sprintf('chunk%d = data(front(%d):back(%d),:);', i, i, i));
    eval(sprintf('chunkSmooth%d = dataSmooth(frontSmooth(%d):backSmooth(%d),:);', i, i, i));
end

%--------------------------------------------------------------------------
% Plot if you are testing
if testing
    figure(1) %#ok<UNRCH>
    cla reset
    plot(x, y, 'k')
    hold
    for i=1:numChunks
        eval(sprintf('plot(chunk%d(:,1), chunk%d(:,2));', i, i));
    end
    wait = input('Waiting for the go ahead.');
end

%--------------------------------------------------------------------------
% Shift x-values to start at 0 for fitting
startX = zeros(length(numChunks),1); %#ok<NASGU>
startXSmooth = zeros(length(numChunks),1); %#ok<NASGU>
for i=1:numChunks
    eval(sprintf('startX(%d) = chunk%d(1,1);', i, i));
    eval(sprintf('shiftedX%d = chunk%d(:,1) - startX(%d);', i, i, i));
    eval(sprintf('startXSmooth(%d) = chunkSmooth%d(1,1);', i, i));
    eval(sprintf('shiftedXSmooth%d = chunkSmooth%d(:,1) - startXSmooth(%d);', i, i, i));
end

% Put shifted x-values with their y-values
for i=1:numChunks
    eval(sprintf('shiftedChunk%d = [shiftedX%d chunk%d(:,2)];', i, i, i));
    eval(sprintf('shiftedChunkSmooth%d = [shiftedXSmooth%d chunkSmooth%d(:,2)];', i, i, i));
end

%--------------------------------------------------------------------------
% Put all shifted chunks in one cell array to return
fitChunkStr = [];
unshiftedChunkStr = [];
fitChunkStrSmooth = [];
unshiftedChunkStrSmooth = [];
for i = 1:numChunks
    eval(sprintf('fitChunkStr = [fitChunkStr '' shiftedChunk%d''];', i));
    eval(sprintf('unshiftedChunkStr = [unshiftedChunkStr '' chunk%d''];', i));
    eval(sprintf('fitChunkStrSmooth = [fitChunkStrSmooth '' shiftedChunkSmooth%d''];', i));
    eval(sprintf('unshiftedChunkStrSmooth = [unshiftedChunkStrSmooth '' chunkSmooth%d''];', i));
end

eval(sprintf('fitChunks = {%s};', fitChunkStr));
eval(sprintf('unshiftedChunks = {%s};', unshiftedChunkStr));
eval(sprintf('fitChunksSmooth = {%s};', fitChunkStrSmooth));
eval(sprintf('unshiftedChunksSmooth = {%s};', unshiftedChunkStrSmooth));
end

