function pqm_prices(TTmb,TTsfmp,idxMP,varsX,Rsqrd,setype,nboot)
% Generate event study tables for prices
%%
% Table: FX and YC [pq_prices.do]
nmods     = 2; nocons = true; namect = {};
namesrows = [{' Target','','Path',''} namect {'Obs.','\(R^{2}\)'}];

nametex   = fullfile('..','..','Docs','Tables','f_fctrsfxyc');
namesvars = [{'usdmxn_tttg'} strcat('gmxn',{'02','05','10','30'},'yr_tttg')];
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
namescols = ['FX Returns' strcat('\(\Delta\)',{' '},{'2','5','10','30'},'Y Yield')];
namescols = strcat('\multicolumn{2}{c}{',namescols,'}');
midrules  = strcat('\cmidrule(lr){',{'2-3','4-5','6-7','8-9','10-11'},'}');
midrules  = {strjoin(midrules,''),'\midrule'};
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);

% Table: FX and YC before and after respective break dates [pq_prices.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrsfxycsb');
namesvars = [{'usdmxn_tttg'} strcat('gmxn',{'02','05','10','30'},'yr_tttg')];
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
namescols = ['FX Returns' strcat('\(\Delta\)',{' '},{'2','5','10','30'},'Y Yield')];
namescols = strcat('\multicolumn{2}{c}{',namescols,'}');
midrules  = strcat('\cmidrule(lr){',{'2-3','4-5','6-7','8-9','10-11'},'}');
midrules  = {strjoin(midrules,''),'\midrule'};
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);