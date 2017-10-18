function Turnover=cal_port_turnover(OldPort,NewPort)
if isempty(OldPort)
    Turnover=sum(abs(NewPort(:,2)));
elseif isempty(NewPort)
    Turnover=sum(abs(OldPort(:,2)));
else
    CodeAll=unique([OldPort(:,1);NewPort(:,1)]);
    HoldOld=zeros(size(CodeAll));
    HoldNew=zeros(size(CodeAll));
    [~,IA,IB]=intersect(CodeAll,OldPort(:,1),'stable');
    HoldOld(IA)=OldPort(IB,2);
     [~,IA,IB]=intersect(CodeAll,NewPort(:,1),'stable');
    HoldNew(IA)=NewPort(IB,2);
    Turnover=sum(abs((HoldNew-HoldOld)));
end