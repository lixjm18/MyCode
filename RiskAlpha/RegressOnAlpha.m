%%
addpath('E:\work\MyCode\RiskAlpha');
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select distinct TradingDay '...
    'from ShengYunDB..StockDailyTrading '...
    'where TradingDay>=''2015-07-01'' '...
    'order by TradingDay '...
    ]);
curs=exec(conn, str1);
curs1=fetch(curs);
TDList = curs1.Data;
TDListF=TDList.TradingDay;
%%
% Mat=[];
load('E:\work\Analysts\NewData_Org_mean\Optimize\300\FRwithAlpha.mat');
conn=connect_jydb();
setdbprefs('datareturnformat','table')
try
    for i1=Mat(end,1)+1:length(TDListF)
        disp(i1)
        F=RA_get_exposure_local(TDListF{i1},conn);
        if istable(F)
            FRA=RA_get_factorReturnsLocal(F);
            Mat=[Mat;[i1,FRA]];
        end
    end
catch err
end
save('E:\work\Analysts\NewData_Org_mean\Optimize\300\FRwithAlpha.mat','Mat')
RelT=TDListF(Mat(:,1)+1);
%%
PortWeight=Input.PortWeight;
TPort=unique(PortWeight(:,1));

[PortXX,RiskC]=get_port_active_exposures_LT(PortWeight,'HS300W','2017-11-30');
%%
TDList=str2double(cellstr(datestr(datenum(TDListF,'yyyy-mm-dd'),'yyyymmdd')));
PortActRet=zeros(1,length(TDList));
PortFactorRets=zeros(37,length(TDList));
PortResidual=zeros(1,length(TDList));
%%
for i1=2:length(TDList)
    i1
    DateT=datestr(datenum(num2str(TDList(i1)),'yyyymmdd'),'yyyy-mm-dd');
    TPortCX=find(TPort<TDList(i1-1),1,'last');
    if isempty(TPortCX)
        continue
    else
        PortC=PortWeight(PortWeight(:,1)==TPort(TPortCX),:);
        FA=Mat(find(Mat(:,1)==i1-1),2:end);
        
        [PortActRet(:,i1),PortFactorRets(:,i1),PortResidual(:,i1)]=RA_decompose_port_ret(PortC,'HS300W',DateT,FA);
    end
end


%%
% PortXX=PortXX';
% RiskC=RiskC';
PortActRet=PortActRet';
PortFactorRets=PortFactorRets';
PortResidual=PortResidual';