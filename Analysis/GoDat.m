clear all; clc; clf;
colormap('jet');

if 0;
    % load raw data
    [N,T]=xlsread('../Data/EAVS_data_plume_indicators_22_12_16.xlsx');
    
    % get variables names
    KepVrb=[3:4 6:17]';
    VrbNms=T(1,KepVrb)'; %first row is variable names
    VrbNms=pU2H(VrbNms); %get rid of underscores
    
    % get numeric data
    X=N(:,KepVrb-2);
    
    % get volcano ids (just in case)
    [VlcNms,VlcIdn]=unique(T(:,5));
    
    % put in structure
    D.Raw.X=X;
    D.Raw.Nms=VrbNms;
    D.Raw.n=size(X,1);
    D.Raw.p=size(X,2);
    D.Raw.Idn=(1:D.Raw.n)';
    D.Vlc.Nms=VlcNms;
    D.Vlc.Idn=VlcIdn;
    
    % drop observations - discussed with Emma
    % drop 189
    % deep 101, 226, 234 for the moment
    D.Dat=D.Raw;
    [D.Dat.Idn,Idn]=setdiff(D.Raw.Idn,[189]);
    D.Dat.X=D.Raw.X(Idn,:);
    D.Dat.n=size(D.Dat.X,1);
    
    % centre points for 1 and 3 bullseye models
    D.LL.Lak=[41.7837506 11.1921697];
    D.LL.NW=[39.8497434	14.9822459];
    D.LL.SW=[37.4455346	5.7791835];
    D.LL.BE=[ 40.458366 14.0081304; 41.0099595 10.8719263;37.9484619 6.6261688];
    
    % distances from lake (1BE model) and from 3 volcano centres (3BE model)
    for i=1:D.Dat.n;
        D.Dat.Dst.Lak(i,1)=pSphDst(D.Dat.X(i,1),D.Dat.X(i,2),D.LL.Lak(1),D.LL.Lak(2))*1e-3;
        D.Dat.Dst.Lak(i,2)=D.Dat.X(i,2)>D.LL.Lak(2); %defines "north region"
        for j=1:3;
            D.Dat.Dst.BE(i,j)=pSphDst(D.Dat.X(i,1),D.Dat.X(i,2),D.LL.BE(j,1),D.LL.BE(j,2))*1e-3;
        end;
    end;
    
    D.Rgr.Trn=[0;0;-1;-1;-1;-1;-1;+1;-1;-1;-1;+1;+1;+1];
    
    save Dat D;
else;
    load Dat;
end;

if 0; % plot: raw data
    clf;
    for j=1:D.Dat.p;
        subplot(3,5,j);
        plot(D.Dat.X(:,j),'k');
        title(D.Dat.Nms{j});
    end;
    pDatStm('Raw data');
    pGI('RawData',2);
end;

if 0; % plot: scatter
    clf;
    plotmatrix(D.Dat.X);
    pDatStm('Scatter matrix');
    pGI('ScatterMatrix',2);
end;

if 0; % plot: long-lat
    clf; hold on;
    plot(D.Dat.X(:,1),D.Dat.X(:,2),'ko');
    plot(D.LL.Lak(:,1),D.LL.Lak(:,2),'r*','markersize',10);
    plot(D.LL.NW(:,1),D.LL.NW(:,2),'r*','markersize',10);
    plot(D.LL.SW(:,1),D.LL.SW(:,2),'r*','markersize',10);
    for j=1:3;
        plot(D.LL.BE(j,1),D.LL.BE(j,2),'b*','markersize',10);
    end;
    pDatStm('Locations');
    pGI('Locations',2);
end;

if 0; % plot: measurements with distance from lake north and south
    clf; hold on;
    t=D.Dat.Dst.Lak(:,2)==1; %north
    k=0;
    for j=1:12;
        k=k+1;
        subplot(4,6,k)
        plot(D.Dat.Dst.Lak(t,1),D.Dat.X(t,j+2),'ko');
        title(D.Dat.Nms{j+2});
    end;
    t=D.Dat.Dst.Lak(:,2)==0; %south
    for j=1:12;
        k=k+1;
        subplot(4,6,k)
        plot(D.Dat.Dst.Lak(t,1),D.Dat.X(t,j+2),'k*');
        title(D.Dat.Nms{j+2});
    end;
    pDatStm('Values with distance from lake: north (o), south (*)');
    pGI('EffectOfDistanceFromLake',2);
