function Txt2=VlcU2H(Txt1);
%function Txt2=VlcU2H(Txt1);
%
% MATLAB code to accompany the article "Afar triple junction fed by single, asymmetric mantle upwelling"
% by Watts et al. (2024).
%
% See GoFullAnalysis.m for context
%
% Replace troublesome underscores by hyphens

if iscell(Txt1)==1;
    nT=size(Txt1,1);
    Txt2=Txt1;
    for iT=1:nT;
        tTxt=Txt1{iT};
        t1=strfind(tTxt,'_');
        tTxt(t1)='-';
        Txt2{iT}=tTxt;
    end;
end;

if ischar(Txt1)==1;
    nT=size(Txt1,1);
    Txt2=Txt1;
    for iT=1:nT;
        tTxt=Txt1(iT,:);
        t1=strfind(tTxt,'_');
        tTxt(t1)='-';
        Txt2(iT,:)=tTxt;
    end;
end;

return;