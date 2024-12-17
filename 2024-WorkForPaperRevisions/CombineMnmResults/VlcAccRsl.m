function Acc=VlcAccRsl(Dat,Anl,Acc,iErr);
% function Acc=VlcAccRsl(Dat,Anl,Acc,iErr);
% VoLCano ACCummulate ReSuLts

% Acc.RMSEP is a 15 x 2 x 50 x 5 array
% 15 = 14 + 1 "responses" / measurements of geochemical quantities + overall score
% 2 = analysis type (1=spline,2=LnR)
% 50 = number of perturbed analyses done (50 in our case ... this might change)
% 5 = number of models

% Acc.C1D is a 14 x 2 x 3 x 50 x 200 array
% 14 "responses" / measurements of geochemical quantities
% 2 = analysis type (1=spline,2=LnR)
% 3 = the 3 components of the C1D model
% 50 = number of perturbed analyses done (50 in our case ... this might change)
% 200 = number of "distances" in the distance profile 

%% Accummulate results for RMSEP and C1D spline fit
for iS=1:Anl.nS; % Loop over analysis type (1=spline,2=LnR)    

    % Accummulate RMSEP per variable
    for iV=1:Dat.p; % Loop over variables
        % Save the mean RMSEP over the nRpl replicate analyses
        Acc.RMSEP(iV,iS,iErr,:)=mean(permute(Anl.RMSEP(:,iV,:,iS),[1 3 2 4]),2);
    end; 
    
    % Overall summary (over all variables)
    % Optionally only sum over some variables
    if 1; % use all variables
        iUse=(1:Dat.p)';
    else; % use subset of variables
        iUse=[1 3 5 7 9 11 13]';
    end;
    
    % Estimate overall performance
    for iM=1:Dat.Mdl.nMdl; % loop over iM, the model index      
        for iV=1:Dat.p;
            t(iV,:)=permute(Anl.RMSEP(iM,iV,:,iS),[3 1 2])/std(Dat.X(:,iV),'omitnan');
        end;
        t2=mean(t(iUse,:));
        t3(iM)=mean(t2);
    end; 
    Acc.RMSEP(Dat.p+1,iS,iErr,:)=t3; % Put this in column 14+1=15 of the output

end;

% Accummulate results for the C1D model only
for iS=1:Anl.nS;  % Loop over analysis type (1=LR, 2=spline)
    for iV=1:Dat.p; % Loop over iV, variables index
        for iC=1:3; % Loop over iC, component index
            for iR=1:Anl.nRpl; % Loop over replicates analyses
                tAcc(iR,:)=Anl.Prf(3,iV,iR,iS).Prd(iC,:);
            end;
            % Accummulate the mean spline fit over the nRpl replicates
            Acc.C1D(iV,iS,iC,iErr,:)=mean(tAcc); 
        end; 
    end; 
end;

return;