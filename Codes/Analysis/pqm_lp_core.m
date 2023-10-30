function lps = pqm_lp_core(vary,varsX,TTsf,idxMP,hrzntot,setype,nboot)
% Generate coefficient estimates and confidence bands over indicated horizon

alpha  = 0.05;                                                              % confidence level
prctls = round([(alpha/2)*(nboot+1) (1-alpha/2)*(nboot+1)],0);              % left and right percentiles
lps    = nan(4*2,hrzntot);                                                  % save coeffs, CIs & h=0 per surprise for all h
nMP    = sum(idxMP);
for h = 1:hrzntot                                                           % for each horizon
    % Coefficient estimates
    if h == 1
        varyfwd = vary;                                                     % equivalent to h = 0
    else
        varyfwd = [vary(h:end); nan(h-1,1)];
    end
    depvar = varyfwd;                                                       % change in basis points
    [beta,se,~,~,~,df] = pqm_fitlrm(varsX,depvar);
    lps(1,h) = beta(2);      lps(4,h) = beta(3);                            % estimates for Target & Path (beta(1) is the constant)
    yhat = [ones(size(varsX,1),1) varsX]*beta;                              % don't preserve NaNs
    resd = depvar - yhat;                                                   % preserve NaNs

    % Standard errors
    if     strcmp(setype,'hac')
        [~,se] = hac(varsX,depvar,'Display','off');                         % HAC robust standard errors using output by fitlm
    elseif strcmp(setype,'boot')
        betabs = nan(1+size(varsX,2),nboot);                                % constant + number of regressors
        for kbs = 1:nboot
            rng(kbs);                                                       % same seed as for synthetic factors
            yboot = depvar;
            resbt = resd(idxMP);
            yboot(idxMP) = yhat(idxMP) + resbt(randi(nMP,nMP,1));           % sample residuals with replacement
            Xboot = [TTsf{:,2*kbs-1:2*kbs} varsX(:,3:end)];                 % move to next couple of synthetic factors per iteration
            betabs(:,kbs) = pqm_fitlrm(Xboot,yboot);
        end
        betadiff = betabs - repmat(mean(betabs,2),1,nboot);
        Vcovboot = (betadiff*betadiff')/(nboot-1);
        se = sqrt(diag(Vcovboot));

        % Confidence intervals
        distrbT  = sort(betabs(2,:));  distrbP  = sort(betabs(3,:));        % sort bootstrap estimates for Target & Path
        lps(2,h) = distrbT(prctls(1)); lps(3,h) = distrbT(prctls(2));       % CIs for Target
        lps(5,h) = distrbP(prctls(1)); lps(6,h) = distrbP(prctls(2));       % CIs for Path
    end
    if ~strcmp(setype,'boot')                                               % either 'ols' or 'hac'
        c = tinv(1-alpha/2,df);
        lps(2,h) = beta(2) - c*se(2); lps(3,h) = beta(2) + c*se(2);         % CIs for Target
        lps(5,h) = beta(3) - c*se(3); lps(6,h) = beta(3) + c*se(3);         % CIs for Path
    end
    if h == 1                                                               % significant on-impact effects
        tstats = beta./se;
        pvals  = (1-tcdf(abs(tstats),repmat(df,size(tstats,1),1)))*2;       % p-values based on two-tailed test
        if pvals(2) < alpha; lps(7,h) = beta(2); end
        if pvals(3) < alpha; lps(8,h) = beta(3); end
    end
end