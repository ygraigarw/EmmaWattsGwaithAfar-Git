function Dat=VlcGetDat(FilNam,Dgn);
%function VlcSmmC1D(Dat,Anl);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Application data-specific function to extract data into desired format for modelling

% Centre points for 1 and 3 centre models
Dat.C1.LngLtt=[41.7837506 11.1921697]; %the lake
Dat.C3.LngLtt=[40.458366 14.0081304; 37.9484619 6.6261688;41.7837506 11.1921697; ]; %(1)NW (2)SW (3)lake in that order

if exist(FilNam,'file')==2;
    [N,T]=xlsread(FilNam); %read data
else;
    fprintf(1,'Cant find the xlsx file\n');
    return;
end;
Dat.Lbl.Obs=T(2:end,1); %observation names
Dat.Lbl.Vrb=T(1,6:end)'; %variable names
Dat.Lbl.Vrb(9)={'LaOverSm'}; %this name has a weird character, so use something else
Dat.LngLtt=N(:,2:3); %longitude and latitude of each observation

% Eliminate rift 4, allocate it all to rift 1 and 2
Dat.RftInd=N(:,1); %rift index
Dat.RftInd(Dat.RftInd==4 & Dat.LngLtt(:,2)>Dat.C1.LngLtt(2))=1; 
Dat.RftInd(Dat.RftInd==4 & Dat.LngLtt(:,2)<=Dat.C1.LngLtt(2))=2; 

% Don't need distances to lake N(:,4) because we're going to calculate them, but use as a check
Dat.X=N(:,5:end); %data matrix, basically the core of our analysis
[Dat.n,Dat.p]=size(Dat.X); %size of input matrix (this should be 290 x 14)

% Calculate distances from the lake, and from the three centres
Dat.Dst.C1=nan(Dat.n,1); %distance to the "one plume" centre
Dat.Dst.C3=nan(Dat.n,3); %distance to the "three plume" centre
for i=1:Dat.n;
    Dat.Dst.C1(i,1)=VlcSphDst(Dat.LngLtt(i,1),Dat.LngLtt(i,2),Dat.C1.LngLtt(1),Dat.C1.LngLtt(2))*1e-3; %spherical distance in km
    for j=1:3;
        Dat.Dst.C3(i,j)=VlcSphDst(Dat.LngLtt(i,1),Dat.LngLtt(i,2),Dat.C3.LngLtt(j,1),Dat.C3.LngLtt(j,2))*1e-3;
    end;
end;

% Allocate observations to plumes
Dat.PlmInd=nan(Dat.n,1);
Dat.PlmInd(Dat.RftInd==3)=3; %all rift 3 observations are associated with the "lake" plume
Dat.PlmInd(Dat.RftInd==4)=3; %all rift 4 observations are associated with the "lake" plume
t=find(Dat.RftInd==1|Dat.RftInd==2);
tMnmDst=min(Dat.Dst.C3(t,:),[],2);
tPlmInd=nan(size(t,1),1);
for j=1:3;
    tPlmInd(Dat.Dst.C3(t,j)==tMnmDst)=j;
end;
Dat.PlmInd(t)=tPlmInd';

% Calculate the numbers of observation per combination of plume and rift
for j=1:3;
    for k=1:3;
        Dat.C3.n(j,k)=sum(Dat.PlmInd==j & Dat.RftInd==k);
    end;
end;

% Construct data sets for all the analyses needed
Dat.Mdl.Nms={'C1C';'C3C';'C1D';'C3D';'C3X'};
Dat.Mdl.nMdl=size(Dat.Mdl.Nms,1); %number of model types
Dat.Mdl.nSbm=2; %Two SuBModels (1)=linear trend, (2)=penalised B-spline. This is a given.

% Dat.Mdl.C1C : 1 plume centre, common S(d)
Dat.Mdl.C1C.Dst=Dat.Dst.C1; %use distance from C1 for all rifts
Dat.Mdl.C1C.Ind=ones(Dat.n,1);
Dat.Mdl.C1C.n=Dat.n;

% Dat.Mdl.C3C : 3 plume centres, common S(d)
for i=1:Dat.n
    Dat.Mdl.C3C.Dst(i,1)=Dat.Dst.C3(i,Dat.PlmInd(i));
end;
Dat.Mdl.C3C.Ind=ones(Dat.n,1);
Dat.Mdl.C3C.n=Dat.n;

% Dat.Mdl.C1D : 1 plume centre, different S(d) for each Rft
for j=1:3; %loop over rift
    t=Dat.RftInd==j;
    Dat.Mdl.C1D(j,1).Dst=Dat.Dst.C1(t);
    Dat.Mdl.C1D(j,1).Ind=t;
    Dat.Mdl.C1D(j,1).n=sum(t);
