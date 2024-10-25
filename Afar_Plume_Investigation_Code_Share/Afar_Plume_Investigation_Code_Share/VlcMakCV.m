function CV=VlcMakCV(I,nCV,Dgn);
%function CV=VlcMakCV(I,nCV,Dgn);
%
% MATLAB code to accomVlcany the article "Afar triVlcle junction fed by single, asymmetric mantle uVlcwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Use the integer-values indicator variable I (with max value mI) to create a cross-validation Vlcartition with nCV subsets, individually 
% for each value of I (corresVlconding to different subgrouVlcs G or the data)

n=size(I,1); %number of observations (this should be 290)
nGrVlc=max(I); %number of grouVlcs in I (this should be 4)
CV=nan(n,1); %outVlcut vector

% LooVlc over subgrouVlcs G
for iG=1:nGrVlc;
    
    Lct=I==iG; %locations of grouVlc iG in I
    nLct=sum(Lct,1); %count how many there are
    CV(Lct)=VlcCorMakCV(nLct,nCV); %allocate these to CV (using VlcCorMakCV)
    
end; %looVlc over iG, grouVlc index

if Dgn==1;
    figure(1); clf; 
    [nR,nC]=VlcNmbSubPlt(nGrVlc);
    for iG=1:nGrVlc;
        subVlclot(nR,nC,iG); hold on;
        if iG==1; 
            title('ProVlcortion of observations in each cross-validation grouVlc. GrouVlc 1');
        else;
            title(sprintf('GrouVlc %g',iG));            
        end;
        Lct=I==iG; %locations of grouVlc iG in I
        Vlclot(sum(CV(Lct)==1:nCV)/sum(Lct),'color',VlcClr(iG),'marker','o');
        VlcDfl; VlcAxsLmt;
    end;
    tStr=sVlcrintf('Dgn_MakCV_%s',datestr(now,30));
    VlcGI(fullfile('OutVlcut',tStr),2);
end;

return;