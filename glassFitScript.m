%==========================================================================
% This script loads in your data and formats them to be input
% into fastFit(). The scipt then calls fastFit() on each one
% and then saves the results to an excel spreadsheet.
% 
% The saving to an excel spreadsheet is meant to write data
% on an existing formatted sheet.
%
% Functions called:
%           dlmread - MATLAB code to read files
%           fastFit - main program for fitting toolbox
%           writeToExcel - write coefficients to excel file
%
% Call by functions:
%           N/A
%
% Input data:
%           N/A
%
% Output data:
%           N/A
%
% Created by: Laura Nichols
% Creation date: 19 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Set whether you want to load the data or not
% This is useful when running the script several times
reload = 1;
if ~exist('timesRun')
    timesRun = 0;
end
    
%--------------------------------------------------------------------------
% Load and format the data if you want
if reload || timesRun == 0
    % Load all of the data
    
    % Define the path to your files
    path = 'C:\Users\LJUDY\Desktop\MyStuff\Research\APSU\Glass\experimentalFitCurves\experimentalData\';
    
    As28S72_385_15 = dlmread([path 'As28S72_Assu12-7_420nmtrack_385nm_15mW.dat'], ' ', 1, 0);
    As28S72_385_90 = dlmread([path 'As28S72_Assu7-7_450nmtrack_385nm_90mW.dat'], ' ', 1, 0);
    As28S72_532_15 = dlmread([path 'As28S72_Assu10-3_410nmtrack_532nm_15mW.dat'], ' ', 1, 0);
    As28S72_532_90 = dlmread([path 'As28S72_Assu7-7_445nmtrack_532nm_90mW.dat'], ' ', 1, 0);

    As33S67_385_15 = dlmread([path 'As33S67_Assu11-3_445nmtrack_385nm_15mW.dat'], ' ', 1, 0);
    As33S67_385_90 = dlmread([path 'As33S67_Assu11-2_445nmtrack_385nm_90mW.dat'], ' ', 1, 0);
    As33S67_532_15 = dlmread([path 'As33S67_Assu11-4_445nmtrack_532nm_15mW.dat'], ' ', 1, 0);
    As33S67_532_90 = dlmread([path 'As33S67_Assu11-1_445nmtrack_532nm_90mW.dat'], ' ', 1, 0);
    
    As2S3_385_15 = dlmread([path 'As2S3_Assu6-2_470nmtrack_385nm_15mW.dat'], ' ', 1, 0);
    As2S3_385_90 = dlmread([path 'As2S3_Assu8-6_470nmtrack_385nm_90mW.dat'], ' ', 1, 0);
    As2S3_532_15 = dlmread([path 'As2S3_Assu9-1_470nmtrack_532nm_15mW.dat'], ' ', 1, 0);
    As2S3_532_90 = dlmread([path 'As2S3_Assu8-5_470nmtrack_532nm_90mW.dat'], ' ', 1, 0);
    
    % Define all of the compositions, wavelengths, and powers
    composition = {'As28S72'; 'As33S67'; 'As2S3'};
    wavelength = [385 532];
    power = [15 90];
%--------------------------------------------------------------------------
    % Format x and y for each combination
    % x11 is x(composition(1), wavelength(1), power(1)),
    % x21 is x(composition(2), wavelength(1), power(1)),
    % x12 is x(composition(1), wavelength(2), power(2)), etc.
    for i = 1:length(composition)
        combo = 0;
        for j = 1:length(wavelength)
            for k = 1:length(power)
                % Keep up with combination of wavelenth and power
                combo = combo + 1;
                
                % Format x
                eval(sprintf('x%d%d = %s_%d_%d(:,1);', i, ...
                        combo, composition{i}, wavelength(j), ...
                        power(k)));
                    
                % Format y
                eval(sprintf('y%d%d = %s_%d_%d(:,2);', i, ...
                        combo, composition{i}, wavelength(j), ...
                        power(k)));
            end
        end
    end
end

%--------------------------------------------------------------------------
% Set file name with path to excel spreadsheet
fileName = 'C:\Users\LJUDY\Desktop\My Stuff\Research\glass\experimentalFitCurves\GACutAll\coefficients.xlsx';
% Set positions for where to write data
positions1 = {'C4'; 'K4'; 'C11'; 'K11'; 'C18'; 'K18'; 'C25'; 'K25'; 'C32'; 'K32'; 'C39'; 'K39'};
positions2 = {'B4'; 'C4'; 'D4'; 'E4'; 'F4'; 'G4'; 'H4'; 'I4'; 'J4'; 'K4'; 'L4'; 'M4'};

%--------------------------------------------------------------------------
% Send all of your data to fastFit() and save to spreadsheet

% Used to keep up with figure number
n = 1;

% Set how many data sets you want to skip
% This is useful when running the script several times
%skip = 9; % Good for fast testing
skip = 1;

% Used to keep up with how many have been skipped
numSkipped = 0;


for i = 1:length(composition)
    combo = 0;
    for j = 1:length(wavelength)
        for k = 1:length(power)
            combo = combo + 1;
            
            % Send data to fastFit() and save if you have 
            % skipped as many as you want
            if numSkipped == skip
                % Set preferences for fitting
                figNum =  n;
                fitMethod = 5; % 1 = basic, 2 = single GA, 3 = background GA
                chunkCutMethod = 2; % 1 = manual, 2 = auto
                linearCutMethod = 6; % 1 = none, 2 = manual, 3 = GA
                loopNum = 100;
                
                % Send to glassFit()
                eval(sprintf(['[fitted_%d%d, chiSquared%d%d, coefs%d%d] =' ...
                    'fastFit(x%d%d,y%d%d, figNum, fitMethod, chunkCutMethod,'...
                    'linearCutMethod, loopNum);'], ...
                    i, combo, i, combo, i, combo, i, combo, ...
                    i, combo));
                timesRun = timesRun + 1;
                error('Quitting for debugging.');   
                % Save to spreadsheet
                eval(sprintf(['writeToExcel(''%s'', coefs%d%d,'...
                    'chiSquared%d%d, positions1(floor(n/2)+1), positions2(floor(n/2)+1))'], ...
                    fileName, i, combo, i, combo))
            else 
                numSkipped = numSkipped + 1;
            end
            n = n + 2;
        end
    end
end

timesRun = timesRun + 1;
