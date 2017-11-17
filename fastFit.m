function [fitted, chiSquared, coefs] = fastFit(x, y, figNum, fitMethod, chunkCutMethod, linearCutMethod, fitLinear, loopNum) 
%==========================================================================
% This function is the main interface for the rest of the 
% functions. It takes user input to determine fitting 
% options, separates the chunks, fits them, and produces
% two graphs. The first graph created is an intermediate
% graph where the user can see the separated chunks in 
% different colors. The second graph created is nicer with 
% a table with the coefficients.
% 
% In case you want to make your own plot, the fitted chunks
% are put together and returned in "fitted" and a matrix for 
% each coefficient is returned.
%
% Functions called:
%           getAndTestInput - gets user input and tests for 
%                             errors
%           getTurningPoints - finds the points where the 
%                              chunks should be separated
%           manualMode - manually move or select points for
%                        cutting
%           getFit - sends user information and turning 
%                    points, separates the chunks, and fits
%                    the data
%           plotStrExpFit - makes the nice final plot
%
% Called by functions:
%           script used to run fastFit
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
%           chunkCutMethod - how to cut cycles
%                            1 = manual
%                            2 = GA
%           linearCutMethod - how to cut linear parts
%                             1 = none
%                             2 = manual
%           fitLinear - will linear portions be fit
%                           0 = no
%                           1 = yes
%           loopNum - how many times to try to fit if using
%                     basic fitting method
%
% Output data:
%           fitted - array holding all fitted data
%           chiSquared - vector holding chi squared for each
%                        chunk
%           coefs - vector of coefficients for each chunk
%
% Created by: Laura Nichols
% Creation date: 8 March 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

