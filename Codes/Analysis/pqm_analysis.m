% Generate tables and local projections with bootstrapped standard errors
tic; clear; clc
nboot  = 10000;
setype = 'boot';                                                            % options: 'hac', 'boot'; otherwise ols
TTmb   = pqm_varsdy(nboot);
TTsf   = TTmb(:,contains(TTmb.Properties.VariableNames,{'targetbs','pathbs'}));
idxMP  = TTmb.mpday == 1 & TTmb.date >= datetime('1-Jan-2011');

%% Tables: Prices and flows
TTsfmp = TTsf(idxMP,:);
varsX  = [TTmb.target11(idxMP) TTmb.path11(idxMP)];
pqm_prices(TTmb,TTsfmp,idxMP,varsX,'R2',setype,nboot);
pqm_flowsdy(TTmb,TTsfmp,idxMP,varsX,'R2',setype,nboot);
fprintf('%s: Elapsed time at tables is %.2f minutes.\n',datestr(now),toc/60);

%% Local projections: FX & YC and flows
horizon = 30;                                                               % number of days
pqm_lp_fx(TTmb,TTsf,idxMP,horizon,setype,nboot);
fprintf('%s: Elapsed time at FX is %.2f minutes.\n',datestr(now),toc/60);
pqm_lp_yc(TTmb,TTsf,idxMP,horizon,setype,nboot);
fprintf('%s: Elapsed time at YC is %.2f minutes.\n',datestr(now),toc/60);
pqm_lp_flows(TTmb,TTsf,idxMP,horizon,setype,nboot);
fprintf('%s: Elapsed time at flows is %.2f minutes.\n',datestr(now),toc/60);