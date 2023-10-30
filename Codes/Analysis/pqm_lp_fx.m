function pqm_lp_fx(TTmb,TTsf,idxMP,horizon,setype,nboot)
%% Local projections: FX (with structural break)

namesfctr = {'Target','Path'};
pathfigs  = fullfile('..','..','Docs','Figures','LPs');
hrzntot   = horizon + 1;

tintvals = {{'1-Jan-2011','30-Oct-2014'},{'31-Oct-2014','30-Jun-2023'}};
namesfx  = {'pre','post'};
ntivals  = size(tintvals,2);
for kk = 1:ntivals
    namesvars = {'logusdmxn'};
    nvarsy    = size(namesvars,2);
    idxT      = isbetween(TTmb.date,tintvals{kk}{1},tintvals{kk}{2});
    varsy     = extractvars(namesvars,TTmb(idxT,:));
    lpsfx     = nan(4*2,hrzntot,nvarsy);                                    % save coeffs, CIs & h=0 per surprise for all h & vars

        % Regressions
    for k1 = 1:nvarsy                                                       % for each variable
        vary      = varsy(:,k1);
        namesctrl = {'logusdmxn','h15t10y','vix','embi','wti','tedsprd','ticesprd','cds5y','dlogmexbol'};
        controls  = TTmb{:,ismember(TTmb.Properties.VariableNames,namesctrl)};
        controls  = [nan(1,size(controls,2)); controls(1:end-1,:)];         % controls are lagged 1 period
        varsX     = [TTmb.target11 TTmb.path11 controls];
        lpsfx(:,:,k1) = pqm_lp_core(vary,varsX(idxT,:),TTsf(idxT,:),idxMP(idxT),hrzntot,setype,nboot);
    end

        % Plots
    close all
    namesfile = strcat(namesfctr,'11FX',namesfx{kk});
    for k2 = 1:2                                                            % for each surprise
        if k2 == 1                                                          % rows in lpsfx for target and path surprises
            ibt = 1; ill = 2; iul = 3;
        else
            ibt = 4; ill = 5; iul = 6;
        end
        ymin = min(lpsfx([2 5],:,:),[],"all");  ymax = max(lpsfx([3 6],:,:),[],"all");
        ymin = ymin*(1-0.05*sign(ymin));        ymax = ymax*(1+0.05*sign(ymax));% add +/- 5% space to y-axis
        figure
        for k1 = 1:nvarsy                                                   % for each variable
            subplot(1,nvarsy,k1)
            plot(0:horizon,lpsfx(ibt,:,k1),'blue','LineWidth',1.5); hold on; plot(0:horizon,lpsfx(ill:iul,:,k1),'k--'); hold on; yline(0);
            xlabel('Days'); xticks(0:horizon*0.5:horizon)
            ax = gca;
            xlim(ax, xlim(ax) + [-1,1]*range(xlim(ax)).* 0.03)              % add +/- 3% of x-axis range to each side
            box(ax,'off'); set(gcf,'color','w');                            % no box outline, white background color
            ax.YLim = [ymin ymax];                                          % y limits using all variables
            if k2 == 1                                                      % y label only for left-most figure
                ylabel('Basis Points');
    %             set(get(ax,'YLabel'),'Rotation',0,'Position',[.08*horizon max(ax.YLim)])% horizontal label placed at the top
            end
            set(ax,'FontSize',9,'FontName','SansSerif');                    % sets fontsize and font type per subplot
        end

        % Export figure to Latex
        set(gcf,'units','centimeters','position',[0,0,18,10]);              % [xini,yini,xsize,ysize]
        delete(fullfile(pathfigs,namesfctr{k2},[namesfile{k2}  '.eps']));
        print(fullfile(pathfigs,namesfctr{k2},namesfile{k2}),'-depsc2');
        close
    end
end