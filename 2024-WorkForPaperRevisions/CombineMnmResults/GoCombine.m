%% Intro
% Emma has run around 50 analyses with PERTURBED data, in order to see to what extent our inferences
% change
% Results from these 50 analyses are stored in large (66MB) MATLAB structures called Anl (ANaLysis)
% This code reads in the individual files and saves just the things we want for plotting (saving the
% whole lot would be huge)

%% Recap
% Anl.RMSEP is 5 x 14 x 100 x 2
% 5 models, 14 responses, 100 replicates of CV TTT and 2 model forms (1=spline,2=LnR)
% This is all we want to summarise model performance over 50 perturbations

%% Setup
clear; clc; clf;

%% Check to see the Output folder exists, and create it if it doesnt
if exist('Output','dir')==0;
    fprintf(1,'Creating Output directory\n');
    mkdir 'Output';
end;

%% Create or load Acc structure (ACCummulated results)
if 1; % Acc has not yet been created

    %% Define the folder where all your folders of results sit
    Drc='Mnm_Afar_Plume_outputs';
    % Check to see the folder exists
    if exist(Drc,'dir')==0;
        fprintf(1,'WARNING: File %s not present. Fix before continuing\n', Drc);
        mkdir 'Output';
    end;

    %% Load raw data
    if exist('Dat.mat','file')==0;
        fprintf(1,'WARNING: File Dat.mat not present. Fix before continuing\n');
        return;
    end;
    load Dat;

    %% Load analysis data files
    % Find all the folders you can use
    tFld=dir(Drc);
    tn=size(tFld,1);
    k=0;
    Fld=cell(tn-2,1);
    nFld=tn-2;
    for ti=3:tn; % Loop over the folder to find the subfolder names
        tNam=tFld(ti).name;
        if strcmp(tNam(1),'.')==0;
            k=k+1;
            Fld{k,1}=tNam;
        end;
    end;

    % Load all the data from the files in each folder
    k=0;
    Acc=[];
    for iF=1:nFld;
        tFil=dir(fullfile(Drc,Fld{iF}));
        tn=size(tFil,1);
        for ti=3:tn; % Loop over the files in the subfolder, and load them
            tNam=tFil(ti).name;
            k=k+1;
            fprintf(1,'Loading file %g\n',k);
            load(fullfile(Drc,Fld{iF},tNam));
            Acc=VlcAccRsl(Dat,Anl,Acc,k);
        end;
    end;

    % Add variables from any Anl structure needed for plotting
    Acc.nS=Anl.nS;
    Acc.Bss.Zl=Anl.Bss.Zl;
    Acc.Bss.Zr=Anl.Bss.Zr;
    Acc.Bss.nZ=Anl.Bss.nZ;

    save Acc Acc Dat; % Save Dat and Acc to Acc.mat for future use

else; % Acc already exists, so just load it

    load Acc; % Load Dat and Acc from previously saved Acc.mat

end;

%% Make figure for Acc.RMSEP
if 1;

    MdlTyp={'Spl';'LnR'};
    ClrTyp={'r';'k'};

    clf;
    [nR,nC]=pNmbSubPlt(Dat.p);

    for iS=1:Acc.nS;

        for iV=1:Dat.p+1;

            subplot(nR,nC,iV); hold on;

            plot(permute(Acc.RMSEP(iV,iS,:,:),[3 4 1 2])','-','color',ClrTyp{iS});

            title(sprintf('Variable %g (%s)',iV,pU2H(Dat.Lbl.Vrb{iV})));
            set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
            pDfl;pAxsLmt;

            if iV==11;
                xlabel('Model');
                ylabel('Mean RMSEP (spline=r, linear=k)');
            end;

            if iV==15;
                title('Overall predictive performance');
                xlabel('Model');
                ylabel('Standardised mean RMSEP (spline=r, linear=k)');
            end;

            set(gca,'xtick',(1:Dat.Mdl.nMdl),'xticklabel',Dat.Mdl.Nms);
            pDfl;pAxsLmt;

        end; %loop over iV, variables index

    end;

    pGI('Output/Acc_RMSEP');

end;

%% Make figure for C1D spline model
if 1;

    MdlTyp={'Spl';'LnR'};

    iS=1; % Spline model only

    clf;

    for iV=1:Dat.p;

        for iC=1:3;

            subplot(3,Dat.p,iV+Dat.p*(iC-1)); hold on;

            tx=linspace(Acc.Bss.Zl,Acc.Bss.Zr,Acc.Bss.nZ)';
            ty=permute(Acc.C1D(iV,iS,iC,:,:),[4 5 1 2 3])';
            plot(tx,ty,'r');

            if iC==1;
                title(sprintf('%g(%s) Cmp%g',iV,pU2H(Dat.Lbl.Vrb{iV}),iC));
            else;
                title(sprintf('Cmp%g',iC));
            end;
            pDfl;pAxsLmt;
            tLmtl=tx(find(isnan(mean(ty,2))==0,1,'first'));
            tLmtr=tx(find(isnan(mean(ty,2))==0,1,'last'));
            if tLmtr-tLmtl>200; % Only change the x-limits when the spline distance range is >200
                set(gca,'xlim',[tLmtl tLmtr]);
            end;

        end; %loop over iC, component index

    end; %loop over iV, variables index

    pGI('Output/Acc_C1D');

end;

return;