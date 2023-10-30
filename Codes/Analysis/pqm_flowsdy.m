function pqm_flowsdy(TTmb,TTsfmp,idxMP,varsX,Rsqrd,setype,nboot)
% Generate event study tables for flows
%%
nmods     = 1; nocons = true; namect = {};
namesrows = [{' Target','','Path',''} namect {'Obs.','\(R^{2}\)'}];
namescols = {'Banks','Mutual','Pension','Insurers','Others','Repos','Collateral','Foreigners'};

% Table: Flows to Cetes (event study) [pq_flowsdy.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrsctsid');
namesvars = strcat('dcts',lower(namescols));
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
midrules  = strcat('\cmidrule(lr){',{'2-2','3-3','4-4','5-5','6-6','7-7','8-8','9-9'},'}');
midrules  = {strjoin(midrules,''),'\midrule'};
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);


% Table: Flows to Bonos (event study, with valuation adjustment) [pq_flowsdy.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrsbndidva');
namesvars = strcat('dqbnd',lower(namescols));
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);


% Table: Flows to Bonos (event study, no valuation adjustment) [pq_flowsdy.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrsbndidnova');
namesvars = strcat('dbnd',lower(namescols));
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);


% Table: Flows to Udibonos (event study) [pq_flowsdy.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrsudiid');
namesvars = strcat('dudi',lower(namescols));
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);


% Table: Total holdings of Cetes and Bonos (event study, with valuation adjustment) [pq_flowsdy.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrstotidva');
namesvars = {'dctstotal','dqbndtotal'};
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
namescols = {'Cetes','Bonos'};
midrules  = strcat('\cmidrule(lr){',{'2-2','3-3'},'}');
midrules  = {strjoin(midrules,''),'\midrule'};
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);


% Table: Total holdings of Cetes, Bonos and Udibonos (event study, no valuation adjustment) [pq_flowsdy.do]
nametex   = fullfile('..','..','Docs','Tables','f_fctrstotidnova');
namesvars = {'dctstotal','dbndtotal','duditotal'};
varsy     = extractvars(namesvars,TTmb(idxMP,:));
regcell   = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsfmp,nboot);
namescols = {'Cetes','Bonos','Udibonos'};
midrules  = strcat('\cmidrule(lr){',{'2-2','3-3','4-4'},'}');
midrules  = {strjoin(midrules,''),'\midrule'};
pqm_regcell2latex(regcell,namesrows,namescols,midrules,nametex);