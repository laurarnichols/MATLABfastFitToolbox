function [ cutIndex, cutIndexSmooth ] = getCutPoints(x, y, smoothX, numChunks, linearCutMethod, turningIndex)
%==========================================================================
% This function takes the turning points and separates the 
% chunks of data into different variables. It will also call
% getCutPoints to cut linear portions of the graph if that 
% option is selected.
%
% Functions called:
%           getAndTestInput - gets user input and tests for 
%                             errors
%           manualMode - manually move or select points for
%                        cutting
%           cutGA - use GA to find best spot to cut linear
%
% Called by functions:
%           getFitChunks - separates the chunks
%
% Input data:
%           x and y - data points
%           numChunks - number of total chunks, linear and nonlinear
%           linearCutMethod - how to cut linear parts
%                             1 = none
%                             2 = manual
%                             2 = GA
%           turningIndex - array holding indices of turning
%                            points
%
% Output data:
%           cutIndex - linear cut points
%
% Created by: Laura Nichols
% Creation date: 19 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Initialize to empty array so if you don't want to cut,
% something is still returned
cutIndex = [];

%--------------------------------------------------------------------------
% If you want to cut manually
if linearCutMethod == 2
    % Pop up a figure
    figure(1)
    cla reset
    plot(x, y)

    % Ask user how many points they want to cut at
    clc
    request = '\nHow many points do you want to cut at?\n';
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    eval(sprintf('check2 = ''temp < 0 || temp > %d'';', numChunks));
    message2 = 'Value entered was less than 0 or greater than numChunks.';
    countCut = getAndTestInput(request, check1, message1, check2, message2);

    % Send to manualMode to select points
    [cutIndex, ~] = manualMode(x, y, countCut, 1);
    
%--------------------------------------------------------------------------
% If you want to cut with a GA
elseif linearCutMethod == 3    
    % Send each chunk to GA individually
    for i = 1:numChunks
        % Separate chunks
        cutX = x(turningIndex(i):turningIndex(i+1));
        cutY = y(turningIndex(i):turningIndex(i+1));
        
        % Send to GA
        cutIndex = [cutIndex (cutGA(cutX, cutY)+turningIndex(i))]; %#ok<AGROW>
    end
end

%--------------------------------------------------------------------------
% Convert back to unsmoothed data

indexXSmooth = zeros(length(cutIndex), length(smoothX));

% Find indices that have an x-value close to what you want
for i = 1:length(cutIndex)
    indexXSmooth(i,:) = abs(smoothX - turningPointSmooth(i,1)) < 1;
end

% Only choose one point for each index
for i = 1:length(cutIndex)
    foundSmooth = 0;
    for j = 1:length(indexXSmooth(i,:))
        if indexXSmooth(i,j) && ~(foundSmooth)
            cutIndexSmooth(i) = j; %#ok<AGROW>
            foundSmooth = 1;
        end
    end
end
end

