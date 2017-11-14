function [ fitted, chiSquared, coefs ] = getUserInput( x, y, figNum, fitMethod, chunkCutMethod, linearCutMethod, fitFunction )
%UNTITLED Summary of this function goes here
%   9 March 2017

loopNum = 0;
clc
display(sprintf('\nThis is the fastFit toolbox. \n'));

if nargin < 7
    display(sprintf('\nThis is your data. \n'));
    figure(1)
    cla reset
    plot(x,y)
    pause(3)
end

if nargin < 4
   request = ['\nWhat fitting method would you like to use?' ...
                '\n\t 1) Basic MATLAB fitting' ...
                '\n\t 2) GA with single function' ...
                '\n\t 3) GA with multiple functions\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1 && temp ~= 2 && temp ~= 3';
    message2 = 'Value entered was not an option.';
    fitMethod = getAndTestInput(request, check1, message1, check2, message2);
    clc
end

if fitMethod == 1
    request = '\nWhat is the maximum number of times to try to fit?\n';
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp < 0';
    message2 = 'Value entered was less than zero.';
    loopNum = getAndTestInput(request, check1, message1, check2, message2);
    clc
end

if nargin < 5
    request = ['\nWhat method would you like to use\n to cut the chunks?' ...
                '\n\t 1) Manually cut' ...
                '\n\t 2) GA cut\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1 && temp ~= 2';
    message2 = 'Value entered was not an option.';
    chunkCutMethod = getAndTestInput(request, check1, message1, check2, message2);
    clc
end

if nargin < 6
    request = ['\nWhat method would you like to use\n to cut the linear portion?' ...
                '\n\t 1) Manually cut' ...
                '\n\t 2) GA cut\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1 && temp ~= 2';
    message2 = 'Value entered was not an option.';
    linearCutMethod = getAndTestInput(request, check1, message1, check2, message2);
    clc
end

if nargin < 7
    request = ['\nWhat function would you like to use?' ...
                '\n\t 1) Stretched exponential\n'];
    check1 = 'length(temp) > 1';
    message1 = 'Value entered had a length greater than 1.';
    check2 = 'temp ~= 1';
    message2 = 'Value entered was not an option.';
    fitFunctionChoice = getAndTestInput(request, check1, message1, check2, message2);
    clc
    
    if fitFunctionChoice == 1
        fitFunction = 'strExp';
    end
end

[fitted, chiSquared, coefs] = main(x, y, figNum, fitMethod, loopNum, chunkCutMethod, linearCutMethod, fitFunction);
end

