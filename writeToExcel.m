function writeToExcel( fileName, coefs, chiSquared, startPoint1, startPoint2 ) %#ok<INUSL>
%==========================================================================
% This file takes the coefficients for a given data set and
% writes them to an excel spreadsheet.
%
% This works best if the spreadsheet is already created and
% formatted because it only ouputs the numbers.
%
% Created by: Laura Nichols
% Creation date: 25 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Figure out how many chunks you have
[numChunks, numVars] = size(coefs);

% Change data to be organized by chunk not coefficient

firstDecay(1:4) = coefs(1,1:4);
firstDecay(5) = chiSquared(1);

% If there are no values to give, then output '-'
firstIncrease(1:5) = '-';
secondDecay(1:5) = '-';
secondIncrease(1:5) = '-';

%--------------------------------------------------------------------------
% Add data to table if you have it
if numChunks > 1
    clear firstIncrease
    
    firstIncrease(1:4) = coefs(2,1:4);
    firstIncrease(5) = chiSquared(2);
end

if numChunks > 2
    clear secondDecay
    
    secondDecay(1:4) = coefs(3,1:4);
    secondDecay(5) = chiSquared(3);
end

if numChunks > 3 
    clear secondIncrease
    
    secondIncrease(1:4) = coefs(4,1:4);
    secondIncrease(5) = chiSquared(4);
end
%--------------------------------------------------------------------------
% Give an error if there are more than 4 chunks used
if numChunks > 4
    error('writeToExcel() is not formatted to write out your data.');
end

%--------------------------------------------------------------------------
% Format data for table
firstDecay = firstDecay';
firstIncrease = firstIncrease';
secondDecay = secondDecay';
secondIncrease = secondIncrease';

% Create table
T = table(firstDecay, firstIncrease, secondDecay, ...
    secondIncrease);

% Ouput table to spreadsheet
eval(sprintf(['writetable(T,fileName,''Sheet'''...
    ',1,''Range'',''%s'', ''WriteVariableNames'',false)'], startPoint1{:}));

%--------------------------------------------------------------------------

%T = table(coefs');

% Ouput table to spreadsheet
%eval(sprintf(['writetable(T,fileName,''Sheet'''...
%    ',2,''Range'',''%s'', ''WriteVariableNames'',false)'], startPoint2{:}));

end

