function VclSmm_S(Dat,Anl);

% Modified version of VlcSmm to allow processing of linear regression models too

MdlTyp={'Spl';'LnR'};
ClrTyp={'r';'k'};

figure(1); clf;
[nR,nC]=pNmbSubPlt(Dat.p);

for iS=1:Anl.nS;
    
    % Loop over variables
    for iV=1:Dat.p;%Dat.p;
        
        subplot(nR,nC,iV); hold on;
        
        % Loop over models
        for iM=1:Dat.Mdl.nMdl;
            
            plot(iM,permute(Anl.RMSEP(iM,iV,:,iS),[3 1 2 4]),'o','color',ClrTyp{iS});
            
        end; % loop over iM, the model index
        
        plot(mean(permute(Anl.RMSEP(:,iV,:,iS),[1 3 2 4]),2),'-','color',ClrTyp{iS});
        
        title(sprintf('Variable %g (%s)',iV,pU2H(Dat.Lbl.Vrb{iV})));
        set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
        pDfl;pAxsLmt;
        
        if iV==11;
            xlabel('Model');
            ylabel('RMSEP (spline=r, linear=k)');
        end;
        
    end; %loop over iV, variables index
    
    
    % Plot overall summary
    subplot(nR,nC,Dat.p+1); hold on;

    % Only use some variables
    % 1 = "true", "if 1" => if true => do it
    % 0 = "false", "if 0" => if false => don't it
    if 1; % use all variables
        iUse=(1:Dat.p)';
    else; % use subset of variables
        iUse=[1 3 5 7 9 11 13]';
    end;
    
    for iM=1:Dat.Mdl.nMdl;
        
        for iV=1:Dat.p;
            t(iV,:)=permute(Anl.RMSEP(iM,iV,:,iS),[3 1 2])/std(Dat.X(:,iV),'omitnan');
        end;

        %t2=mean(t);
        t2=mean(t(iUse,:));
        
        t3(iM)=mean(t2);
        
        plot(iM,t2,'o','color',ClrTyp{iS});
        
    end; % loop over iM, the model index
    
    plot(t3,'-','color',ClrTyp{iS});
    
    title('Overall predictive performance');
    xlabel('Model');
    ylabel('Mean standardised RMSEP (spline=r, linear=k)');
    set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
    pDfl;pAxsLmt;
    
end;

% If Anl.ErrInd exists, change the name of the summary plot to indicate its value
if isfield(Anl,'ErrInd')==0;
    pGI('Output/Anl_Smm1',2);
else;
    pGI(sprintf('Output/Anl_Smm1_E%g',Anl.ErrInd));
end;

% Visualise one centre fits
% Loop over variables

for iS=1:Anl.nS;
    
    for iM=1:Dat.Mdl.nMdl;
        
        figure(1); clf;
        [nR,nC]=pNmbSubPlt(Dat.p);
        
        for iV=1:Dat.p;%Dat.p;
            
            subplot(nR,nC,iV);hold on;
            
            t=[nanmin(Dat.X(:,iV)) nanmax(Dat.X(:,iV))];
            plot(t,t,'r-','linewidth',1);
            
            for iR=1:Anl.nRpl;
                
                t0=Anl.Prf(iM,iV,iR,iS).Dgn;
                for j=1:size(t0,1);
                    if size(t0{j},1)>0;
                        plot(t0{j}(:,2),t0{j}(:,3),'color',pClr(j),'marker','.','markersize',10,'linestyle','none');
                    end;
                end;
                
            end;
            
            title(sprintf('Variable %g (%s)',iV,pU2H(Dat.Lbl.Vrb{iV})));
            pDfl;pAxsLmt;
            
        end; %loop over iV, variables index
        
        pGI(sprintf('Output/Anl_ObsPrd_Mdl_%s_%g_%s',MdlTyp{iS},iM,Dat.Mdl.Nms{iM}),2);
        
    end; % loop over iM, the model index
    
end;

return;