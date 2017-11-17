function testPlot( fitInfo, x, y, allFit, wasCut, unshiftedChunks, fitChunks, coefs, fitMethod, fitLinear )  %#ok<INUSL>
%==========================================================================
% This function takes the fit data and initial data to create a 
% rough plot to see what's going on when testing.
%
% Functions called:
%           cFit - MATLAB function to produce function for 
%                  evaluation; similar to output of fit
%                  function
%
% Called by functions:
%           Changes as testing progresses
%
% Input data:
%           fitInfo - option to tell what information you
%                     are giving
%                          1 = just coefficients
%                          2 = entire array of fitted
%                              data
%           x and y - data points
%           allFit - array containing all fit data
%           wasCut - array containing booleans for whether or
%                    not each chunk was linearly cut
%           unshiftedChunks - cell array containing each
%                             of the unshifted separated
%                             chunks
%           coefs - vector containing fit coefficients
%           fitMethod - choice of what fitting to use:
%                           1 = basic
%                           2 = single GA
%                           3 = background GA
%
% Output data:
%           N/A
%
% Created by: Laura Nichols
% Creation date: 15 June 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

if fitInfo == 1 
    [~, numChunks] = size(unshiftedChunks);
%--------------------------------------------------------------------------
    % Separate fit chunks into individual variables from the
    % cell array returned by getFitChunks

    % Set up loop variables
    countFit = 0;
    countLinear = 0;
    i = 1;

    % Separate chunks
    while i <= numChunks
        countFit = countFit + 1;
        eval(sprintf('fitChunk%d = fitChunks{:,i};', countFit));
        eval(sprintf('unshiftedChunk%d = unshiftedChunks{:,i};', countFit));
        i = i + 1;
        if wasCut(countFit)
            countLinear = countLinear + 1;
            eval(sprintf('linearChunk%d = fitChunks{:,i};', countLinear));
            eval(sprintf('unshiftedLinearChunk%d = unshiftedChunks{:,i};', countLinear));
            i = i + 1;
        end
    end
    
    if fitLinear == 0
        countLinear = 0;
    end
    
%-------------------------------------------------------------------------- 
    % Define nonlinear fit type
    for i = 1:countFit
        ft{1,i} = fittype('(a1-a2*exp(-(t/tau)^beta)) + (a1B-a2B*exp(-(t/tauB)^betaB))', 'independent', 't', 'dependent', 'y' ); %#ok<AGROW>
    end

    % Define linear fit type
    for i = 1:countLinear
        ftLin{1,i} = fittype( 'm*t + b + a1B - a2B*exp(-(t/tauB)^betaB)', 'independent', 't', 'dependent', 'y' );  %#ok<AGROW>
    end
    
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
    % Generate functions 
    for i = 1:countFit
        fitresult{1,i} = cfit(ft{1,i}, a1(i), a1B, a2(i), a2B, beta(i), betaB, tau(i), tauB);  %#ok<AGROW>
    end

    % Generate functions to return and get the chi squared values
    % for linear chunks
    for i = 1:countLinear
        fitresultLinear{1,i} = cfit(ftLin{1,i}, a1B, a2B, b(i), betaB, m(i), tauB);  %#ok<AGROW>
    end
%-------------------------------------------------------------------------- 
    % Put all of the fit results in arrays
    
    % Nonlinear
    for i = 1:countFit
        fitresult1 = fitresult{1,i}; %#ok<NASGU>
        eval(sprintf('fitted%d = [unshiftedChunk%d(:,1) fitresult1(fitChunk%d(:,1))];', i, i, i));
    end

    % Linear
    for i = 1:countLinear
        fitresultLinear1 = fitresultLinear{1,i}; %#ok<NASGU>
        eval(sprintf('fittedLinear%d = [unshiftedLinearChunk%d(:,1) fitresultLinear1(linearChunk%d(:,1))];', i, i, i));
    end

    i = 1;
    countFit = 0;
    countLinear = 0;
    
    figure(1)
    cla reset
    h = plot(x, y, fitted1(:,1), fitted1(:,2));
    % Make the fitted line thicker
    set(h(2),'linewidth',2,'Color', [0.8392, 0.3333, 0.2314])
    hold
    
   if wasCut(1) && fitLinear ~= 0
       plot(fittedLinear1(:,1), fittedLinear1(:,2),'Color' , [0.8392, 0.3333, 0.2314],'linewidth',2)
       countLinear = countLinear + 1;
       i = i + 1;
   elseif wasCut(1)
       i = i+ 1;
   end
    
    i = i + 1;
    countFit = countFit + 1;
    while i <= numChunks
        countFit = countFit + 1;
        eval(sprintf('plot(fitted%d(:,1), fitted%d(:,2),''Color'', [0.8392, 0.3333, 0.2314],''linewidth'',2)', countFit, countFit));
        i = i + 1;
        if wasCut(countFit) && fitLinear ~= 0
            countLinear = countLinear + 1;
            eval(sprintf('plot(fittedLinear%d(:,1), fittedLinear%d(:,2),''Color'', [0.8392, 0.3333, 0.2314],''linewidth'',2)', countLinear, countLinear));
            i = i + 1;
        elseif wasCut(countFit)
            i = i + 1;    
        end
    end
    % Set font size
    ax = gca;
    ax.FontSize = 16;         
    % Create a legend
    legend( h, 'Experimental Data', 'Stretched Exponential Fit', 'Location', 'NorthEast' );
    % Label axes
    xlabel('Time (s)')
    ylabel('Transmittance (%)')
    axis([0 2e4 16 23])
    
elseif fitInfo == 2
    figure(1)
    cla reset
    h = plot(x, y, allFit(:,1), allFit(:,2));
    % Make the fitted line thicker
    set(h(2),'linewidth',2)
    % Set font size
    ax = gca;
    ax.FontSize = 16;         
    % Create a legend
    legend( h, 'Experimental Data', 'Stretched Exponential Fit', 'Location', 'NorthEast' );
    % Label axes
    xlabel('Time (s)')
    ylabel('Transmittance (%)')
    axis([0 2e4 16 23])
elseif fitInfo == 3
    count = wasCut;
    
    for i = 1:count
        eval(sprintf('fitted%d = allFit{:,i};', i));
    end
    
    figure(1)
    cla reset
    h = plot(x, y, fitted1(:,1), fitted1(:,2));
    % Make the fitted line thicker
    set(h(2),'linewidth',2,'Color', [0.8392, 0.3333, 0.2314])
    hold
    
    for i = 2:count
        eval(sprintf('plot(fitted%d(:,1), fitted%d(:,2),''Color'', [0.8392, 0.3333, 0.2314],''linewidth'',2)', i, i));
    end
    % Set font size
    ax = gca;
    ax.FontSize = 16;         
    % Create a legend
    legend( h, 'Experimental Data', 'Stretched Exponential Fit', 'Location', 'NorthEast' );
    % Label axes
    xlabel('Time (s)')
    ylabel('Transmittance (%)')
    axis([0 2e4 16 23])
else 
    error('Invalid option to testPlot.')
end
end