end;

% Dat.Mdl.C3D : 3 plume centres, different S(d) for each Rft
for j=1:3; %loop over rift
    t=Dat.RftInd==j;
    tDstC3=Dat.Dst.C3(t,:);
    tPlmInd=Dat.PlmInd(t);
    tn=sum(t);
    for i=1:tn;
        Dat.Mdl.C3D(j,1).Dst(i,1)=tDstC3(i,tPlmInd(i));
    end;
    Dat.Mdl.C3D(j,1).Ind=t;
    Dat.Mdl.C3D(j,1).n=sum(t);
end;

% Dat.Mdl.C3X : 3 plume centres, different S(d) for each combination of Plm and Rft
kk=0;
for k=1:3; %loop over plume
    for j=1:3; %loop over rift
        t=Dat.PlmInd==k & Dat.RftInd==j;
        if sum(t)>0;
            kk=kk+1;
            tDstC3=Dat.Dst.C3(t,:);
            tPlmInd=Dat.PlmInd(t);
            tn=sum(t);
            for i=1:tn;
                Dat.Mdl.C3X(kk,1).Dst(i,1)=tDstC3(i,tPlmInd(i));
            end;
            Dat.Mdl.C3X(kk,1).Ind=t;
            Dat.Mdl.C3X(kk,1).n=sum(t);
            %Dat.PlmRft is necessary to set up the cross-validation cleverly
            Dat.PlmRft.Ind(t,1)=kk;
            Dat.PlmRft.Cmb(kk,1:2)=[k j];
        end;
    end;
end;

% Plot locations
figure(1); clf;
subplot(1,2,1); hold on
for j=1:3;
    plot(Dat.LngLtt(Dat.PlmInd==j,1),Dat.LngLtt(Dat.PlmInd==j,2),'color',VlcClr(j),'marker','o','linestyle','none');
end;
for j=1:3;
    plot(Dat.C3.LngLtt(j,1),Dat.C3.LngLtt(j,2),'marker','.','markersize',40,'color','k');
end;
VlcDfl; VlcAxsLmt;
title('Locations of observations and plume allocations (r=1, m=2, g=3)');
xlabel('Longitude');
ylabel('Latitude');
subplot(1,2,2); hold on
for j=1:3;
    plot(Dat.LngLtt(Dat.RftInd==j,1),Dat.LngLtt(Dat.RftInd==j,2),'color',VlcClr(j),'marker','o','linestyle','none');
end;
for j=1:3;
    plot(Dat.C3.LngLtt(j,1),Dat.C3.LngLtt(j,2),'marker','.','markersize',40,'color','k');
end;
VlcDfl; VlcAxsLmt;
title('Locations of observations and rift allocations (r=1, m=2, g=3, (note, rift 4 converted to 1 or 2)');
xlabel('Longitude');
ylabel('Latitude');
tStr=sprintf('Anl_Data_LngLtt');
VlcGI(fullfile('Output',tStr),2);

if Dgn==1;
    
    % Check distances from lake given in xls with those calculated from LngLtt
    fprintf(1,'Root mean square distance between lake distance from xls and LngLtt is %g\n',sqrt(mean((N(:,4)-Dat.Dst.C1).^2)));
    
    % Plot distances from lake
    figure(1); clf; hold on;
    plot(N(:,4),'r');
    plot(Dat.Dst.C1,'b--');
    VlcDfl; VlcAxsLmt;
    title('Distances from lake from xls (r) and from LngLtt data (b)');
    tStr=sprintf('Dgn_GetDatC1_Distances_%s',datestr(now,30));
    VlcGI(fullfile('Output',tStr),2);
    
    % Plot distances from all centres, with "rift index" and "plume index" highlighted
    figure(1); clf; hold on;
    for j=1:3;
        plot(Dat.Dst.C3(:,j),'color',VlcClr(j));
    end;
    for j=1:3;
        for k=1:3;
            plot(find(Dat.PlmInd==j & Dat.RftInd==k),Dat.Dst.C3(Dat.PlmInd==j & Dat.RftInd==k,j),'color',VlcClr(k),'marker','o','linestyle','none');
        end;
    end;
    VlcDfl; VlcAxsLmt;
    title(sprintf('Distances from 3 centres: [%g,%g] (r), [%g,%g] (m), [%g,%g] (g); plume allocations (location of circle), and rift (color of circle)',reshape(Dat.C3.LngLtt',6,1)));
    tStr=sprintf('Dgn_GetDatC3_%s',datestr(now,30));
    VlcGI(fullfile('Output',tStr),2);
    
end;

return;

