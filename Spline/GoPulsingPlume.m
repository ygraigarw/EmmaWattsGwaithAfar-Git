clear;

% Load worksheet
if 1; %from XL
    [N,T]=xlsread('data_phil_spline.xlsx'); %read data
    Dat.Lbl.Obs=T(2:end,1); %observation names
    Dat.Lbl.Vrb=T(1,2:end)'; %variable names
    Dat.Lbl.Vrb(2+9)={'LaOverSm'};
    Dat.X=N; %data matrix
    save Dat Dat;
else; %from MATLAB
    load Dat;
end;

for iV=1:14; %loop over all 14 variables
    
    for iR=1:5; %loop over all 4 rifts (+ "5" == all rifts)
        
        clf;
        
        %% Define data
        if 1;
            if iR<5;
                t=Dat.X(:,1)==iR; %rift iR
            else;
                t=Dat.X(:,1)<10; %all rifts
            end;
            XIn=Dat.X(t,2); %distance
            YIn=Dat.X(t,2+iV); %choose a variable
            % Drop missing values
            tMss=isnan(YIn);
            XIn=XIn(tMss==0);
            YIn=YIn(tMss==0);
            % Sort by increasing XIn
            [jnk,tOrd]=sort(XIn);
            n=size(XIn,1);
            XIn=XIn(tOrd); %use actual distance
            %XIn=(1:n)'; %use rank of distance
            YIn=YIn(tOrd);
            %plot(XIn,YIn,'ko');
        end;
        
        if 0; % test using simulated data
            XIn=(1:1.5:97)';
            n=size(XIn,1);
            YInTru=abs(sin(2*pi*XIn/27)./sqrt(XIn));
            YIn=YInTru+0.05*randn(n,1);
        end;
        
        %% Specify spline
        Xl=0; %lower limit of x
        Xr=1800; %upper limit of x
        %X=(Xl:Xr)'; %index set of values at which spline is defined
        X=linspace(Xl,Xr,200);
        ndX=30; %roughly number of spline basis functions (also depends on SplDgr and PnlOrd)
        SplDgr=2; %never change this (2=cubic spline)
        PnlOrd=2; %never change this (2=second difference == curvature penalty)
        IsPrd=0; %never change this (0=non-periodic)
        [B,P,D]=pBss(X, Xl, Xr, ndX, SplDgr, PnlOrd, IsPrd);
        [nB,pB]=size(B);
        
        %% Map observations on to index set
        A=nan(n,1);
        for i=1:n;
            t1=(XIn(i)-X).^2;
            t2=find(t1==min(t1));t2=t2(1);
            A(i)=t2;
        end;
        
        %% Cross-validation for optimal roughness
        % Set of Lmb values to try
        Lmb=10.^(-8:0.1:1)';
        nLmb=size(Lmb,1);
        % Cross-validation set-up
        nCV=30; % nCV cross-validation groups
        CV=pMakCV(n,nCV);
        % Fit the p-spline
        if n>=10; %only if there are at least 10 points
            DoPlt=1;
            S=FitSpline(YIn,XIn,A,B,P,CV,Lmb,DoPlt);
            
            if DoPlt==1;
                subplot(1,2,1); hold on;
                if exist('YInTru');
                    plot(XIn,YInTru,'c');
                end;
            end;
            
            tStr=sprintf('SplineFit-%g-%s-Rift%g',iV,Dat.Lbl.Vrb{2+iV},iR);
            pGI(tStr,2);
        end;
    end;
    
end;