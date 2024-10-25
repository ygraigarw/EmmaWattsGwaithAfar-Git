% Driver file for plotting existing results
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Script to make nice plots of output

load('Output\Anl_20240412T180803.mat'); %need to modify file name as appropriate
load('Dat.mat');

%iM=5; nCmp=5;
iM=3; nCmp=3;   % iM = the model, nCmp is the amount of rifts 1 = Sea Sea, 2 = MER, 3 = Aden
clf;
%Txt=sprintf('iR%giV%giM%giCmp%g',iR,iV,iM,iCmp);

Z=linspace(Anl.Bss.Zl,Anl.Bss.Zr,Anl.Bss.nZ)';

for iV=1:14;
    subplot(3,5,iV);hold on;
    for j=1:nCmp;
        plot(Z,Anl.Prf(iM,iV,1,1).Prd(j,:),'color',VlcClr(j));
        plot(Z,Anl.Prf(iM,iV,1,2).Prd(j,:),'color',VlcClr(j),'linestyle','--');
        plot(Dat.Mdl.C1D(j,1).Dst,Dat.X(Dat.Mdl.C1D(j,1).Ind==1,iV),'.','color',VlcClr(j))
    end;
    VlcAxsLmt;VlcDfl;
    set(gca,'xlim',[0 500]);
    %title(Txt);
end;

%% Create plots for stacking with all three rifts on - Delta7/4 plot
EmMarker = {'o','diamond','>','square'}
nCmp=3;
for iV=9;
    clf;hold on;
    for j=1:nCmp;
        %plot(Z,Anl.Prf(iM,iV,1,1).Prd(j,:),'color',eClr(j), 'LineWidth',1.5);
        %plot(Dat.Mdl.C1D(j,1).Dst,Dat.X(Dat.Mdl.C1D(j,1).Ind==1,iV),'LineStyle','none','marker', EmMarker(j),'MarkerFaceColor',eClr(j), 'MarkerEdgeColor','k')
        plot(Z,Anl.Prf(iM,iV,1,2).Prd(j,:),'color',VlcClr(j),'linestyle','--');
        plot(Dat.Mdl.C1D(j,1).Dst,Dat.X(Dat.Mdl.C1D(j,1).Ind==1,iV),'LineStyle','none','marker', EmMarker{j},'MarkerFaceColor',VlcClr(j), 'MarkerEdgeColor','k')
    end;
    %VlcAxsLmt;VlcDfl;
    set(gca,'FontSize',12,'box','on','linewidth',0.8);
    set(gca,'xlim',[0 500],'FontSize',12,'box','on','linewidth',1);
    grid on
    %title(Txt);
end;

%% Making the summary predictive performance plot 
if 1; %assumes both spline and linear regression results present
    figure
    for iM=1:Dat.Mdl.nMdl;
        
        for iV=1:Dat.p;
            t(iV,:)=permute(Anl.RMSEP(iM,iV,:),[3 1 2])/std(Dat.X(:,iV),'omitnan');
        end;
        t2=mean(t);
        t3s(iM)=mean(t2(:,1:Anl.nRpl)); %spline
        t3l(iM)=mean(t2(:,Anl.nRpl+1:2*Anl.nRpl)); %linear
        
        plot(iM,t2(:,1:Anl.nRpl),'o','MarkerFaceColor','#0072BD','MarkerEdgeColor','k','MarkerSize',10); %1:100 replicates of spline model
        hold on
        plot(iM,t2(:,Anl.nRpl+1:2*Anl.nRpl),'square','MarkerFaceColor','#A2142F','MarkerEdgeColor','k','MarkerSize',10); %101:200 is 100 replicates of linear model
    end; % loop over iM, the model index
    
    plot(t3s,'Linestyle','-', 'Color','#0072BD', LineWidth=1.5);
    plot(t3l,'Linestyle','-', 'Color','#A2142F',LineWidth=1.5);
    
    xlim([0 6]);
    ylim([0.5 1]);
    %title('Overall predictive performance');
    xlabel('Model','FontSize',16,'FontWeight','bold');
    ylabel('Mean standardised RMSEP','FontSize',16,'FontWeight','bold');
    set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
    grid on
end;