function [regcell,regtab] = pqm_regoutput(varsX,varsy,nmods,nocons,Rsqrd,setype,TTsf,nboot)
% Reports results from several regression models
% 
% nmods: number of models per variable (1->2 regressors, 2->1 & 2 regressors)
% nocons: boolean on whether to *report* the constant
% Rsqrd options: 'R2', 'R2adj'
% setype options: 'hac', 'boot'; otherwise ols
% TTsf: timetable with synthetic factors
% nboot: number of bootstrap iterations
%%
if nargin < 3; Rsqrd = 'R2';   end                                          % default is to report original R2
if nargin < 4; nocons = false; end                                          % default is to include the constant

T      = size(varsX,1);
regtab = nan( (size(varsX,2)+1)*2+2, size(varsy,2)*nmods );                 % indepvars+constant+se+obs+R2, # regressions per depvar
for k2 = 1:size(varsy,2)                                                    % dependent variables
    for k1 = (3-nmods):size(varsX,2)                                        % models per dependent variable
        % Coefficient estimates and residuals
        [beta,se,nobs,R2,R2adj] = pqm_fitlrm(varsX(:,1:k1),varsy(:,k2));
        yhat = [ones(T,1) varsX(:,1:k1)]*beta;                              % don't preserve NaNs
        resd = varsy(:,k2) - yhat;                                          % preserve NaNs
        
        % Standard errors
        if     strcmp(setype,'hac')
            [~,se] = hac(varsX(:,1:k1),varsy(:,k2),'Display','off');        % HAC robust standard errors using output by fitlm
        elseif strcmp(setype,'boot')
            betabs = nan(1+k1,nboot);                                       % constant + number of regressors
            for kbs = 1:nboot
                rng(kbs);                                                   % same seed as for synthetic factors
                yboot = yhat + resd(randi(T,T,1));                          % sample residuals with replacement
                Xboot = TTsf{:,2*kbs-1:2*kbs};                              % rotate synthetic factors per iteration
                betabs(:,kbs) = pqm_fitlrm(Xboot(:,1:k1),yboot);
            end
            betadiff = betabs - repmat(mean(betabs,2),1,nboot);
            Vcovboot = (betadiff*betadiff')/(nboot-1);
            se = sqrt(diag(Vcovboot));
        end
        
        % Save output
        rout = [beta se];
        rout = rout([2:end 1],:);                                           % move constant to the end
        if k1 == 1
            rout = [rout(1,:); nan(1,2); rout(2:end,:)];                    % add empty row if one regressor
        end
        rout = reshape(rout',numel(rout),1);                                % vertically alternate coefficient and se
        if strcmp(Rsqrd,'R2'); Rsqrd = R2; else; Rsqrd = R2adj; end
        if nmods == 1; cntr = k2; else; cntr = 2*k2-2+k1; end               % counter to store results appropriately
        regtab(:,cntr) = [rout; nobs; max(Rsqrd,0)];
    end
end
regcell = pqm_regtab2regcell(regtab,nocons);