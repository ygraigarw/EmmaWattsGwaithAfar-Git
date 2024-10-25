function VlcSmm(Dat,Anl);
%function VlcSmm(Dat,Anl);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Standard plot for diagnosis of spline model

figure(1); clf;
[nR,nC]=pNmbSubPlt(Dat.p);

% Loop over variables
for iV=1:Dat.p;%Dat.p;
    
    subplot(nR,nC,iV); hold on;

    % Loop over models
    for iM=1:Dat.Mdl.nMdl;

        plot(iM,permute(Anl.RMSEP(iM,iV,:),[3 1 2]),'ko');

    end; % loop over iM, the model index

    plot(mean(permute(Anl.RMSEP(:,iV,:),[1 3 2]),2),'r-');
    
    title(sprintf('Variable %g (%s)',iV,pU2H(Dat.Lbl.Vrb{iV})));
    set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
    pDfl;pAxsLmt;
    
    if iV==11;
        xlabel('Model');
        ylabel('RMSEP');
    end;
    
end; %loop over iV, variables index

% Plot overall summary
subplot(nR,nC,Dat.p+1); hold on;
for iM=1:Dat.Mdl.nMdl;
    
    for iV=1:Dat.p;
        t(iV,:)=permute(Anl.RMSEP(iM,iV,:),[3 1 2])/std(Dat.X(:,iV),'omitnan');
    end;
    t2=mean(t);
    t3(iM)=mean(t2);
    
    plot(iM,t2,'ko');
    
end; % loop over iM, the model index

plot(t3,'r-');

title('Overall predictive performance');
xlabel('Model');
ylabel('Mean standardised RMSEP');
set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
pDfl;pAxsLmt;

pGI('Output/Anl_Smm1',2);

% Visualise one centre fits
% Loop over variables

for iM=1:Dat.Mdl.nMdl;
    
    figure(1); clf;
    [nR,nC]=pNmbSubPlt(Dat.p);
    
    for iV=1:Dat.p;%Dat.p;
        
        subplot(nR,nC,iV);hold on;
    
        t=[nanmin(Dat.X(:,iV)) nanmax(Dat.X(:,iV))];
        plot(t,t,'r-','linewidth',1);

        for iR=1:Anl.nRpl;
            
            t0=Anl.Prf(iM,iV,iR).Dgn;
            for j=1:size(t0,1);
                if size(t0{j},1)>0;
                    plot(t0{j}(:,2),t0{j}(:,3),'color',pClr(j),'marker','.','markersize',10,'linestyle','none');
                end;
            end;
        
        end;
        
        title(sprintf('Variable %g (%s)',iV,pU2H(Dat.Lbl.Vrb{iV})));
        pDfl;pAxsLmt;

    end; %loop over iV, variables index
    
    pGI(sprintf('Output/Anl_ObsPrd_Mdl_%g_%s',iM,Dat.Mdl.Nms{iM}),2);

end; % loop over iM, the model index    

return;