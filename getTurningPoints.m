function [ turningPoint, turningIndex, turningPointSmooth, turningIndexSmooth, smoothXTrim, smoothYTrim ] = getTurningPoints(x, y, chunkCutMethod)
%==========================================================================
% This function takes input data (x and y) and finds the
% turning points. This is best to use if you have noisy data.
% It asks for noise threshold, number of turning points, and
% the pulse height from the user. It also asks the user if
% the fit points look correct. 
% 
% Make sure to only select yes if points are right on the 
% edge. Otherwise, the chunks will overlap when you try to 
% fit and it will not work.
%
% Functions called:
%           smooth - MATLAB function to smooth data
%           getAndTestInput - gets user input and tests for 
%                             errors
%           manualMode - manually move or select points for
%                        cutting
%
% Called by functions:
%           fastFit - main interface for toolbox
%
% Input data:
%           x and y - data points
%           figNum - keeps track of what figure number to
%                    created when running on different data 
%                    back to back
%           chunkCutMethod - choice of how to separate cycles
%                           1 = manual
%                           2 = GAlinearCutMethod
%
% Output data:
%           turningPoint - x and y values for turning points
%           turningIndex - array holding indices of turning
%                          points
%
% Created by: Laura Nichols
% Creation date: 19 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Smooth data
smoothNum = floor(0.0018*length(x));
smoothX = smooth(x, smoothNum);
smoothY = smooth(y, smoothNum);
smoothData(:,1) = smoothX;
smoothData(:,2) = smoothY; %#ok<NASGU>

% Use fewer points
count = 0;

for i = 1:50:length(smoothX)
    count = count + 1;
    smoothXTrim(count) = smoothX(i);
    smoothYTrim(count) = smoothY(i);
end

%--------------------------------------------------------------------------
% Get user to tell you how many turning points there are
figure(1)
cla reset
plot(smoothX, smoothY)

clc
fprintf('\nThe figure displayed shows the smoothed data.\n\n');
fprintf('Please enter a single positive integer\ngiving the number of cycles,\n(separate chunks).\n\n');

request = 'Please enter a single positive integer.\n';
check1 = 'length(temp) > 1';
message1 = 'Value entered had a length greater than 1.';
check2 = 'floor(temp) < 1';
message2 = 'Value entered was less than or equal to 0.';
numTurningPoints = floor(getAndTestInput(request, check1, message1, check2, message2)) + 1;

%--------------------------------------------------------------------------
if chunkCutMethod == 1
    [turningPoint(:,1), turningPoint(:,2)] = manualMode(smoothX, smoothY, numTurningPoints, 1);
elseif chunkCutMethod == 3
    [turningPoint(:,1), turningPoint(:,2)] = manualMode(smoothX, smoothY, numTurningPoints, 2);
