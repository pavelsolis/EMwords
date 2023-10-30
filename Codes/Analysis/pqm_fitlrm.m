function [beta,se,n,R2,R2adj,df] = pqm_fitlrm(varsX,vary)
% Fit a linear regression model
% 
% Assumptions:
% - varsX and vary can contain NaNs
% - size(varsX,1) = size(vary,1)
% - varsX does not include a constant
% - model always includes a constant
%%
T     = numel(vary);
Xy    = [ones(T,1) varsX vary];       	% add constant to the left
Xy(any(isnan(Xy),2),:) = [];          	% remove NaNs
X     = Xy(:,1:end-1);
y     = Xy(:,end);
[n,k] = size(X);
df    = n-k;
invXX = (X'*X)\eye(k);               	% compute inverse only once
beta  = invXX*(X'*y);
yhat  = X*beta;
eps   = y - yhat;
eps2  = eps'*eps;
sig2  = eps2/df;
Vcov  = invXX*sig2;
se    = sqrt(diag(Vcov));
ydiff = y - repmat(mean(y),n,1);
ydif2 = ydiff'*ydiff;
R2    = 1 - eps2/ydif2;
R2adj = 1 - sig2/(ydif2/(n-1));