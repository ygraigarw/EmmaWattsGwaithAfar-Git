function y=eClr(i);
%function y=eClr(i);
% Colours
%

Clr=ones(4,3).*NaN;
Clr(1,:)=[0 0.564 0.741];%blue
Clr(2,:)=[0.466 0.675 0.188];%green
Clr(3,:)=[0.929 0.694 0.125];%yellow/golden
Clr(4,:)=[0.502 0.502 0.502];%grey

y=NaN;

if nargin==0;
    fprintf(1,'Colors are %g: (%g,%g,%g)\n',[(1:4)' Clr]');
    return;
end;

if max(abs(rem(i,1)))>1e-10;
	fprintf(1,'Error: eClr: not integer\n');
	return;
end;

if min(i)<1;
	fprintf(1,'Error: eClr: min(i)<1\n');
	return;
end;

if max(i)>4;
	i=rem(i,11);if i==0; i=4; end;
	if 0;
		fprintf(1,'WARNING: eClr: max(i)>4. Setting to i mod 4\n');
	end;
end;
y=Clr(i,:);