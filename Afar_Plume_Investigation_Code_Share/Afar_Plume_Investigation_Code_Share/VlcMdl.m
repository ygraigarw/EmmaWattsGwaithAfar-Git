function [RMSEP,Prf]=VlcMdl(iR,iV,iM,iS,CV,Dat,Anl);
%function [RMSEP,Prf]=VlcMdl(iR,iV,iM,iS,CV,Dat,Anl);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Estimate a statistical model for given input parameters 

Dgn=Anl.Dgn; %local version for neatness

MdlNam=Dat.Mdl.Nms{iM}; %name of the model 

nCmp=size(Dat.Mdl.(MdlNam),1); %number of different components to the chosen model

if Dgn==1;
    figure(1); clf;
    [nR,nC]=pNmbSubPlt(nCmp);
end;

tPrf=nan(nCmp,2);
tLmbOpt=nan(nCmp,1);
tPrd=nan(nCmp,Anl.Bss.nZ);
tDgn=cell(nCmp,1);
% Loop over the components
for iCmp=1:nCmp;
    
    % Set up the sample
    tY=Dat.X(Dat.Mdl.(MdlNam)(iCmp).Ind==1,iV);
    tX=Dat.Mdl.(MdlNam)(iCmp).Dst;
    tCV=CV(Dat.Mdl.(MdlNam)(iCmp).Ind==1);
    % Drop missing values
    tMss=isnan(tY);
    tX=tX(tMss==0);
    tY=tY(tMss==0);
    tCV=tCV(tMss==0);
    % Sort by increasing XIn
    [~,tOrd]=sort(tX);
    tX=tX(tOrd);
    tY=tY(tOrd);
    tCV=tCV(tOrd);
    tn=size(tY,1);
    Txt=sprintf('iR%giV%giM%giCmp%g',iR,iV,iM,iCmp);

    % Do the modelling
    if tn>=10; %only do full model if there are a reasonable number of observations 
        if iS==1;
            [tA,tB,tP,tZ]=VlcMakSpl(tX,Anl.Bss); %create a spline basis, and allocation observations to it
            [tRMSEPOpt,tLmbOpt(iCmp),~,~,tYh,tYFll]=VlcFitSpl(tY,tA,tB,tP,tCV,Anl.Lmb,Txt,Dgn); %evaluate the best spline model for the data
        else;
            Z=linspace(Anl.Bss.Zl,Anl.Bss.Zr,Anl.Bss.nZ)';
            [tRMSEPOpt,tYh,tYFll]=VlcFitLnrRgr(tY,tX,Z,tCV);
        end;
        tPrf(iCmp,:)=[tn*tRMSEPOpt.^2 tn]; %sum of squares error
        tZ=linspace(Anl.Bss.Zl,Anl.Bss.Zr,Anl.Bss.nZ)';
        tUse=tZ>=min(tX)-range(tX)/20 & tZ<=max(tX)+range(tX)/20;
        tPrd(iCmp,tUse)=tYFll(tUse)';
    elseif tn>0; %fit using a constant
        tYh=ones(tn,1)*mean(tY);
        tPrf(iCmp,:)=[sum((tY-tYh).^2) tn]; %sum of squares error
        tUse=tZ>=min(tX)-range(tX)/20 & tZ<=max(tX)+range(tX)/20;
        if sum(tUse)==0;
            tUse=tZ>=min(tX)-2*(Anl.Bss.Zr-Anl.Bss.Zl)/Anl.Bss.nZ & tZ<=max(tX)+2*(Anl.Bss.Zr-Anl.Bss.Zl)/Anl.Bss.nZ;            
        end;
        tPrd(iCmp,tUse)=ones(sum(tUse),1)*mean(tY);
    else;
        tYh=[];
        tPrf(iCmp,:)=[0 0]; %no error possible!
        tPrd(iCmp,:)=ones(size(tZ,1),1)*NaN;
    end;
    % Plots
    if Dgn==1;
        subplot(nR,nC,iCmp); hold on;
        if tn>0;
            plot(tX,tY,'bo');
            plot(tX,tYh,'r*');
            tUse=tZ>=min(tX)-range(tX)/20 & tZ<=max(tX)+range(tX)/20;
            plot(tZ(tUse),tYFll(tUse),'r-');
        end;
        title(Txt);
        pDfl;pAxsLmt;
    end;

    tDgn{iCmp}=[tX tY tYh];

end; %loop over iCmp, component index

RMSEP=sqrt(sum(tPrf(:,1))/sum(tPrf(:,2))); %overall RMSEP
Prf.RMSEP=RMSEP;
Prf.Prd=tPrd;
Prf.LmbOpt=tLmbOpt;
Prf.Dgn=tDgn;

if Dgn==1;
    Txt=sprintf('iR%giV%giM%g',iR,iV,iM);
    if iS==1;
        pGI(sprintf('Output/Spl_%s',Txt),2);
    else;
        pGI(sprintf('Output/LnR_%s',Txt),2);
    end;
end;

return;