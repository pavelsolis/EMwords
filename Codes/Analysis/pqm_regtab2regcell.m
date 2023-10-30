function regcell = pqm_regtab2regcell(regtab,nocons)
% Convert an array with regression output into a cell with standard format
% Assumptions:
% - For each coefficient, regtab reports its estimate and standard error
% - The values for the constant are below the rest of the coefficients
% - The last two rows of regtab report the number of obs. and the R-squared
% 
% Inputs:
% - regtab: array where each column reports the output of a regression
% - nocons: boolean on whether to *report* the constant
%%
if nargin < 2
    nocons = false;                                                         % default is to include the constant
end

% Extract coefficients and standard errors
regout = regtab(1:end-2,:);
coeffs = regout(1:2:end,:);
stderr = regout(2:2:end,:);

% Compute p-values
dgfree = regtab(end-1,:) - (size(regout,1)-sum(isnan(regout)))/2;           % number of observations minus number of coefficients
tstats = coeffs./stderr;                                                    % coefficients over standard errors
pvals  = (1-tcdf(abs(tstats),repmat(dgfree,3,1)))*2;                        % positive tstats; times 2 for a two-tailed test

% Round to 2 and (if zero) up to 3 decimals
coefrn2 = round(coeffs,2);
coefrn3 = round(coeffs,3);
coefrn2(coefrn2 == 0) = coefrn3(coefrn2 == 0);
stdern2 = round(stderr,2);
stdern3 = round(stderr,3);
stdern2(stdern2 == 0) = stdern3(stdern2 == 0);
r2rnd2  = round(regtab(end,:),2);
r2rnd3  = round(regtab(end,:),3);
r2rnd2(r2rnd2 == 0) = r2rnd3(r2rnd2 == 0);

% Add stars to coefficients
coefstr = cellstr(string(coefrn2));
coefstr(pvals < 0.01) = strcat(coefstr(pvals < 0.01),'***');
coefstr(pvals < 0.05 & pvals >= 0.01) = strcat(coefstr(pvals < 0.05 & pvals >= 0.01),'**');
coefstr(pvals < 0.1 & pvals >= 0.05)  = strcat(coefstr(pvals < 0.1 & pvals >= 0.05),'*');

% Add parenthesis to standard errors
stderpr = cellstr(string(stdern2));
stderpr(~isnan(stderr)) = strcat('(',stderpr(~isnan(stderr)),')');

% Store results in a cell array
regcell = cell(size(regout));
regcell(1:2:end,:) = coefstr;
regcell(2:2:end,:) = stderpr;
regcell(end+1,:)   = cellstr(string(regtab(end-1,:)));
regcell(end+1,:)   = cellstr(string(r2rnd2));

if nocons
    regcell(end-3:end-2,:) = [];                                            % remove values for the constant
end