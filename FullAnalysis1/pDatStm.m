function pDatStm(Txt);
%function pDatStm(Txt);

set(gcf,'units','pixels');
set(gca,'units','pixels');

FigPos=get(gcf,'position');
AxPos=get(gca,'position');
LctX=FigPos(1)+FigPos(3)-AxPos(1)-150;
LctY=30-AxPos(2);

tStr=sprintf('PhJ %s',datestr(now,30));

text(LctX,LctY,pUnTeX(tStr),'FontName','Garamond','FontSize',10,'FontWeight','bold','units','pixels','horizontalalignment','right','verticalalignment','middle');%,'Interpreter','latex');

if nargin==1;
   FigPos=get(gcf,'position');
   AxPos=get(gca,'position');
   LctX=FigPos(1)-AxPos(1)+200;
   LctY=30-AxPos(2);
   tStr=pUnTeX(Txt);
   text(LctX,LctY,tStr,'FontName','Garamond','FontSize',10,'FontWeight','bold','units','pixels','horizontalalignment','left','verticalalignment','middle');%,'Interpreter','latex');
end;

return;