end;

if 0; % plot: measurements with distance from bullseyes north and south
    clf; hold on;
    t=D.Dat.Dst.Lak(:,2)==1; %north
    k=0;
    for jj=1:2;
        for j=1:12;
            k=k+1;
            subplot(8,6,k)
            plot(D.Dat.Dst.BE(t,jj),D.Dat.X(t,j+2),'o','color',pClr(jj));
            title(D.Dat.Nms{j+2});
        end;
    end;
    t=D.Dat.Dst.Lak(:,2)==0; %south
    for jj=2:3;
        for j=1:12;
            k=k+1;
            subplot(8,6,k)
            plot(D.Dat.Dst.BE(t,jj),D.Dat.X(t,j+2),'*','color',pClr(jj));
            title(D.Dat.Nms{j+2});
        end;
    end;
    pDatStm('Values with distance from bullseyes (NW=1=r, E=2=m, SW=3=g): north (o), south (*)');
    pGI('EffectOfDistanceFromBullseyes',2);
end;

% functional forms
% - starting vand end values are known for plume, but confounded by crust
% Down with distance: Pb64, 74, 84, delta74, 84, Sr86-87, Ce-Pb, deltaNb,
% Up with distance: Nd143-144, Vs-40, 80, 120

if 1; % fit one plume model
    clf;
    k=0; %counter for plots
    for iR=1:2;
        
        % specify rift
        if iR==1;
            RgnIdn=D.Dat.Dst.Lak(:,2)==1; %north
        else;
            RgnIdn=D.Dat.Dst.Lak(:,2)==0; %south
        end;
        
        for j=1:12; % loop over variables
            
            tRsp=D.Dat.X(RgnIdn,j+2);
            tDst=D.Dat.Dst.Lak(RgnIdn,1);
            tKep=~isnan(tRsp);
            tRsp=tRsp(tKep);
            tX=[ones(sum(tKep),1) tDst(tKep)];
            
            tb=tX\tRsp; %linear regression
            
            % handle the situation that fitted trend is in wrong direction
            if tb(2)*D.Rgr.Trn(j+2)<0;
                tb(2)=0;
                tb(1)=mean(tRsp);
            end;
            
            k=k+1;
            subplot(4,6,k); hold on;
            plot(D.Dat.Dst.Lak(RgnIdn,1),D.Dat.X(RgnIdn,j+2),'ko');
            plot([min(D.Dat.Dst.Lak(RgnIdn,1)) max(D.Dat.Dst.Lak(RgnIdn,1))]',tb(1)+[0 max(D.Dat.Dst.Lak(RgnIdn,1))]*tb(2),'k');
            title(D.Dat.Nms{j+2});
            
            tRsd=tRsp-tX*tb;
            tCnt=tRsp-mean(tRsp);
            D.Rgr.BE1.LOF(j,iR)=(tRsd'*tRsd)/(tCnt'*tCnt);
            D.Rgr.BE1.StnPrmEst(j,iR,:)=tb/std(tCnt);
            
        end;
        
    end;
    D.Rgr.BE1.OLOF=sum(D.Rgr.BE1.LOF(:))/24;
    pDatStm('Fit one plume. North is top two rows');
    pGI('FitOnePlume',2);
end;

if 1; % fit three plume model
    clf;
    k=0; %counter for plots
    for iR=1:2;
        
        % specify rift
        if iR==1;
            RgnIdn=D.Dat.Dst.Lak(:,2)==1; %north
        else;
            RgnIdn=D.Dat.Dst.Lak(:,2)==0; %south
        end;
        
        for j=1:12; % loop over variables
            
            tRsp=D.Dat.X(RgnIdn,j+2);
            if iR==1;
                tDst=D.Dat.Dst.BE(RgnIdn,1:2);
            else;
                tDst=D.Dat.Dst.BE(RgnIdn,2:3);
            end;
            tKep=~isnan(tRsp);
            tRsp=tRsp(tKep);
            tX=[ones(sum(tKep),1) tDst(tKep,:)];
            
            tb=tX\tRsp; %linear regression
            
            % handle the situation that fitted trend is in wrong direction
            if tb(2)*D.Rgr.Trn(j+2)<0 && tb(3)*D.Rgr.Trn(j+2)<0;
                tb(2:3)=0;
                tb(1)=mean(tRsp);
            elseif tb(3)*D.Rgr.Trn(j+2)<0;
                tb(3)=0;
                tX2=tX(:,[1 2]);
                tb2=tX2\tRsp;
                if tb2(2)*D.Rgr.Trn(j+2)<0;
                    tb(2)=0;
                    tb(1)=mean(tRsp);
                else;
                    tb(1)=tb2(1);
                    tb(2)=tb2(2);
                end;
            elseif tb(2)*D.Rgr.Trn(j+2)<0;
                tb(2)=0;
                tX2=tX(:,[1 3]);
                tb2=tX2\tRsp;
                if tb2(2)*D.Rgr.Trn(j+2)<0;
                    tb(3)=0;
                    tb(1)=mean(tRsp);
                else;
                    tb(1)=tb2(1);
                    tb(3)=tb2(2);
                end;
            end;
            
            k=k+1;
            subplot(4,6,k); hold on;
            plot(tRsp,tX*tb,'o');
            
            tRsd=tRsp-tX*tb;
            tCnt=tRsp-mean(tRsp);
            D.Rgr.BE3.LOF(j,iR)=(tRsd'*tRsd)/(tCnt'*tCnt);
            D.Rgr.BE3.StnPrmEst(j,iR,:)=tb/std(tCnt);
            
        end;
        
    end;
    D.Rgr.BE3.OLOF=sum(D.Rgr.BE3.LOF(:))/24;
    pDatStm('Fit three plume. North is top two rows');
    pGI('FitThreePlume',2);
end;

if 1; % compare lack of fit over variables
    
    clf; hold on;
    iR=1;
    plot(D.Rgr.BE1.LOF(:,iR),'r');
    plot(D.Rgr.BE3.LOF(:,iR),'b');
    iR=2;
    plot(D.Rgr.BE1.LOF(:,iR),'r--');
    plot(D.Rgr.BE3.LOF(:,iR),'b--');
    set(gca,'xtick',(1:12)','xticklabels',D.Dat.Nms(3:end));
    pDfl;
    
    pDatStm('Compare plume fits. Small is good. North=solid, South=dash. BE1=r, BE3=b. ');
    pGI('ComparePlumeFits',2);
    
end;

if 1; % run bootstrap analyses for both models
    
    BE1BotStr;
    BE3BotStr;
    [D.Rgr.BS.BE1.OLOF D.Rgr.BS.BE3.OLOF]
    
end;

if 1; % plot regression slopes from different models
    clf; hold on;
    for iR=1:2; % regions
        if iR==1;
            plot(D.Rgr.BE1.StnPrmEst(:,iR,2),'-','color','r');
        else;
            plot(D.Rgr.BE1.StnPrmEst(:,iR,2),'--','color','r');
        end;            
    end;
end;

if 1; % plot regression slopes from different models
    clf; hold on;
    subplot(2,1,1); hold on; title 'One plume model';
    for iR=1:2; % regions
        if iR==1;
            plot(D.Rgr.BE1.StnPrmEst(:,iR,2),'-','color','r');
        else;
            plot(D.Rgr.BE1.StnPrmEst(:,iR,2),'--','color','r');
        end;            
    end;
    ylabel 'Change in standardised response per km';
    set(gca,'xtick',(1:12)','xticklabels',D.Dat.Nms(3:end));
    set(gca,'ylim',[-0.02 +0.03]); %set same scale on both subplots to emphasise difference
    pDfl;
   
    subplot(2,1,2); hold on; title 'Three plume model';
    for iR=1:2; % regions
        if iR==1;
            plot(D.Rgr.BE3.StnPrmEst(:,iR,2),'-','color','r');
            plot(D.Rgr.BE3.StnPrmEst(:,iR,3),'-','color','g');
        else;
            plot(D.Rgr.BE3.StnPrmEst(:,iR,2),'--','color','g');
            plot(D.Rgr.BE3.StnPrmEst(:,iR,3),'--','color','b');
        end;            
    end;
    ylabel 'Change in standardised response per km';
    set(gca,'xtick',(1:12)','xticklabels',D.Dat.Nms(3:end));
    set(gca,'ylim',[-0.02 +0.03]); %set same scale on both subplots to emphasise difference
    pDfl;
    pDatStm('BE3 standardised parameter estimates. Plume1North=r, Plume2North=Solidg, Plume2South=Dashedg, Plume3South=Dashedb');
    pGI('PlumeModelStandardisedParameterEstimates',2);
end;










