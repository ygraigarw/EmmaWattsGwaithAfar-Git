function [RMSEPOpt,LmbOpt,RMSEPTTOpt,LmbTTOpt,Yh,YFll]=VlcFitSpl(Y,A,B,P,CV,Lmb,Txt,Dgn);
%function [RMSEPOpt,LmbOpt,RMSEPTTOpt,LmbTTOpt,Yh,YFll]=VlcFitSpl(Y,A,B,P,CV,Lmb,Txt,Dgn);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Spline fit with two-deep cross-validation for optimal tuning and assessment of predictive performance

nCV=max(CV);
nLmb=size(Lmb,1);
n=size(Y,1);

IS=(1:nCV)';

% Cross-validation loop for testing
SqrErrTst=nan(nCV,1);
LmbTTOpt=nan(nCV,1);
RMSEPTTOpt=nan(nCV,1);
for iC=1:nCV;
    
    ISTT=IS(IS~=iC);
    
    iTst=CV==iC;
    iTT=CV~=iC;
    
    YTT=Y(iTT);
    ATT=A(iTT);
    BTT=B(ATT,:);
    
    YTst=Y(iTst);
    ATst=A(iTst);
    BTst=B(ATst,:);

    % Cross-validation loop for tuning
    SqrErrTT=nan(nCV-1,nLmb);
    nTT=size(YTT,1);
    for jC=1:nCV-1;
    
        iTun=CV==ISTT(jC);
        iTrn=(CV~=iC) & (CV~=ISTT(jC)); %points not in the test or tuning sets
    
        YTrn=Y(iTrn);
        ATrn=A(iTrn);
        BTrn=B(ATrn,:);
    
        YTun=Y(iTun);
        ATun=A(iTun);
        BTun=B(ATun,:);
    
        % Loop over possible values of roughness
        for iL=1:nLmb;
            tCh=inv(BTrn'*BTrn+Lmb(iL).*P)*BTrn'*YTrn; % p-spline regression
            YTunh=BTun*tCh; % fitted values
            %YTunh=VlcSplPrd(tCh,ATun,ATrn,B); % careful fitted values, managing extrapolation
            SqrErrTT(jC,iL)=sum((YTun-YTunh).^2); % lack of fit
        end;
    
    end;

    % Overall performance as a function of roughness
    RMSEPTT=sqrt(sum(SqrErrTT)'/nTT);
    
    % Optimal roughness
    t=find(RMSEPTT==min(RMSEPTT));t=t(1);
    if t>1;
        LmbTTOpt(iC)=Lmb(t);
        RMSEPTTOpt(iC)=RMSEPTT(t);
    else;
        t2=find(RMSEPTT-RMSEPTT(1)<0.01*(max(RMSEPTT)-RMSEPTT(1)));
        t2=max(t2);
        LmbTTOpt(iC)=Lmb(t2);
        RMSEPTTOpt(iC)=RMSEPTT(t2);
    end;
    
    % Issue warning if optimal Lmb appears on edge of Lmb domain
    %if Dgn==1;
        if LmbTTOpt(iC)==Lmb(1);
            fprintf(1,'WARNING: Optimal Lmb suggest very rough solution for %s\n',Txt);
        end;
        if LmbTTOpt(iC)==Lmb(end);
            fprintf(1,'WARNING: Optimal Lmb suggest very smooth solution for %s\n',Txt);
        end;
    %end;

    % Calculate the performance of the optimal model on the test data
    tCh=inv(BTT'*BTT+LmbTTOpt(iC).*P)*BTT'*YTT; % p-spline regression
    %YTsth=BTst*tCh; % fitted values
    YTsth=VlcSplPrd(tCh,ATst,ATT,B); % careful fitted values, managing extrapolation
    SqrErrTst(iC)=sum((YTst-YTsth).^2); % lack of fit
    
end; %loop of iC, testing index

% Overall performance as a function of roughness
RMSEPOpt=sqrt(sum(SqrErrTst)'/n);
LmbOpt=mean(LmbTTOpt);

% Overall spline model
tCh=inv(B(A,:)'*B(A,:)+LmbOpt.*P)*B(A,:)'*Y; % p-spline regression
Yh=B(A,:)*tCh; % fitted values

% Full spline model
tCh=inv(B(A,:)'*B(A,:)+LmbOpt.*P)*B(A,:)'*Y; % p-spline regression
YFll=B*tCh; % fitted values

return;

