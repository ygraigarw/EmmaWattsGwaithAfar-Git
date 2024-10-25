function [B,P,D]=VlcBss(X, Xl, Xr, ndX, SplDgr, PnlOrd, IsPrd);
%function [B,P,D]=VlcBss(X, Xl, Xr, ndX, SplDgr, PnlOrd, IsPrd)
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% CONSTRUCT A B-SPLINE BASIS OF SplDgrREE 'SplDgr', USING TRUNCATED POWER
% FUNCTIONS (TPFs). (SEE "SPLINES, KNOTS & PENALTIES", Eilers and MarX
% 2004, pages 3&4)

% X        n x 1 data
% Xl       1 x 1 left limit of X data
% Xr       1 x 1 right limit of X
% ndX      1 x 1 number of segments wanted
% SplDgr   1 x 1 degree of spline
% PnlOrd   1 x 1 difference penalty order
% IsPrd    1 x 1 optional periodic b-spline

%Optional test mode
if nargin==0 %test mode
	X=(0.001:0.001:1)'*10;
	Xl=0;
	Xr=1*10;
	ndX=10;
	SplDgr=3;
	PnlOrd=1;
	IsPrd=1;
end

%Standardise for stability
X=(X-Xl)/(Xr-Xl);
Xl=0;
Xr=1;

%Estimate truncated power functions
dX = (Xr - Xl) / ndX ;
knots = (Xl - SplDgr * dX :dX: Xr + SplDgr * dX)';
% Pw=NaN(length(X),length(knots));
% for i=1:length(X)
% 	for j=1:length(knots)
% 		Pw(i,j)=tpower(X(i),knots(j),SplDgr); %grid of values of the truncated power function for all possible (X,knots)
% 	end
% end
Pw=tpower(X,knots,SplDgr); %grid of values of the truncated power function for all possible (X,knots)

%Convert truncated power functions into b-spline basis set
n = length(knots);
if ndX>SplDgr
    tD = diff(eye(n),SplDgr + 1) ./ (gamma(SplDgr + 1) * dX ^ SplDgr);
    B = (-1) ^ (SplDgr + 1) * Pw * tD';
    m = length(B(1,:));
else
    error('not enough knots for spline degree')    
end
B(abs(B)<1e-5)=0;
B=sparse(B);

%Make periodic b-spline if required
if IsPrd==1 %periodic version
	B(:,1:SplDgr) = B(:,1:SplDgr)+B(:,m-(SplDgr-1):m);
	B=B(:,1:m-SplDgr);
end

%Compute Penalty Matrix
if IsPrd==0 %non-periodic
    if PnlOrd==0
        D = speye(m);
    else
        if m>PnlOrd
            D = diff(speye(m), PnlOrd);
        else
            error('not enough knots for penalty degree')
        end
    end
    P = D' * D;
else %periodic
    %20130115: this was previously using PnlOrd+1 instead of SplDgr, which works when
    %SplDgr=3 and PnlOrd=2 (our default) but was not correct in general
    if (m-SplDgr)>PnlOrd
        d1=diff(eye(m-SplDgr),PnlOrd);
        d2=d1(1,:);
        d3=NaN(m-SplDgr,m-SplDgr);
        for i=1:m-SplDgr
            d3(i,:)=circshift(d2,[0,i-1]);
        end
        D=sparse(d3);
        P = D' * D;
    else
        error('not enough knots for penalty degree')
    end
end

%Plot if test
if nargin==0 %test mode
	%pMakFgr;
    clf
	subplot(1,2,1);hold on; plot(X,B); plot(X,B(:,1),'k','LineWidth',3); title 'b-spline basis functions';
	subplot(1,2,2);hold on; plot(P); plot(P(:,1),'k','LineWidth',3); title 'penalty matrix';
	fprintf(1,'pBBase: B is %g x %g\n',size(B));
	fprintf(1,'pBBase: P is %g x %g\n',size(P));
end

%Normal completion
return;

%*************************************************************
function P = tpower(x, knots, SplDgr)

% TRUNCATED POWER FUNCTION - USING TO CONSTRUCT B-SPLINE BASIS MATRIX
%See "Splines, Knots & Penalties" (Eilers & Marx 2004), and "The Craft of Smoothing"
%presentation - slide 23-24

[X,T] = meshgrid(x,knots);
P=((X - T) .^ SplDgr .* (X > T))';

%Normal completion
return;
%*************************************************************