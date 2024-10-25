function y=VlcShp(i);
%function y=VlcShp(i);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Marker shape for scatter plot

Shp=ones(16,3).*NaN;
Shp(1,:)='o'; %circle
Shp(2,:)='square'; % square
Shp(3,:)='diamond';% diamond
Shp(4,:)='^'; % up triangle
Shp(5,:)='v'; % down triangle
Shp(6,:)='>'; % right triangle
Shp(7,:)='<'; % left triangle
Shp(8,:)='+'; % plus sign
Shp(9,:)='x'; % cross
Shp(10,:)='*'; % asterisk

y=NaN;
y=Clr(i,:);