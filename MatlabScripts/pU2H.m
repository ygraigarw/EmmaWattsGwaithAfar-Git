function Txt2=pU2H(Txt1);

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