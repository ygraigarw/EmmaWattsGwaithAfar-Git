clear;
clf;

if 0; % Test the idea in principle
    
    % Make some data
    Xl=0;
    Xr=100;
    X=(Xl:Xr)';
    n=size(X,1);
    YTru=sin(2*pi*X/23); %true signal
    YObs=YTru+0.5*randn(n,1); %observed noisy signal
    %
    subplot(2,2,1); hold on;
    plot(X,YTru,'c');
    plot(X,YObs,'b');
    box on; grid on; axis tight;
    title('Data (tru=c, obs=b, est=r)');
    xlabel('Distance x');
    
    % Get a spline basis matrix
    ndX=30; %roughly number of spline basis functions (also depends on SplDgr and PnlOrd)
    SplDgr=2; %never change this (2=cubic spline)
    PnlOrd=2; %never change this (2=second difference == curvature penalty)
    IsPrd=0; %never change this (0=non-periodic)
    [B,P,D]=pBss(X, Xl, Xr, ndX, SplDgr, PnlOrd, IsPrd);
    p=size(B,2);
    %
    subplot(2,2,2); hold on;
    plot(X,B);
    box on; grid on; axis tight;
    title('Basis functions');
    xlabel('Distance x');
    %
    subplot(2,2,3); hold on;
    imagesc(P);
    box on; grid on; axis tight;
    colorbar;
    title('Spline penalty matrix');
    xlabel('Spline basis index');
    
    % Fit a p-spline
    Lmb=1e-10;
    Ch=inv(B'*B+Lmb.*P)*B'*YObs; %p-spline regression
    %
    subplot(2,2,4); hold on;
    plot(Ch,'r');
    box on; grid on; axis tight;
    title('Estimated spline coefficients');
    xlabel('Spline basis index');
    %
    subplot(2,2,1); hold on;
    Yh=B*Ch; % fitted values
    plot(X,Yh,'r');
    
    pGI('BasicFittingIdeas',2);
    
end;

if 1; %Run a full analysis to estimate optimal roughness
        
    % Define spline basis
    Xl=0;
    Xr=100;
    X=(Xl:Xr)';
    %
    ndX=30; %roughly number of spline basis functions (also depends on SplDgr and PnlOrd)
    SplDgr=2; %never change this (2=cubic spline)
    PnlOrd=2; %never change this (2=second difference == curvature penalty)
    IsPrd=0; %never change this (0=non-periodic)
    [B,P,D]=pBss(X, Xl, Xr, ndX, SplDgr, PnlOrd, IsPrd);
    [nB,pB]=size(B);

    % Define sample for analysis
    XIn=(Xl:Xr)';
    n=size(XIn,1);
    YInTru=sin(2*pi*XIn/27);
    YIn=sin(2*pi*XIn/27)+0.2*randn(n,1);

    % Cross-validation loop to find the optimal value of Lmb
    %
    %
    % Set of Lmb values to try
    Lmb=10.^(-8:0.1:1)';
    nLmb=size(Lmb,1);
    %
    % Cross-validation set-up
    nCV=50; % nCV cross-validation groups
    CV=pMakCV(n,nCV);
    %
    % Allocation (allocate every observation in XIn to a location in X at which B is known)
    A=nan(n,1);
    for i=1:n;
        t1=(XIn(i)-X).^2;
        t2=find(t1==min(t1));t2=t2(1);
        A(i)=t2;
    end;
    %
    % Cross-validation loop
    SqrErr=nan(nCV,nLmb);
    for iC=1:nCV;
        
        iTrn=CV~=iC;
        iTst=CV==iC;
        
        YTrn=YIn(iTrn);
        ATrn=A(iTrn);
        BTrn=B(ATrn,:);

        YTst=YIn(iTst);
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
    
    subplot(1,2,1); hold on;
    plot(XIn,YIn,'b');
    box on; grid on; axis tight;
    title('Data (obs=b, est=r)');
    xlabel('Distance x');
    
    subplot(1,2,2); hold on;
    plot(log10(Lmb),RMSEP,'k');
    t=find(RMSEP==min(RMSEP));t=t(1);
    plot(log10(Lmb(t)),RMSEP(t),'ko');
    if t==1;
        t2=find(RMSEP-RMSEP(1)<0.01*(max(RMSEP)-RMSEP(1)));
        t2=max(t2);
        plot(log10(Lmb(t2)),RMSEP(t2),'ro');
        LmbOpt=Lmb(t2);
    else;
        LmbOpt=Lmb(t);
    end;        
    box on; grid on; axis tight;
    title('Optimal selection of smoothing parameter');
    xlabel('log_{10}(\lambda)');
    ylabel('Root mean square error of prediction');
    
    subplot(1,2,1); hold on;
    tCh=inv(B'*B+LmbOpt.*P)*B'*YIn; %p-spline regression
    YInh=B*tCh; % fitted values
    plot(XIn,YInh,'r');
    if exist('YInTru');
        plot(XIn,YInTru,'c');
    end;        
    box on; grid on; axis tight;

    pGI('OptimalSplineFit',2);
    
end;