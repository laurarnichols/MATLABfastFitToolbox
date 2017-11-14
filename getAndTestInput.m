function inVal = getAndTestInput( request, check1,  message1, check2, message2)
%==========================================================================
% This function takes messages and checks to test, gets input 
% from the user, and makes sure they meet the requirements.
%
% Functions called:
%           N/A
%
% Called by functions:
%           fastFit - main interface for toolbox
%           getTurningPoints - finds the points where the 
%                              chunks should be separated
%           manualMode - manually move or select points for
%                        cutting
%           getCutPoints - get the points to cut linear if 
%                          option is selected
%
% Input data:
%           request - message to display to user to ask
%                     for info
%           check1 and check2 - what tests to use to validate
%                               user input
%           message1 and message2 - what message to output if
%                                   user input does not meet
%                                   requirements
%
% Output data:
%           inVal - validated user input value
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Check to make sure the number of arguments makes sense
if nargin < 3, error('Not enough input arguments to getAndTestInput().'); end
if nargin == 4, error('Not enough input arguments to getAndTestInput().'); end
if nargin > 5, error('Too many input arguments to getAndTestInput().'); end

%--------------------------------------------------------------------------
% Get preliminary input from user
temp = input(sprintf(request));

% Test checks based on how many checks the function was given
if nargin == 3
    while eval(sprintf(check1))
        display(sprintf(message1));
        temp = input(sprintf(request));
    end
else
    while eval(sprintf(check1)) || eval(sprintf(check2))
        if eval(sprintf(check1))
            display(sprintf(message1));
        else
            display(sprintf(message2));
        end

        temp = input(sprintf(request));
    end
end

%--------------------------------------------------------------------------
% Set the return value to the final correct input
inVal = temp;
end