if nargin < 5 || (chunkCutMethod ~= 1 && chunkCutMethod ~= 2)
    clc
    if nargin >= 5
        fprintf(['\nYour initial input for chunk cut method' ...
        ' was not an\noption. \nPlease reselect.\n']);
    end
    
    request = ['\nWhat method would you like to use\n to cut the chunks?' ...
                '\n\t 1) Manual' ...
                '\n\t 2) Automated\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1 && temp ~= 2';
    message2 = 'Value entered was not an option.';
    chunkCutMethod = getAndTestInput(request, check1, message1, check2, message2);
end

% Get turning points for graph
[turningPoints, turningIndices, turningPointsSmooth, turningIndicesSmooth, smoothX, smoothY] = getTurningPoints(x, y, chunkCutMethod);
numStrExpChunks = length(turningIndices) - 1;

%--------------------------------------------------------------------------
% Plot turning points on noisy data
figure(1)
cla reset
plot(x, y)
hold
plot(turningPoints(:,1), turningPoints(:,2), 'ko')

% Ask the user if the turning points still look good
clc
fprintf('\nThis is what the figure currently looks like.\n');

request = ['\nWhat would you like to do?' ...
            '\n\t 1) Continue' ...
            '\n\t 2) Enter manual mode\n'];
check1 = 'length(temp) > 1';
message1 = 'Value entered had a length greater than 1.';
check2 = 'temp ~= 1 && temp ~= 2';
message2 = 'Value entered was not an option.';
choice = getAndTestInput(request, check1, message1, check2, message2);

if choice == 2
    [turningPoints, turningIndices, turningPointsSmooth, turningIndicesSmooth, smoothX, smoothY] = getTurningPoints(x, y, 1);
end

%--------------------------------------------------------------------------
% Get chunks shifted to zero and fit

if nargin < 4 || (fitMethod ~= 1 && fitMethod ~= 2 && fitMethod ~= 3)
   clc
   if nargin >= 4
        fprintf(['\nYour initial input for fit method' ...
        ' was not an\noption. \nPlease reselect.\n']);
   end
    
   request = ['\nWhat fitting method would you like to use?' ...
                '\n\t 1) Basic MATLAB fitting' ...
                '\n\t 2) GA with single function' ...
                '\n\t 3) GA with multiple functions\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1 && temp ~= 2 && temp ~= 3';
    message2 = 'Value entered was not an option.';
    fitMethod = getAndTestInput(request, check1, message1, check2, message2);
end

if fitMethod == 1 && nargin < 7
    clc
    request = '\nWhat is the maximum number of times to try to fit?\n';
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp < 0';
    message2 = 'Value entered was less than zero.';
    loopNum = getAndTestInput(request, check1, message1, check2, message2);
end

if nargin < 6 || (linearCutMethod ~= 1 && linearCutMethod ~= 2)
    clc
    if nargin >= 6
        fprintf(['\nYour initial input for linear cut method' ...
        ' was not an\noption. \nPlease reselect.\n']);
    end
   
    request = ['\nWhat method would you like to use\n to cut the linear portion?' ...
                '\n\t 1) No cut' ...
                '\n\t 2) Manually cut\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1 && temp ~= 2';
    message2 = 'Value entered was not an option.';
    linearCutMethod = getAndTestInput(request, check1, message1, check2, message2);
end

if linearCutMethod ~= 1 && (nargin < 7 || (fitLinear ~= 0 && fitLinear ~= 1))
    clc
    if nargin >= 7
        fprintf(['\nYour initial input for fitLinear' ...
        ' was not an\noption. \nPlease reselect.\n']);
    end
   
    request = ['\nWould you like to fit the linear\n portions?' ...
                '\n\t 0) No' ...
                '\n\t 1) Yes\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 0 && temp ~= 1';
    message2 = 'Value entered was not an option.';
    linearCutMethod = getAndTestInput(request, check1, message1, check2, message2);
elseif linearCutMethod == 1
    fitLinear = 0;
end

[coefs, chiSquared, allCutIndex, chunk, fitted] = getFit(x, y, smoothX, smoothY, turningIndices, turningIndicesSmooth, loopNum, fitMethod, linearCutMethod, fitLinear);

countFit = numStrExpChunks;
numChunks = length(allCutIndex) - 1;
countLinear = numChunks - numStrExpChunks;
%--------------------------------------------------------------------------
% Manual fitting if needed
% General form is: coefs# = [a1 a2 beta tau];
%coefs1 = [];
%coefs2 = [];
%coefs3 = [];
%coefs4 = [];

%fitted1 = [chunk1(:,1) strExpManFit(coefs1, shiftedChunk1(:,1))];
%fitted2 = [chunk2(:,1) strExpManFit(coefs2, shiftedChunk2(:,1))];
%fitted3 = [chunk3(:,1) strExpManFit(coefs3, shiftedChunk3(:,1))];
%fitted4 = [chunk4(:,1) strExpManFit(coefs4, shiftedChunk4(:,1))];

%--------------------------------------------------------------------------
% Plot fit with data for intermediate plot
figure(figNum+1);
cla reset
h = plot(x, y);
hold
plot(turningPoints(:,1), turningPoints(:,2), 'ko')
% Set colors for plotting
color = ['r' 'g' 'y' 'm' 'c'];
for i=1:numChunks
  plot(chunk{1,i}(:,1), chunk{1,i}(:,2), color(mod(i-1,5)+1))
end

fittedTotal = fitted{1,1};

for i = 2:numChunks
    fittedTotal = [fittedTotal; fitted{1,i}];
end

plot(fittedTotal(:,1), fittedTotal(:,2), 'k', 'linewidth',2)

% Set font size
ax = gca;
ax.FontSize = 16;         
% Create a legend
legend( h, 'Experimental Data', 'Stretched Exponential Fit', 'Location', 'NorthEast' );
% Label axes
xlabel('Time (s)')
ylabel('Transmittance (%)')
% 
% %--------------------------------------------------------------------------
% chiSquared

%--------------------------------------------------------------------------
    if fitMethod == 3
        % Define background coefficients
        a1B = coefs(1);
        a2B = coefs(2);
        betaB = coefs(3);
        tauB = coefs(4);
    else
        % Set to make background zero
        a1B = 0; 
        a2B = 0;
        betaB = 1;
        tauB = 1;
    end
    
%--------------------------------------------------------------------------
    % Get coefficients for nonlinear chunks

    % Preallocate for speed
    a1 = zeros(1,countFit);
    a2 = zeros(1,countFit);
    beta = zeros(1,countFit);
    tau = zeros(1,countFit);

    % Set loop variables
    count = 0;
    if fitMethod == 3
        start = 5;
        finish = 4*(countFit+1);
    else
        start = 1;
        finish = 4*countFit;
    end
    
    % Populate nonlinear coefficients
    for i = start:4:finish
        count = count + 1;
        a1(count) = coefs(i);
        a2(count) = coefs(i+1);
        beta(count) = coefs(i+2);
        tau(count) = coefs(i+3);
    end

%--------------------------------------------------------------------------
    % Get coefficients for linear chunks

    % Preallocate for speed
    m = zeros(1,countLinear);
    b = zeros(1,countLinear);

    % Set loop variables
    count = 0;
    if fitMethod == 3
        start = 4*(countFit+1) + 1;
        finish = 4*(countFit+1) + 2*countLinear;
    else
        start = 4*countFit + 1;
        finish = 4*countFit + 2*countLinear;
    end

    % Populate linear coefficients
    for i = start:2:finish
        count = count + 1;
        m(count) = coefs(i);
        b(count) = coefs(i+1);
    end
%--------------------------------------------------------------------------
% Get a prettier final plot with table including fit parameters

plotStrExpFit(x, y, a1, a2, beta, tau, chiSquared, fitted, figNum+2, numChunks, numStrExpChunks);

end
