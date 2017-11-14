function [ y ] = strExpManFitEval( coefs, x )
%==========================================================================
% This function takes input coefficients (coefs) in the form
% coefs = [a1 a2 beta tau] and evaluates them and the given 
% x-data in a stretched exponential function and returns the 
% y-values.
%
% Created by: Laura Nichols
% Creation date: 19 February 2017
% Contact: lnichols11@my.apsu.edu
%==========================================================================

% Get coefficients from input data
a1 = coefs(1);
a2 = coefs(2);
beta = coefs(3);
tau = coefs(4);

% Evaluate stretched exponential
y = a1 - a2*exp(-(x/tau).^beta);
end

