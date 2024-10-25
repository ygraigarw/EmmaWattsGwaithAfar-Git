function CV=VlcCorMakCV(n,nGpCv,X);
%function CV=VlcCorMakCV(n,nGpCv);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Core functionality for partitioning data set

if nargin==2;
    Mth=1; %use traditional approach
else
    Mth=2; %use kmeans to cluster covariates
end;

if nGpCv==n;

    CV=(1:n)';

elseif Mth==1;
    
    %Find a sensible size for each LO group
    nSzGp=floor(n/nGpCv);
    if n-nGpCv*nSzGp>floor(nSzGp/2);
        nSzGp=nSzGp+1;
    end;
    
    %Partition (1:n) sensibly
    CV=ones(n,1)*nGpCv;
    for j=1:nGpCv;
        CV(nSzGp*(j-1)+1:nSzGp*j)=j;
    end;
    CV=CV(1:n);
    
    %Randomise
    if 1;
        [lol,t]=sort(rand(n,1));
        CV=CV(t);
    end;
    
else;
    
    CV=kmeans(X,nGpCv);
    
end;

return;