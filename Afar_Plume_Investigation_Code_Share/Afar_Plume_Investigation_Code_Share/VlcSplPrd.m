function YTsth=VlcSplPrd(Bet,ATst,ATT,B);
%function YTsth=VlcSplPrd(Bet,ATst,ATT,B);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Predict using constructed spline function, but "sample and hold" outside the range of the training data

ATst(ATst<min(ATT))=min(ATT);
ATst(ATst>max(ATT))=max(ATT);

YTsth=B(ATst,:)*Bet;

return;

