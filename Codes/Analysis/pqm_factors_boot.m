function TTbs = pqm_factors_boot(TT,dateStrt,dateEnd,dateScale,nboot,excld)
% TTbs:      timetable with synthetic factors
% TT:        timetable with original data
% dateStrt:  starting date of sample
% dateEnd:   ending date of sample
% dateScale: starting date for rescaling, must be between dateStrt and dateEnd
% nboot:     number of bootstrap samples
% excld:     true to exclude extraordinary meetings when calculating the factors
%%
if nargin < 6
    excld = true;
end
if ~isbetween(dateScale,dateStrt,dateEnd)
    warning('Rescaling date must be between start and end dates.')
end

% Define periods and variables
xtrmtngs = {'27-Apr-2004','17-Feb-2016','20-Mar-2020','21-Apr-2020'};       % dates of extraordinary meetings
ttaux    = TT;
[y,m,d]  = ymd(ttaux.Date);
dates    = datetime(y,m,d);
idxSmple = isbetween(dates,dateStrt,dateEnd);
if excld == true
    idxSmple = idxSmple & ~ismember(datenum(dates),datenum(xtrmtngs)); 
end
idxScale = isbetween(dates,dateScale,dateEnd);
idxScale(~idxSmple) = [];                                                   % scale positions relative to sample positions
idxSwaps = ismember(ttaux.Properties.VariableNames,{'MPSWC','MPSWF','MPSWI','MPSW1A'});
idxS3M   = ismember(ttaux.Properties.VariableNames(idxSwaps),'MPSWC');      % index relative to idxSwaps
idxS1Y   = ismember(ttaux.Properties.VariableNames(idxSwaps),'MPSW1A');

% Read the data
XX    = table2array(ttaux);
data  = XX(idxSmple,idxSwaps);
T     = size(data,1);
X     = (data - repmat(mean(data),T,1))./repmat(std(data),T,1);             % cols of XX: de-mean and unit std

% Generate bootstrap samples
[weights,F] = pca(X);                                                       % F = X*weights; X = F*weights' = F*ldngs;
Xhat  = F(:,1:2)*weights(:,1:2)';                                           % mean(diag(pdist2(X,Xhat,'cosine'))); ~0
zeta  = X - Xhat;                                                           % residuals
zetaw = zeta;                                                               % Winsorize residuals
pctls = prctile(zeta,[1 99]);                                               % 1st and 99th cut-off percentiles
i1 = zeta < pctls(1,:); i2 = zeta > pctls(2,:);
for k1 = 1:size(zeta,2)
    zetaw(i1(:,k1),k1) = min(zeta(~i1(:,k1),k1));
    zetaw(i2(:,k1),k1) = max(zeta(~i2(:,k1),k1));
end

Zboot = nan(T,2*nboot);
for ibs = 1:nboot
    rng(ibs);                                                               % same seed as for regressions
    Xboot = Xhat + zetaw(randi(T,T,1),:);                                   % sample residuals with replacement
    
    % Extract and standardize the factors
    [weights,F] = pca(Xboot);
    Fstd  = F./std(F);                                                      % normalize factors to have unit std
    ldngs = (weights.*std(F))';                                             % 1st column is loadings to each factor for X(:,1)
    F1 = Fstd(:,1);     F2 = Fstd(:,2);
    g1 = ldngs(1,1);    g2 = ldngs(2,1);                                    % loadings of X(:,1) on F1 & F2: g? = corr(X(:,1),F?)
                                                                            % cov = corr since X(:,1) & F1 have unit variances
        % Rotate the (standardized) factors
    a1 = sqrt(1/(1+(g2/g1)^2));
    a2 = g2*a1/g1;
    b1 = sqrt(1/(1+(a1/a2)^2));
    b2 = -a1*b1/a2;
    U  = [a1 b1;a2 b2];
    Z  = [F1 F2]*U;

        % Rescale the rotated factors
    S3M = data(idxScale,idxS3M);                                            % MP surprise (S3M) in basis points
    S1Y = data(idxScale,idxS1Y);                                            % surprise in S1Y in basis points
    b01 = cov(S3M,Z(idxScale,1))/var(Z(idxScale,1));                        % b01(1,2): OLS coefficient of S3M on target factor 
    rs1 = b01(1,2);
    Z1  = rs1*Z(:,1);                                                       % rescales Z1 so it moves 1-to-1 with S3M
    b02 = cov(S1Y,Z(idxScale,2))/var(Z(idxScale,2));                        % b02(1,2): OLS coefficient of S1Y on unscaled Z2
    b03 = cov(S1Y,Z1(idxScale))/var(Z1(idxScale));                          % b03(1,2): OLS coefficient of S1Y on rescaled Z1
    rs2 = b02(1,2)/b03(1,2);
    Z2  = rs2*Z(:,2);                                                       % rescales Z2 to move 1-to-1 w/ effect of Z1 on S1Y
    
    Zboot(:,2*ibs-1:2*ibs) = [Z1 Z2];
end

fctrsbs = nan(size(ttaux,1),size(Zboot,2));
fctrsbs(idxSmple,:) = Zboot;                                                % note: size(Zboot,1) < size(TT,1)
cntr1   = arrayfun(@num2str,1:nboot,'UniformOutput',0);
cntr2   = repelem(cntr1',2);                                                % same counter for Target & Path
varsTP  = repelem({'targetbs','pathbs'},nboot,1);
varsTP  = reshape(varsTP',2*nboot,1);                                       % vertically alternate Target & Path
varsTP  = strcat(varsTP,cntr2);                                             % add numbers to names
TTbs    = array2timetable(fctrsbs,'RowTimes',TT.Date,'VariableNames',varsTP);