function [A,B,P,Z]=VlcMakSpl(X,Bss);

nX=size(X,1);

%% Specify spline
Z=linspace(Bss.Zl,Bss.Zr,Bss.nZ)';
[B,P]=pBss(Z, Bss.Zl, Bss.Zr, Bss.ndZ, Bss.SplDgr, Bss.PnlOrd, Bss.IsPrd);

%% Map observations on to index set
A=nan(nX,1);
for i=1:nX;
    t1=(X(i)-Z).^2;
    t2=find(t1==min(t1));t2=t2(1);
    A(i)=t2;
end;

return;