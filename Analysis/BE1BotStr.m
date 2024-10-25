nBS=250;

for iBS=1:nBS;
    
    BSIdn=randi(D.Dat.n,D.Dat.n,1);
    
    BSDstLak=D.Dat.Dst.Lak(BSIdn,:);
    BSX=D.Dat.X(BSIdn,:);
    
    for iR=1:2;
        
        % specify rift
        if iR==1;
            t=BSDstLak(:,2)==1; %north
        else;
            t=BSDstLak(:,2)==0; %south
        end;
        
        for j=1:12; % loop over variables
            
            tRsp=BSX(t,j+2);
            tDst=BSDstLak(t,1);
            tKep=~isnan(tRsp);
            tRsp=tRsp(tKep);
            tX=[ones(sum(tKep),1) tDst(tKep)];
            
            tb=tX\tRsp; %linear regression
            
            % handle the situation that fitted trend is in wrong direction
            if tb(2)*D.Rgr.Trn(j+2)<0;
                tb(2)=0;
                tb(1)=mean(tRsp);
            end;
            
            tRsd=tRsp-tX*tb;
            tCnt=tRsp-mean(tRsp);
            D.Rgr.BS.BE1.LOF(j,iR,iBS)=(tRsd'*tRsd)/(tCnt'*tCnt);
            
        end;
        
    end;
    Prf(iBS)=sum(sum(D.Rgr.BS.BE1.LOF(:,:,iBS)))/24;
    
end;
D.Rgr.BS.BE1.OLOF=quantile(Prf,[0.025 0.5 0.975]');