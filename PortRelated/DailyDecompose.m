addpath('E:\work\MyFun\PortRelated')
addpath('E:\work\MyFun\StatsFun')
addpath('E:\work\DataUpdate\Daily\PPT')
addpath('E:\work\MyClass\Opt300_Performance')
%% get 300 Ports
PortWeight=[];
StartT=datestr(datenum(num2str(PortWeight(1,1)),'yyyymmdd'),'yyyy-mm-dd');
%% TDList
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select distinct cast(convert(varchar(8),A.TradingDay,112) as Int) as TradingDay '...
    'from ShengYunDB..StockDailyTrading A '...
    'where TradingDay>=''%s'' order by TradingDay '...
    ],StartT);
curs=exec(conn, str1);
curs=fetch(curs);
TDS = curs.Data;
%%
TPort=unique(PortWeight(:,1));
%%
TDList=TDS.TradingDay(1:end);
PortXX=zeros(36,length(TDList));
RiskC=zeros(4,length(TDList));
PortActRet=zeros(1,length(TDList));
PortFactorRets=zeros(36,length(TDList));
PortResidual=zeros(1,length(TDList));

%%
for i1=2:length(TDList)
    DateT=datestr(datenum(num2str(TDList(i1)),'yyyymmdd'),'yyyy-mm-dd');
    PortC=PortWeight;
    [PortXX(:,i1),RiskC(:,i1)]=get_port_active_exposures_LT(PortC,'HS300W',DateT);
    [PortActRet(:,i1),PortFactorRets(:,i1),PortResidual(:,i1)]=decompose_port_ret(PortC,'HS300W',DateT);
end
%%
PortXX=PortXX';
RiskC=RiskC';
PortActRet=PortActRet';
PortFactorRets=PortFactorRets';
PortResidual=PortResidual';