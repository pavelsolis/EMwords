function pqm_lp_flows(TTmb,TTsf,idxMP,horizon,setype,nboot)
%% Local projections: Flows (with structural break)

namecateg = strcat('Categ',{'1','2'});                                      % '3'
namevarsA = {{'Domestic','Foreigners'},{'Banks','Mutual','Pension','Others'}};% {'Insurers','Repos','Collateral'}
namegroup = {'Cetes','BonosVA','Udibonos'};                                 % 'Bonos'
namescrty = {'cts','qbnd','udi'};                                           % 'bnd'
namegpsfx = {{'pre','post'},{'pre','post'},{''}};
tgpintval = {{{'1-Jan-2011','14-Dec-2016'},{'15-Dec-2016','30-Jun-2023'}},...
            {{'1-Jan-2011','10-Feb-2021'},{'11-Feb-2021','30-Jun-2023'}},...
            {{'1-Jan-2011','30-Jun-2023'}}};
namesfctr = {'Target','Path'};
pathfigs  = fullfile('..','..','Docs','Figures','LPs');
hrzntot   = horizon + 1;

    % Regressions
for k3 = 1:numel(namecateg)                                                 % vars
    for k4 = 1:numel(namegroup)                                             % securities
        if strcmp(namescrty{k4},'udi')
            units = 'UDI   Billions';
        else
            units = 'MXN   Billions';
        end
        
        tintvals = tgpintval{k4};
        namesfx  = namegpsfx{k4};
        ntivals  = size(tintvals,2);
        for kk = 1:ntivals
            namesvars = strcat(namescrty{k4},lower(namevarsA{k3}));
            nvarsy    = size(namesvars,2);
            idxT      = isbetween(TTmb.date,tintvals{kk}{1},tintvals{kk}{2});
            varsy     = extractvars(namesvars,TTmb(idxT,:));
            lpsf      = nan(4*2,hrzntot,nvarsy);                                % save coeffs, CIs & h=0 per surprise for all h & vars

            for k1 = 1:nvarsy                                                   % for each variable
                vary      = varsy(:,k1);
                namesctrl = {namesvars{k1},'dlogusdmxn','h15t10y','vix','embi','wti','tedsprd','ticesprd','cds5y','dlogmexbol'};
                controls  = TTmb{:,ismember(TTmb.Properties.VariableNames,namesctrl)};
                controls  = [nan(1,size(controls,2)); controls(1:end-1,:)];     % controls are lagged 1 period
                varsX     = [TTmb.target11 TTmb.path11 controls];
                lpsf(:,:,k1) = pqm_lp_core(vary,varsX(idxT,:),TTsf(idxT,:),idxMP(idxT),hrzntot,setype,nboot);
            end     % var

                % Plots
            close all
            namesvars = namevarsA{k3};  if strcmp(namesvars(end),'Others'); namesvars{end} = 'Non-Financial'; end
            namesfile = strcat(namesfctr,'11',namegroup{k4},namecateg{k3},namesfx{kk});

            for k2 = 1:2                                                        % for each surprise
                if k2 == 1                                                      % rows in lps for target and path surprises
                    ibt = 1; ill = 2; iul = 3;
                else
                    ibt = 4; ill = 5; iul = 6;
                end
                ymin = min(lpsf(ill,:,:),[],"all");	ymax = max(lpsf(iul,:,:),[],"all");
                ymin = ymin*(1-0.05*sign(ymin));    ymax = ymax*(1+0.05*sign(ymax)); % add +/- 5% space to y-axis
                figure
                for k1 = 1:nvarsy                                               % for each variable
                    subplot(1,nvarsy,k1)
                    plot(0:horizon,lpsf(ibt,:,k1),'blue','LineWidth',1.5); hold on; plot(0:horizon,lpsf(ill:iul,:,k1),'k--'); hold on; yline(0);
                    title(namesvars(k1)); xlabel('Days'); xticks(0:horizon*0.5:horizon)
                    ax = gca;
                    xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.03)          % add +/- 3% of x-axis range to each side
                    box(ax,'off'); set(gcf,'color','w');                        % no box outline, white background color
                    ax.YLim = [ymin ymax];                                      % y limits using all variables
                    if k1 == 1                                                  % y label only for left-most figure
                        ylabel(units);
    %                     set(get(ax,'YLabel'),'Rotation',0,'Position',[.08*horizon max(ax.YLim)])  % horizontal label placed at the top
                    end
                    set(ax,'FontSize',9,'FontName','SansSerif');                % sets fontsize and font type per subplot
                end

                % Export figure to Latex
                set(gcf,'units','centimeters','position',[0,0,18,10]);          % [xini,yini,xsize,ysize]
                delete(fullfile(pathfigs,namesfctr{k2},namegroup{k4},[namesfile{k2} '.eps']));
                print(fullfile(pathfigs,namesfctr{k2},namegroup{k4},namesfile{k2}),'-depsc2');
                close
            end     % shock
        end     % pre/post
    end    % group
end     % categories