function VlcAxsLmt(Dlt);
%function VlcAxsLmt(Dlt)
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
%Adjust axes limits wrt to range of data plotted
%
%Dlt=0 corresponds to axis('tight');
%Dlt=0.1 corresponds to adding 0.1 * the range of each axis to each axis (so 0.05 either end)

if nargin==0;
	Dlt=0.1;
end;

limits = objbounds(findall(gca));

if isempty(limits)==0;
	
   xl=limits(1); xh=limits(2); yl=limits(3); yh=limits(4); zl=limits(5); zh=limits(6);
   %t=get(gca,'xlim'); xl=t(1); xh=t(2);
   %t=get(gca,'ylim'); yl=t(1); yh=t(2);
   %t=get(gca,'zlim'); zl=t(1); zh=t(2);
    
	rx=xh-xl; if rx==0; rx=abs(xl)*0.1; end;
	xl=xl-rx*Dlt/2; xh=xh+rx*Dlt/2;
	
	ry=yh-yl; if ry==0; ry=abs(yl)*0.1; end;
	yl=yl-ry*Dlt/2; yh=yh+ry*Dlt/2;
	
	if xh>xl & yh>yl;
		set(gca,'xlim',[xl xh],'ylim',[yl yh]);
	end;
	
	rz=zh-zl;
	if rz>0;
		zl=zl-rz*Dlt/2; zh=zh+rz*Dlt/2;
		set(gca,'xlim',[xl xh],'ylim',[yl yh],'zlim',[zl zh]);
	end;
	
end;

return;