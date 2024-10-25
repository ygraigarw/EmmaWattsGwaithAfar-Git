nBS=250;

for iBS=1:nBS;
    
    BSIdn=randi(D.Dat.n,D.Dat.n,1);
    
    BSDstLak=D.Dat.Dst.Lak(BSIdn,:);
    BSDstBE=D.Dat.Dst.BE(BSIdn,:);
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
            if iR==1;
                tDst=BSDstBE(t,1:2);
            else;
                tDst=BSDstBE(t,2:3);
            end;
            tKep=~isnan(tRsp);
            tRsp=tRsp(tKep);
            tX=[ones(sum(tKep),1) tDst(tKep,:)];
            
            tb=tX\tRsp; %linear regression
            
            % handle the situation that fitted trend is in wrong direction
            if tb(2)*D.Rgr.Trn(j+2)<0 && tb(3)*D.Rgr.Trn(j+2)<0;
                tb(2:3)=0;
                tb(1)=mean(tRsp);
            elseif tb(3)*D.Rgr.Trn(j+2)<0;
                tb(3)=0;
                tX2=tX(:,[1 2]);
                tb2=tX2\tRsp; %X\Y is shorthand for "regress Y on X", gives inv(X'*X)*X'*Y
                if tb2(2)*D.Rgr.Trn(j+2)<0;
                    tb(2)=0;
                    tb(1)=mean(tRsp);
                else;
                    tb(1)=tb2(1);
                    tb(2)=tb2(2);
                end;
            elseif tb(2)*D.Rgr.Trn(j+2)<0;
                tb(2)=0;
                tX2=tX(:,[1 3]);
                tb2=tX2\tRsp;
                if tb2(2)*D.Rgr.Trn(j+2)<0;
                    tb(3)=0;
                    tb(1)=mean(tRsp);
                else;
                    tb(1)=tb2(1);
                    tb(3)=tb2(2);
                end;
            end;
                        
            tRsd=tRsp-tX*tb;
            tCnt=tRsp-mean(tRsp);
            D.Rgr.BS.BE3.LOF(j,iR,iBS)=(tRsd'*tRsd)/(tCnt'*tCnt);
            
        end;
        
    end;
    Prf(iBS)=sum(sum(D.Rgr.BS.BE3.LOF(:,:,iBS)))/24;
    
end;
D.Rgr.BS.BE3.OLOF=quantile(Prf,[0.025 0.5 0.975]');