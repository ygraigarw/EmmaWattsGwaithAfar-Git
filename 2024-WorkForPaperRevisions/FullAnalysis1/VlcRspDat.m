function Dat=VlcRspDat(Dat0);
%function Dat=VlcRspDat(Dat0);

%Generate a local perturbed copy of the data for error analysis
%The perturbation is made independently per observation and variable
%The form of the perturbation is x_new = x_old + error_standarddeviation * random Gaussian variate
%Dat.E gives the "plus or minus" measurement error, assumed to be 2 * error_standarddeviation

Dat=Dat0;
Dat.X=Dat.X+randn(Dat.n,Dat.p).*Dat.E/2; %overwrite the Dat.X field with a perturbed version

return;