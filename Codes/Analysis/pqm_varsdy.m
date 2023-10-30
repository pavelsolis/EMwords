function TTmb = pqm_varsdy(nboot)
%% Load dataset
load(fullfile('..','..','Data','Analytic','datasets.mat'),'TTmf','TTtg')
TTmb = TTmf;

%% Clean dataset and generate variables

% Rename variables
TTmb.Properties.VariableNames = lower(TTmb.Properties.VariableNames);
TTmb.Properties.DimensionNames{1} = 'date';
TTmb.Properties.VariableNames(ismember(TTmb.Properties.VariableNames,{'mpday_ttdm','target_tttg','path_tttg'})) = {'mpday','target11','path11'};

% Exclude emergency meetings & end sample in June 2023
TTmb.mpday(isnan(TTmb.mpday)) = 0;
xtrmtngs = {'27-Apr-2004','17-Feb-2016','20-Mar-2020','21-Apr-2020'};       % dates of extraordinary meetings
TTmb.mpday(ismember(datenum(TTmb.date),datenum(xtrmtngs)) | TTmb.date > datetime('30-Jun-2023')) = 0;

% Generate variables for analysis
TTmb.c4766y   = (TTmb.c4765y+TTmb.c4767y)/2;
TTmb.tedsprd  = (TTmb.us0003m - TTmb.usgg3m)*100;
TTmb.ticesprd = (TTmb.mxibtiie - TTmb.cetrg028)*100;

% Express flows in (MXN or UDI) billions
aux1 = TTmb{:,contains(TTmb.Properties.VariableNames,{'cts','bnd','udi'})}./1000;
TTmb(:,contains(TTmb.Properties.VariableNames,{'cts','bnd','udi'})) = array2table(aux1); % replace values

% Generate first differences
aux1 = TTmb{2:end,contains(TTmb.Properties.VariableNames,{'cts','bnd','udi','c476'})} - TTmb{1:end-1,contains(TTmb.Properties.VariableNames,{'cts','bnd','udi','c476'})};
aux2 = array2table([nan(1,size(aux1,2)); aux1],'VariableNames',strcat('d',TTmb.Properties.VariableNames(contains(TTmb.Properties.VariableNames,{'cts','bnd','udi','c476'}))));
TTmb = [TTmb aux2];                                                         % flows and daily yield changes

aux1 = (TTmb{2:end,endsWith(TTmb.Properties.VariableNames,{'yr_ttdy'})} - TTmb{1:end-1,endsWith(TTmb.Properties.VariableNames,{'yr_ttdy'})})*100;
aux2 = array2table([nan(1,size(aux1,2)); aux1],'VariableNames',strcat('d',TTmb.Properties.VariableNames(endsWith(TTmb.Properties.VariableNames,{'yr_ttdy'}))));
TTmb = [TTmb aux2];                                                         % in basis points

% Generate deflator
TTmb.deltay   = TTmb.dc4761y;
TTmb.mtyyrsul = round(TTmb.mtydys/365);                                     % average maturity as integer
yrs  = arrayfun(@num2str,TTmb.mtyyrsul(:),'UniformOutput',0);
dcyr = strcat('dc476',yrs,'y');
for yr = 2:8
    tempstr = ['dc476' num2str(yr) 'y'];
    TTmb.deltay(ismember(dcyr,tempstr)) = TTmb{ismember(dcyr,tempstr),ismember(TTmb.Properties.VariableNames,tempstr)};
end
TTmb.dfltr    = 1 - TTmb.deltay.*TTmb.mtyyrsul/100;
TTmb.deflator = 1 + TTmb.dprice/100;

% Adjust for valuation effects (bonos only)
aux1 = TTmb{:,startsWith(TTmb.Properties.VariableNames,'bnd')}./TTmb.deflator;
aux2 = array2table(aux1,'VariableNames',strcat('q',TTmb.Properties.VariableNames(startsWith(TTmb.Properties.VariableNames,'bnd'))));
TTmb = [TTmb aux2];                                                         % deflated value of holdings

aux1 = aux1(2:end,:) - aux1(1:end-1,:);
aux2 = array2table([nan(1,size(aux1,2)); aux1],'VariableNames',strcat('d',TTmb.Properties.VariableNames(startsWith(TTmb.Properties.VariableNames,'qbnd'))));
TTmb = [TTmb aux2];                                                         % flows

% Compute returns (in basis points)
TTmb.logusdmxn  = log(TTmb.usdmxn)*10000;                                   % so that change in basis points
TTmb.logmxmx    = log(TTmb.mxmx)*10000;
TTmb.logmexbol  = log(TTmb.mexbol)*10000;
TTmb.dlogusdmxn = [nan; (TTmb.logusdmxn(2:end) - TTmb.logusdmxn(1:end-1))];
TTmb.dlogmxmx   = [nan; (TTmb.logmxmx(2:end) - TTmb.logmxmx(1:end-1))];
TTmb.dlogmexbol = [nan; (TTmb.logmexbol(2:end) - TTmb.logmexbol(1:end-1))];

% Flows in logs and log changes not computed

%% Add the synthetic factors

date11 = datetime(2011,1,1);
date13 = datetime(2013,1,1);
datety = today('datetime');
TTbs   = pqm_factors_boot(TTtg,date11,datety,date13,nboot);
TTmb   = synchronize(TTmb,TTbs);

% Use zeros in non-MP days after 2011 for all factors
idx0mp = TTmb.mpday == 0 & TTmb.date >= datetime('1-Jan-2011');
[nrws,ncls] = size(TTmb(idx0mp,contains(TTmb.Properties.VariableNames,{'target11','path11','targetbs','pathbs'})));
TTmb(idx0mp,contains(TTmb.Properties.VariableNames,{'target11','path11','targetbs','pathbs'})) = array2table(zeros(nrws,ncls));