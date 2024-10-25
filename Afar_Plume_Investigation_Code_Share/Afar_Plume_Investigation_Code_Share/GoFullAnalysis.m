% DRIVER FUNCTION
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% Assess the predictive performance of 6 different models to explain species composition along 3 rifts
% 
% Setup 
% - There are 14 species of interest, which have been measured at interesting locations
% - The locations are characterised by distance from a common "centre" (the lake) or one of three local centres
% - The local centres are the lake, a point in the northwest, and a point in the southwest
% - The species are in general isotopes of elements found in the ground "rock", or sometimes functions of these
% - For the 3 centre case, observations on rifts 1 and 2 should be allocated to the nearest plume centre. Observations on rifts 3 and 4
%   should be allocated to the lake.
% - We might expect that the properties of concentration with distance depend on both plume centre and rift in general. 
% - We assume that observations belong to just one rift. For some observations, the rift is not known with certainty. I have allocated
%   to the rift which seems obvious from LngLtt
%
% Models
% - There are 5 models, and p refers to plume, r to rift
% - C1C: One centre is active (the lake), and all rifts behave similarly.
%   So "property" with distance from the centre S(d) is the same function for all rifts
% - C3C: Three centres are active, but all rifts behave similarly
%   So "property" with distance from the appropriate centre S(d_p) is the same function for all rifts
% - C1D: One centre is active, but rifts behave differently
%   So "property" with distance from the centre S_r(d) is a different function for each rift
% - C3D: Three centres are active, but rifts behave differently
%   So "property" with distance from the appropriate centre S_r(d_p) is a different function for each rift
%   NB Here, within a given rift, the function S_r(d_p) is the same for different plumes!!
% - C3X: Three centres are active, and all rifts and plumes behave differently
%   So "property" with distance from the appropriate centre S_pr(d_p) is a different function for each rift AND for each plume 
%   NB Here, within a given rift, the function S_r(d_p) is different for different plumes!!
%
% Model variants
% - 1: Spl, a roughness penalised B-spline
% - 2: LnR, a linear regression model (with positive or negative slope)
%
% Model assessment
% - First we need to fit each of the models, then we have to estimate the "predictive performance" of the models.
% - The key to estimating predictive performance is to calculate how well the model works for REPRESENTATIVE DATA
%   THAT WERE NOT USED TO FIT THE MODEL (call this the "test" set)
% - Fitting the linear model is easy. We can do this in one step using maximum likelihood (or least squares,
%   they are the same because we will assume that "measurement error" will be Gaussian) using the "training and tuning" set 
%   (ie all data except the test set).
% - Fitting a spline S is a bit tricky, because we have to estimate the "optimal roughness" of the spline.
%   This means we have to set the roughness of the spline such that it provides best predictive performance for 
%   THE DATA USED TO FIT THE MODEL (ie train and tune only, NOT TEST!!!!!)
% - We achieve this by only using the "training set" for model fitting for a fixed value of "roughness" L (usually lambda),
%   then using the "tuning" set to check how well S(L) actually works for prediction.
% - We can then use the value of L which maximises predictive performance as our "optimal S".
% - In general, the value of L will be different for different species and different rifts. 
%
% Two-deep cross-validation 
% - We fit all of the "model assessment" features together in a "two group cross-validation" analysis. Simply, this works like this
% - Split (formally partition) the whole sample into nCV subsets at random (we need to think a bit about a sensible value for nCV)
% - Use one subset as the test set
% - Use another subset as the tuning set
% - Use the remaining nCV-2 subsets as the training set
% - This way we can estimate the "unbiased" predictive performance of the four models over individual species, and all species
% - NB For models C?L?, we don't need a tuning set. So we just merge it with the training data, and just us test (1 subset) 
%   and train (nCV-1 subsets)
% - Because we split the data in three at random, the answers we get will depend to some extent 
%   on how we split. We can measure this variability in predictive performance by repeating the whole procedure say 100 times.
%   Then we will have "a distribution" of predictive performance for each species (and all species) for all 4 models.

% Clear everything up, just in case there are nasty hang-overs from previous runs
clear; clc; clf

% Optionally remove all old diagnostic ouptput output
if 1;
    dos('del Output\Dgn*png');
end;

% Set up main "tuning factors" for the analysis (we need to check results are not too sensitive to these choices)
Anl.Dgn=0; %diagnosis mode (generate extra diagnostic plots to check things are working when Anl.Dgn=1; otherwise Anl.Dgn=0)
Anl.nRpl=3; %number of replicates (typically 100)
Anl.nCV=5; %number of cross-validation subgroups (minimum number of observations per rift is 41, there as NaNs too, so nCV=5 feels OK)
Anl.nS=2; % Number of sub models (First is always spline, the second is the linear regression so "1" means "spline only" and "2" means "run both").

% Do not ordinarily change these values
Anl.Lmb=10.^(-3:0.1:5)'; %set of spline roughnesses Lmb values to try (for everything!!). 10.^(-8:0.1:1)' worked in testing
Anl.nLmb=size(Anl.Lmb,1);
Anl.Bss.Zl=0; %lower limit of spline domain
Anl.Bss.Zr=1800; %upper limit of spline domain
Anl.Bss.nZ=200; %number of points for spline domain
Anl.Bss.ndZ=30; %roughly number of spline basis functions (also depends on SplDgr and PnlOrd)
Anl.Bss.SplDgr=2; %never change this (2=cubic spline)
Anl.Bss.PnlOrd=2; %never change this (2=second difference == curvature penalty)
Anl.Bss.IsPrd=0; %never change this (0=non-periodic)

% Read in the data
if 1; %from XL is you want
    Dat=VlcGetDat('data_phil_spline_longlat_dist_update_Ce_Pb_100km_Pb.xlsx',Anl.Dgn);
    save Dat Dat;
else; %from MATLAB, assuming you've created this already
    if exist('Dat.mat','file')==2;
        load Dat;
    else;
        fprintf(1,'Need to create Dat.mat first\n');
        return;
    end;
end;

% Loop over replicates of the whole analysis
for iR=1:Anl.nRpl;
    
    fprintf(1,'Replicate %g of %g\n',iR,Anl.nRpl);

    % Split the data into train, tune and test.
    % - Do this separately for each plume x rift combination
    % - Why? To make sure we use IDENTICAL train, tune and test data for each model, so that we can compare them fairly
    CV=VlcMakCV(Dat.PlmRft.Ind,Anl.nCV,Anl.Dgn);

    % Loop over variables
    for iV=1:Dat.p;
        
        % Loop over models
        for iM=1:Dat.Mdl.nMdl;
            
            for iS=1:Anl.nS;
            
                [Anl.RMSEP(iM,iV,iR,iS),Anl.Prf(iM,iV,iR,iS)]=VlcMdl(iR,iV,iM,iS,CV,Dat,Anl);
                
            end;
            
        end; % loop over iM, the model index
        
    end; %loop over iV, variables index
    
end; %loop over iR, the replicate index

% Summarise the performance
%VlcSmm(Dat,Anl); %useful for spline model only
VlcSmm_S(Dat,Anl); %useful to compare spline and linear regression

% Visualise model C1D, since this seems to be best
%VlcSmmC1D(Dat,Anl); %useful for spline model only
VlcSmmC1D_S(Dat,Anl); %useful to compare spline and linear regression

% Save analysis with datestamp
save(sprintf('Output/Anl_%s',datestr(now,30)),'Anl');

% Finish
return;