function YTsth=VlcSplPrd(Bet,ATst,ATT,B);

% Predict using constructed spline function, but "sample and hold" outside the range of the training data

ATst(ATst<min(ATT))=min(ATT);
ATst(ATst>max(ATT))=max(ATT);

YTsth=B(ATst,:)*Bet;

return;