else
    %--------------------------------------------------------------------------
    % Get user to tell you the pulse height
    clc
    fprintf(['\nPlease enter a single positive decimal number' ...
                     '\nfor the pulse height.\n' ...
                     '\nUse the smaller pulses. Subtract the maximum' ...
                     '\nfrom the minium. This only needs to be a rough' ...
                     '\napproximation.\n']);

    request = 'Please enter a single positive decimal.\n';
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp < 0';
    message2 = 'Value entered was less than 0.';
    pulseHeight = getAndTestInput(request, check1, message1, check2, message2);
        
    %--------------------------------------------------------------------------
    % Calculate magnitude of change in y and sign
    diffMag = abs(diff(smoothY));
    diffMag(length(smoothX)) = 0; % Use to make indices same for plot
    diffSign = sign(diff(smoothY)); 

    %--------------------------------------------------------------------------
    % Plot magnitudes of change in y for middle 90%
    % to exclude weird behavior on the ends
    front = floor(0.1*length(smoothX));
    back = floor(0.9*length(smoothX));
    figure(1)
    cla reset
    plot(smoothX(front:back), diffMag(front:back))

    % Get user to tell you a good threshold to use
    clc
    fprintf('\nThe figure displayed shows the magnitudes\n of the changes in y.\n\n');
    fprintf('Please look at the graph and pick a value\n on the y-axis for the threshold.\n\n');
    fprintf('Guess lower if you are unsure.\n\n');

    request = 'Please enter a single positive decimal number.\n';
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp < 0';
    message2 = 'Value entered was less than 0.';
    thresh = getAndTestInput(request, check1, message1, check2, message2);

    %--------------------------------------------------------------------------
    % Pick out points that are above the threshold and have
    % a derivative that is different in sign from the last 
    % successful point.
    %  ** Assumes plot goes down first.
    threshInit = thresh;
    working = 0;
    step = 0.05;
    % Repeat until the points look good
    while ~(working)
        num = 1;
        clear markers
        clear markerIndex
        clear signMarker
        signMarker(1) = 1;
        % Find markers above threshold that have a different sign
        % of their derivative from the previous marker
        for i = 1:(length(smoothY))
            if (diffMag(i) > thresh) && (signMarker(num)*diffSign(i) == -1)
                    num = num + 1;
                    turningPointSmooth(num-1,1) = smoothX(i); %#ok<AGROW>
                    turningPointSmooth(num-1,2) = smoothY(i); %#ok<AGROW>
                    markerIndex(num-1) = i; %#ok<AGROW>
                    signMarker(num) = diffSign(i); %#ok<AGROW>
            end
        end

    %--------------------------------------------------------------------------
        % Only want one point for each turn
        num = 0;
        diffMark = abs(diff(turningPointSmooth(:,2)));
        clear turningPoint
        clear turningIndex
        turningPoint = 0;
        turningIndex = 0;
        % Only pick points at least a half a pulse height away
        for i = 1:length(diffMark)
            if diffMark(i) > pulseHeight/2
                num = num + 1;
                turningPoint(num,1) = turningPointSmooth(i,1); %#ok<AGROW>
                turningPoint(num,2) = turningPointSmooth(i,2); %#ok<AGROW>
                turningIndex(num) = markerIndex(i); %#ok<AGROW>
            end
        end

    %--------------------------------------------------------------------------    
        % If the threshold was so bad that no turning points were
        % found then edit it and try again
        if ~exist('turningPoint') %#ok<EXIST>
            threshInit = threshInit - threshInit/4;
            thresh = threshInit;
            continue
        end

    %--------------------------------------------------------------------------    
        % Catch the end
        if abs(turningPoint(num,2) - turningPointSmooth(length(turningPointSmooth),2)) > pulseHeight/2
            turningPoint(num+1,1) = turningPointSmooth(length(turningPointSmooth),1); %#ok<AGROW>
            turningPoint(num+1,2) = turningPointSmooth(length(turningPointSmooth),2); %#ok<AGROW>
            turningIndex(num+1) = markerIndex(length(markerIndex)); %#ok<AGROW>
        end

    %--------------------------------------------------------------------------    
        % If the number  of turning points found is right then
        % make sure they look good
        if(length(turningPoint) == numTurningPoints)
            % Plot turning points on smooth data
            figure(1)
            cla reset
            plot(smoothX, smoothY)
            hold
            plot(turningPoint(:,1), turningPoint(:,2), 'ko')

            % Ask the user if they look right
            clc
            request = ['\nDo these turning points look correct?' ...
                        '\n\t 1) yes' ...
                        '\n\t 2) no\n'];
            check1 = 'length(temp) > 1';
            message1 = 'Value entered had a length greater than 1.';
            check2 = 'temp ~= 1 && temp ~= 2';
            message2 = 'Value entered was not an option.';
            working = floor(getAndTestInput(request, check1, message1, check2, message2));

            if working == 2
                working = 0;
            end

            % If they don't look right, ask the user what they
            % want to do
            if ~(working) 
                clc
                request = ['\nWhat would you like to do?' ...
                            '\n\t 1) Continue' ...
                            '\n\t 2) Reset' ...
                            '\n\t 3) Enter manual mode\n'];
                check1 = 'length(temp) > 1';
                message1 = 'Value entered had a length greater than 1.';
                check2 = 'temp ~= 1 && temp ~= 2 && temp ~= 3';
                message2 = 'Value entered was not an option.';
                choice = getAndTestInput(request, check1, message1, check2, message2);

    %--------------------------------------------------------------------------
                % If the user wants to continue, edit the threshold
                % and try again
                if choice == 1
                    thresh = thresh + step*thresh;
                % If the user wants to reset the threshold,
                % reset to initial value and take smaller steps
                elseif choice == 2
                    thresh = threshInit;
                    step = step/2;
                % If the user wants to manually edit points, call
                % manualMode()
                elseif choice == 3
                    [turningIndex, turningPoint, working] = manualMode(numTurningPoints, ...
                        turningIndex, turningPoint, smoothX, smoothY);
                end
            end

    %--------------------------------------------------------------------------
        % If the number of turning points is wrong, edit threshold
        % and try again
        else
            thresh = thresh + step*threshInit;
        end
    end
end
%--------------------------------------------------------------------------
% Convert back to unsmoothed data
turningPointSmooth = turningPoint;
clear turningPoint

indexX = zeros(length(turningPointSmooth), length(x));
indexXSmooth = zeros(length(turningPointSmooth), length(smoothXTrim));

% Find indices that have an x-value close to what you want
for i = 1:length(turningPointSmooth)
    indexX(i,:) = abs(x - turningPointSmooth(i,1)) < 1;
    indexXSmooth(i,:) = abs(smoothXTrim - turningPointSmooth(i,1)) < x(end)/length(x)*75;
end
% Only choose one point for each index
for i = 1:length(turningPointSmooth)
    found = 0;
    for j = 1:length(indexX(i,:))
        if indexX(i,j) && ~(found)
            turningIndex(i) = j; %#ok<AGROW>
            found = 1;
        end
    end
    foundSmooth = 0;
    for j = 1:length(indexXSmooth(i,:))
        if indexXSmooth(i,j) && ~(foundSmooth)
            turningIndexSmooth(i) = j; %#ok<AGROW>
            foundSmooth = 1;
        end
    end
end

turningPoint(:,1) = x(turningIndex);
turningPoint(:,2) = y(turningIndex);
end

