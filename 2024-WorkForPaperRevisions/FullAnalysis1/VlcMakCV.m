function CV=VlcMakCV(I,nCV,Dgn);

% Use the integer-values indicator variable I (with max value mI) to create a cross-validation partition with nCV subsets, individually 
% for each value of I (corresponding to different subgroups G or the data)

n=size(I,1); %number of observations (this should be 290)
nGrp=max(I); %number of groups in I (this should be 4)
CV=nan(n,1); %output vector

% Loop over subgroups G
for iG=1:nGrp;
    
    Lct=I==iG; %locations of group iG in I
    nLct=sum(Lct,1); %count how many there are
    CV(Lct)=pMakCV(nLct,nCV); %allocate these to CV (using pMakCV)
    
end; %loop over iG, group index

if Dgn==1;
    figure(1); clf; 
    [nR,nC]=pNmbSubPlt(nGrp);
    for iG=1:nGrp;
        subplot(nR,nC,iG); hold on;
        if iG==1; 
            title('Proportion of observations in each cross-validation group. Group 1');
        else;
            title(sprintf('Group %g',iG));            
        end;
        Lct=I==iG; %locations of group iG in I
        plot(sum(CV(Lct)==1:nCV)/sum(Lct),'color',pClr(iG),'marker','o');
        pDfl; pAxsLmt;
    end;
    tStr=sprintf('Dgn_MakCV_%s',datestr(now,30));
    pGI(fullfile('Output',tStr),2);
end;

return;