function S=FitSpline(Y,X,A,B,P,CV,Lmb,DoPlt);

% Dimensions
nCV=max(CV);
nLmb=size(Lmb,1);
n=size(Y,1);

% Cross-validation loop
SqrErr=nan(nCV,nLmb);
for iC=1:nCV;
    
    iTrn=CV~=iC;
    iTst=CV==iC;
    
    YTrn=Y(iTrn);
    ATrn=A(iTrn);
    BTrn=B(ATrn,:);
    
    YTst=Y(iTst);
    ATst=A(iTst);
    BTst=B(ATst,:);
    
    % Loop over possible values of roughness
    for iL=1:nLmb;
        tCh=inv(BTrn'*BTrn+Lmb(iL).*P)*BTrn'*YTrn; % p-spline regression
        YTsth=BTst*tCh; % fitted values
        SqrErr(iC,iL)=sum((YTst-YTsth).^2); % lack of fit
    end;
    
end;

% Overall performance as a function of roughness
RMSEP=sqrt(sum(SqrErr)'/n);

% Optimal roughness
t=find(RMSEP==min(RMSEP));t=t(1);
if t>1;
    LmbOpt=Lmb(t);
    RMSEPOpt=RMSEP(t);
else;
    t2=find(RMSEP-RMSEP(1)<0.01*(max(RMSEP)-RMSEP(1)));
    t2=max(t2);
    LmbOpt=Lmb(t2);
    RMSEPOpt=RMSEP(t2);
end;

if DoPlt==1;

    subplot(1,2,1); hold on;
    plot(X,Y,'b');
    box on; grid on; axis tight;
    title('Data (obs=b, est=r)');
    xlabel('Distance x');
    
    subplot(1,2,2); hold on;
    plot(log10(Lmb),RMSEP,'k');
    plot(log10(LmbOpt),RMSEPOpt,'ko');
    box on; grid on; axis tight;
    title('Optimal selection of smoothing parameter');
    xlabel('log_{10}(\lambda)');
    ylabel('Root mean square error of prediction');
    
    subplot(1,2,1); hold on;
    tCh=inv(B(A,:)'*B(A,:)+LmbOpt.*P)*B(A,:)'*Y; %p-spline regression
    Yh=B(A,:)*tCh; % fitted values
    plot(X,Yh,'r');
    box on; grid on; axis tight;
    
    pGI('OptimalSplineFit',2);

end;

S.Lmb=Lmb;
S.RMSEP=RMSEP;
S.Opt.Lmb=LmbOpt;
S.Opt.RMSEP=RMSEPOpt;

return;