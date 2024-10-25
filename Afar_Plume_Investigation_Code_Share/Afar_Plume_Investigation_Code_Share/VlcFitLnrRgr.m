function [RMSEPOpt,Yh,YFll]=VlcFitLnrRgr(Y,X,Z,CV);
%function [RMSEPOpt,Yh,YFll]=VlcFitLnrRgr(Y,X,Z,CV);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Fit linear regression model, with one-deep cross-validation for estimation of predictive performance

% Dimensions
nCV=max(CV);
n=size(Y,1);

% Cross-validation loop for testing
SqrErrTst=nan(nCV,1);
for iC=1:nCV;
    
    iTst=CV==iC;
    iTT=CV~=iC;
    
    nTT=sum(iTT);
    YTT=Y(iTT);
    XTT=[ones(nTT,1) X(iTT,:)];
    
    nTst=sum(iTst);
    YTst=Y(iTst);
    XTst=[ones(nTst,1) X(iTst,:)];

    % Predict using linear regression
    tCh=inv(XTT'*XTT)*XTT'*YTT; % linear regression
    YTsth=XTst*tCh; % predicted values
    SqrErrTst(iC)=sum((YTst-YTsth).^2); % lack of fit
    
end; %loop of iC, testing index

% Overall performance
RMSEPOpt=sqrt(sum(SqrErrTst)'/n);

% Overall regression model at data locations X
IX=[ones(n,1) X];
IZ=[ones(size(Z,1),1) Z];
tCh=inv(IX'*IX)*IX'*Y; % p-spline regression
Yh=IX*tCh; % fitted values
% Full regression model over "spline" domain
YFll=IZ*tCh; % fitted values

return;

