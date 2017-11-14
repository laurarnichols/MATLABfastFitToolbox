function [turningIndex, turningPoint] = manualMode(x, y, numTurningPoints, selectOnly, turningIndex, turningPoint)
%==========================================================================
% This function allows the user to manually shift the turning
% points. It will ask which one they want to shift, allow them 
% to shift that point until they are satisfied, then ask them
% if they want to edit another point or exit. The user can 
% also select points from a graph using crosshairs.
%
% Functions called:
%           getAndTestInput - gets user input and tests for 
%                             errors
%           ginput - give user crosshairs on graph to select
%                    cut points
%
% Called by functions:
%           fastFit - main interface for toolbox
%           getTurningPoints - finds the points where the 
%                              chunks should be separated
%           getCutPoints - get the points to cut linear if 
%                          option is selected
%
% Input data:
%           x and y - data points
%           numTurningPoints - user inputted values for 
%                              number of turning points
%           selectOnly - used when cutting linear portions;
%                        because there are no points to 
%                        shift yet, the user must select new 
%                        points
%           turningPoint - x and y values for turning points
%           turningIndex - array index for turning points
%
% Output data:
%           turningPoint - x and y values for turning points
%           turningIndex - array index for turning points
%
% Created by: Laura Nichols
% Creation date: 22 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% If called to select points for linear cutting, then there
% will be no original turning points. But they should be 
% there otherwise.
if ~selectOnly && nargin < 6
    error('Not enough input arguments to manualMode.');
end

%--------------------------------------------------------------------------
% Set default values for loop
shiftOrSelect = 2; % Shift or select points
exit = 0; % Want to exit loop
changePoint = 1; % Change point you're working on

% Run through loop until done editing
while ~(exit)
%--------------------------------------------------------------------------
    % Ask user if want to shift current points or just select
    % new ones
    if shiftOrSelect == 2 && ~selectOnly
        clc
        request = ['\nWould you like to shift or reselect points?' ...
                                '\n\t 1) Shift' ...
                                '\n\t 2) Select\n'];
        check1 = 'length(temp) > 1';
        message1 = 'Value entered had a length greater than 1.';
        check2 = 'temp ~= 1 && temp ~= 2';
        message2 = 'Value entered was not an option.';
        shiftOrSelect = getAndTestInput(request, check1, message1, check2, message2);
    end
    
    if shiftOrSelect == 1
%--------------------------------------------------------------------------
        % If the user wants to change the point they are editing
        if changePoint    
            % Ask them which one they want to edit
            clc
            display(sprintf('\nWhich point would you like to shift?\n'));
            request = 'Please enter a single positive integer greater than 0.\n';
            check1 = sprintf('temp > %d', numTurningPoints);
            message1 = sprintf('You only said there were %d points.', numTurningPoints);
            check2 = 'floor(temp) < 1';
            message2 = 'Value entered was less than 0 or a fraction.';

            point = floor(getAndTestInput(request, check1,  message1, check2, message2));

            changePoint = 0;
        end

%--------------------------------------------------------------------------    
        % Ask the user how much they want to shift the current point
        % and give an error if the shift would put them off the graph
        clc
        display(sprintf('\nBy how many points would you like to shift?'));
        request = '\nPlease enter a single integer.\n';
        check1 = sprintf('temp < 0 && abs(temp) > %d', turningIndex(point));
        message1 = 'This shift would put you off of the graph.';
        check2 = sprintf('temp > 0 && abs(temp) > %d',(length(x) - turningIndex(point)))';
        message2 = 'This shift would put you off of the graph.';

        shift = floor(getAndTestInput(request, check1,  message1, check2, message2));

        % Adjust turning indices and turning points
        turningIndex(point) = turningIndex(point) + shift;
        turningPoint(point,1) = x(turningIndex(point));
        turningPoint(point,2) = y(turningIndex(point));

%--------------------------------------------------------------------------
        % Plot the current graph
        figure(1)
        cla reset
        plot(x, y)
        hold
        plot(turningPoint(:,1), turningPoint(:,2), 'ko')

        % Ask the user if the point they are editing looks good
        clc
        request = ['\nDoes that turning point look correct?' ...
                        '\n\t 1) yes' ...
                        '\n\t 2) no\n'];
        check1 = 'length(temp) > 1';
        message1 = 'Value entered had a length greater than 1.';
        check2 = 'temp ~= 1 && temp ~= 2';
        message2 = 'Value entered was not an option.';
        working = getAndTestInput(request, check1, message1, check2, message2);

        if working == 2
            changePoint = 0;
            working = 0;
        end

%--------------------------------------------------------------------------
        % If the user is happy with their current point ask them
        % what they want to do now
        if working      
            clc
            request = ['\nWhat would you like to do now?' ...
                        '\n\t 1) Edit another point' ...
                        '\n\t 2) Exit manual mode\n'];
            check1 = 'length(temp) > 1';
            message1 = 'Value entered had a length greater than 1.';
            check2 = 'temp ~= 1 && temp ~= 2';
            message2 = 'Value entered was not an option.';
            choice = getAndTestInput(request, check1, message1, check2, message2);

            if choice == 1
                changePoint = 1;
            elseif choice == 2
                exit = 1;
            end
        end
%--------------------------------------------------------------------------
    % If the user wants to select new points
    else
        % Loop so that points can be populated on graph
        % as they are being selected
        for i = 1:numTurningPoints
            % Pop up a new figure
            figure(1)
            cla reset
            plot(x, y)
            hold
            if i > 1
                plot(turningPoint(:,1), turningPoint(:,2), 'ko')
            end
            
            clc
            display(sprintf('Please use the crosshairs on the graph to \n select %d points.', numTurningPoints));
            
            % Get the next point
            [nextTurningPointX, nextTurningPointY] = ginput(1);
            turningPoint(i,:) = [nextTurningPointX nextTurningPointY];
        end
%--------------------------------------------------------------------------        
        % Get a point actually in the data that is closest to
        % selections
        markers = turningPoint;
        clear turningPoint

        indexX = zeros(length(markers), length(x));

        % Find indices that have an x-value close to what you want
        for i = 1:length(markers)
            indexX(i,:) = abs(x - markers(i,1)) < 1;
        end

        % Only choose one point for each index
        for i = 1:length(markers)
            found = 0;
            for j = 1:length(indexX(i,:))
                if indexX(i,j) && ~(found)
                    turningIndex(i) = j; 
                    found = 1;
                end
            end
        end

        % Get x-y values for found points
        turningPoint(:,1) = x(turningIndex);
        turningPoint(:,2) = y(turningIndex);
        
%--------------------------------------------------------------------------                
        % Plot the current graph
        figure(1)
        cla reset
        plot(x, y)
        hold
        plot(turningPoint(:,1), turningPoint(:,2), 'ko')
        
        % Ask the user if the turning points look good
        clc
        request = ['\nDoes those turning points look correct?' ...
                        '\n\t 1) yes' ...
                        '\n\t 2) no\n'];
        check1 = 'length(temp) > 1';
        message1 = 'Value entered had a length greater than 1.';
        check2 = 'temp ~= 1 && temp ~= 2';
        message2 = 'Value entered was not an option.';
        working = getAndTestInput(request, check1, message1, check2, message2);

        if working == 2
            working = 0;
        end
        
        exit = working;
    end
end
end

