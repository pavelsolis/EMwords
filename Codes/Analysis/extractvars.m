function vars = extractvars(varnames,TTmb)
% Create vars vector with variables in specified order
nvars = numel(varnames);
vars  = nan(size(TTmb,1),nvars);
for kk = 1:nvars
    vars(:,kk) = TTmb{:,ismember(TTmb.Properties.VariableNames,varnames(kk))};
end