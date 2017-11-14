function [ coefs, chiSquared, fitresult ] = basicFit( x, y, loopNum )
%==========================================================================
% This function will try to fit the given chunk to a stretched
% exponential curve using the given starting points (start). 
% The numbers in start correspond to the starting points for 
% a1, a2, beta, and tau, respectively. If the starting points 
% do not work, randomly add or subtract the values in step to 
% get different starting points and retry the fit.
%
% If the loop goes more than the maximum allowed times 
% (loopNum), the function will exit and display an error 
% saying that the fit did not work and processing will stop.
%
% Created by: Laura Nichols
% Creation date: 19 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Set initial start values
start = [15 0.5 100];

% Set how much to change values in a step
step = [1 0.1 10];

% Try to fit until it works or you run out of loops
working = 0;
count = 0;
while ~(working) && count < loopNum
    count = count + 1;
    try
        [fitresult, ~] = strExpFit(x, y, start);
        working = 1;
    catch
        working = 0;
        % Create matrix with plus or minus randomly
        pm = rand([1, length(start)]);
        pm(pm<0.5) = -1;
        pm(pm>=0.5) = 1;
        
        start = start + pm.*step;
    end
end

% Give an error if the fit never worked
if count >= loopNum
    error('Could not get fit to work with given loop limit.');
else
    coefs = [fitresult.a1 (fitresult.a1-y(1)) fitresult.beta fitresult.tau];
    chiSquared = getChiSquared(x, y, fitresult);
end
end

