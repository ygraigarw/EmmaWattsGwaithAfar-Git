function VlcSmmC1D_S(Dat,Anl);
%function VlcSmmC1D_S(Dat,Anl);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Modified version of VlcSmmC1D to allow processing of linear regression models too

MdlTyp={'Spl';'LnR'};

for iS=1:Anl.nS;
    
    % Loop over variables
    figure(1); clf;
    for iV=1:Dat.p;
        for iC=1:3;
            for iR=1:Anl.nRpl;
                tPrf=Anl.Prf(3,iV,iR,iS).Dgn{iC};
                subplot(3,Dat.p,iV+Dat.p*(iC-1)); hold on;
                if size(tPrf,1)>0 & iR==1;
                    plot(tPrf(:,1),tPrf(:,2),'k.');
                end;
                plot(linspace(Anl.Bss.Zl,Anl.Bss.Zr,Anl.Bss.nZ),Anl.Prf(3,iV,iR,iS).Prd(iC,:),'r')
            end;
            if iC==1;
                title(sprintf('%g(%s) Cmp%g',iV,VlcU2H(Dat.Lbl.Vrb{iV}),iC));
            else;
                title(sprintf('Cmp%g',iC));
            end;
            VlcDfl;VlcAxsLmt;
            if size(tPrf,1)>0;
                set(gca,'xlim',[min(tPrf(:,1))-range(tPrf(:,1))/20,max(tPrf(:,1))+range(tPrf(:,1))/20]);
            end;
        end; %loop over iC, component index
    end; %loop over iV, variables index
    
    VlcGI(sprintf('Output/Anl_C1D_%s',MdlTyp{iS}),2);
    
end;

return;