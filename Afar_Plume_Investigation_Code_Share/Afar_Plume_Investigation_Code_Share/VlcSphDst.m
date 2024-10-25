function D=VlcSphDst(aLngDgr,aLttDgr,bLngDgr,bLttDgr,R);
%function D=VlcSphDst(aLngDgr,aLttDgr,bLngDgr,bLttDgr,R);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Calculate spherical distances between points

%aLngDgr = lng of point A in degrees (E=positive)
%aLttDgr = ltt of point A in degrees (N=positive)
%bLngDgr = lng of point B in degrees (E=positive)
%bLttDgr = ltt of point B in degrees (N=positive)
%R = radius of sphere, if ommitted, earth assumed

%consider points A and B on surface of sphere on unit radius
%spherical cosine law says (on a sphere of radius unity)
%cos(c) =cos(a) * cos(b) + sin(a) * sin(b) * cos(C)
%a is angle from north pole to first point (ie pi/2-ltt in radians)
%b is angle from north pole to first point (ie pi/2-ltt in radians)
%C is the difference in longitude (in radians) between the two points (ie angle in radians subtended by A and B at the north pole)
%c is the distance on the surface of the sphere (in radians) between A and B
%y=c*r is the distance on a sphere of radius r (in metres)

if nargin==0;
   Dst=4;
   switch Dst;
      case 1; %one degree of latitude from Rhuthun must be 1.11e5 m
         aLngDgr=-3.3103;
         aLttDgr=53.1149;
         bLngDgr=-3.3103;
         bLttDgr=53.1149+1;
      case 2; %at latitude 40 degrees N, one degree of longitude is 8.539e4 m (http://www.longitudestore.com/how-big-is-one-gps-degree.html)
         aLngDgr=0;
         aLttDgr=40;
         bLngDgr=1;
         bLttDgr=40;
      case 3; %at latitude 80 degrees N, one degree of longitude is 1.939e4 m (http://www.longitudestore.com/how-big-is-one-gps-degree.html)
         aLngDgr=0;
         aLttDgr=80;
         bLngDgr=1;
         bLttDgr=80;
      case 4; %Rhuthun to Praha, 1.269e6 m (https://www.distancecalculator.net)
         %Rhuthun 3.3103° W, 53.1149° N
         %Praha 14.4378° E, 50.0755° N
         aLngDgr=-3.3103;
         aLttDgr=53.1149;
         bLngDgr=14.4378;
         bLttDgr=50.0755;
   end;
   R=6371e3;
end;

if nargin==4; %assume you are on the earth
   R=6371000;
end;

%% Return if more than half way around the world apart
if abs(bLngDgr-aLngDgr)>180;
   D=NaN;
   return;
end;

%% Return if not in northern hemisphere
if aLttDgr>90 | aLttDgr<0 | aLttDgr>90 | aLttDgr<0;
   D=NaN;
   return;
end;

if (aLngDgr-bLngDgr)^2+(aLttDgr-bLttDgr)^2<1e-10;
   D=0;
   return;
end;

a=(90-aLttDgr)*pi/180;
b=(90-bLttDgr)*pi/180;
C=(bLngDgr-aLngDgr)*pi/180;

D = R * acos(cos(a) * cos(b) + sin(a) * sin(b) * cos(C));

return;