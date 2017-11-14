% real value Mutation like Discrete Breeder genetic algorithm
%
% This function takes a matrix Chrom containing the real
% representation of the individuals in the current population,
% mutates the individuals with probability MutR and returns
% the resulting population.
%
% This function implements the mutation operator of the Breeder
% Genetic Algorithm. (Muehlenbein et. al.)
%
% Syntax:  NewChrom = mutreal(OldChrom, VLUB, MutOpt)
%
% Input parameter:
%    Chrom     - Matrix containing the chromosomes of the old
%                population. Each row corresponds to one individual.
%    VLUB      - Matrix describing the boundaries of each variable.
%    MutOpt    - (optional) Vector containing mutation options
%                MutOpt(1): MutRate - number containing the mutation rate -
%                           probability for mutation of a variable
%                           if omitted or NaN, MutRate = 1/variables per individual
%                           is assumed
%                MutOpt(2): MutRange - (optional) number for shrinking the
%                           mutation range in the range [0 1], possibility to
%                           shrink the range of the mutation depending on,
%                           for instance actual generation.
%                           if omitted or NaN, MutRange = 1 is assumed
%                MutOpt(3): MutPreci - (optional) precision of mutation steps
%                           if omitted or NaN, MutPreci = 16 is assumed
%
% Output parameter:
%    NewChrom  - Matrix containing the chromosomes of the population
%                after mutation in the same format as OldChrom.
%
% See also: mutate, mutbin, mutint

% Author:   Hartmut Pohlheim
% History:  23.11.1994  file created
%           06.12.1994  change of function name
%                       check of boundaries after mutation out of loop
%           16.02.1995  preparation for multi-subpopulations at once
%           03.03.1995  Lower and Upper directly used (less memory)
%           19.03.1995  multipopulation support removed
%                       more parameter checks
%           27.03.1995  Delta exact calculated, for loop saved
%           17.01.1996  Parameter MutPreci added
%           02.03.1998  excluded setting of variables to boundaries, 
%                       when variables outside boundaries
%           25.08.1998  changed default value of MutRange to 0.2 (from 1)
%           23.06.2002  error test excluded, only warnings now, reset of 
%                       outside parameters to defaults


function NewChrom = mutreal(Chrom, VLUB, MutOpt)

% Identify the population size (Nind) and the number of variables (Nvar)
   [Nind,Nvar] = size(Chrom);

% Set standard mutation parameter
   MutOptStandard = [1/Nvar, 1, 16];      % MutRate = 1/Nvar, MutRange = 1, MutPreci = 16

% Check parameter consistency
   if nargin < 2,  error('Not enough input parameter'); end

   [mF, nF] = size(VLUB);
   if mF ~= 2, error('VLUB must be a matrix with 2 rows'); end
   if Nvar ~= nF, error('VLUB and Chrom disagree'); end

   if nargin < 3, MutOpt = []; end
   if isnan(MutOpt), MutOpt = []; end
   if length(MutOpt) > length(MutOptStandard), error(' Too many parameter in MutOpt'); end

   MutOptIntern = MutOptStandard; MutOptIntern(1:length(MutOpt)) = MutOpt;
   MutRate = MutOptIntern(1); MutRange = MutOptIntern(2); MutPreci = MutOptIntern(3);

   if isnan(MutRate), MutRate = MutOptStandard(1);
   elseif (MutRate < 0 || MutRate > 1), 
      warning(sprintf('Parameter for mutation rate must be a scalar in [0, 1] (and not %g). Reset to %g.', MutRate, MutOptStandard(1)));
      MutRate = MutOptStandard(1);
   end

   if isnan(MutRange), MutRange = MutOptStandard(2);
   elseif (MutRange < 0 || MutRange > 1), 
      warning(sprintf('Parameter for shrinking mutation range must be a scalar in [0, 1] (and not %g). Reset to %g.', ...
                       MutRange, MutOptStandard(2)));
      MutRange = MutOptStandard(2);
   end

   if isnan(MutPreci), MutPreci = MutOptStandard(3);
   elseif MutPreci < 1, 
      warning(sprintf('Parameter for mutation precision must be >= 1 (and not %g). Parameter reset to %g.', MutPreci, MutOptStandard(3)));
      MutPreci = MutOptStandard(3);
   end

% the variabels are mutated with probability MutRate
% NewChrom = Chrom (+ or -) * Range * MutRange * Delta
% Range = 0.5 * (upperbound - lowerbound)
% Delta = Sum(Alpha_i * 2^-i) from 0 to MutPreci; Alpha_i = rand(MutPreci,1) < 1/MutPreci

% Matrix with range values for every variable
   Range = repmat(MutRange * (VLUB(2,:) - VLUB(1,:)), [Nind 1]);

% zeros and ones for mutation or not of this variable, together with Range
   Range = Range .* (rand(Nind,Nvar) < MutRate);

% Compute, if + or - sign 
   Range = Range .* (1 - 2 * (rand(Nind,Nvar) < 0.5));

% Used for later computing, here only ones computed
   Vect = 2 .^ (-(0:(MutPreci-1))');
   Delta = (rand(Nind,MutPreci) < 1/MutPreci) * Vect;
   Delta = repmat(Delta, [1 Nvar]);

% Perform mutation 
   NewChrom = Chrom + Range .* Delta;


% End of function

