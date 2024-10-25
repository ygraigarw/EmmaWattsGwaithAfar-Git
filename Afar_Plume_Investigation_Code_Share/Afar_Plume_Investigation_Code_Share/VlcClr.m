function y=VlcClr(i);
%function y=VlcClr(i);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Line styles for plotting

Clr=ones(16,3).*NaN;
Clr(1,:)=[1 0 0]; %red
Clr(2,:)=[1 0 1];%magenta
Clr(3,:)=[0 1 0];%green
Clr(4,:)=[0 1 1];%cyan
Clr(5,:)=[0 0 1];%blue
Clr(6,:)=[0 0 0];%black
Clr(7,:)=[0.5 0.5 0.5];%grey
Clr(8,:)=[0.6 0.4 0.2];%brown
Clr(9,:)=[0.7 0.3 1];%violet
Clr(10,:)=[0.8 0.8 0];%yellow
Clr(11,:)=[0.9 0.3 0];%orange
Clr(12,:)=Clr(1,:)*0.5;
Clr(13,:)=Clr(2,:)*0.5;
Clr(14,:)=Clr(3,:)*0.5;
Clr(15,:)=Clr(4,:)*0.5;
Clr(16,:)=Clr(5,:)*0.5;

y=NaN;

if nargin==0;
    fprintf(1,'Colors are %g: (%g,%g,%g)\n',[(1:16)' Clr]');
    return;
end;

if max(abs(rem(i,1)))>1e-10;
	fprintf(1,'Error: pClr: not integer\n');
	return;
end;

if min(i)<1;
	fprintf(1,'Error: pClr: min(i)<1\n');
	return;
end;

if max(i)>16;
	i=rem(i,11);if i==0; i=16; end;
	if 0;
		fprintf(1,'WARNING: pClr: max(i)>16. Setting to i mod 16\n');
	end;
end;
y=Clr(i,:);