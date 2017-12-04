function [FF1,F]=RA_get_exposure_local_500(TradingDay,conn)
% conn=connect_jydb();
% setdbprefs('datareturnformat','table')
str1=sprintf(['select cast(convert(varchar(8),A.TradingDay,112) as Int) as TradingDay  '...
    ',A.InnerCode  '...
    ',A.MktCap '...
    ',B.Compu_t '...
    ',A.Size  '...
    ',A.Beta  '...
    ',A.ShortMomentum  '...
    ',A.WeightedMomentum  '...
    ',A.Vol  '...
    ',A.Liquidity '...
    ',A.BP '...
    ',A.FirstIndustryCode  '...
    ',Fwd1Ret as Ret '...
    'from ShengYunDB..RM_StockRiskExposure A  '...
    'inner join ShengYunDB..RR_500_Signal B '...
    'on A.InnerCode=B.InnerCode and B.Compu_t is not null '...
    'and A.TradingDay=''%s'' '...
    'and B.TradingDay=(select MAX(TradingDay) from ShengYunDB..RR_500_Signal where TradingDay<=A.TradingDay) '...
    'left join ShengYunDB..StockDailyTrading C '...
    'on C.InnerCode=A.InnerCode '...
    'and C.TradingDay=A.TradingDay '...
    'order by A.TradingDay,A.InnerCode  '...
    ],TradingDay);
curs=exec(conn, str1);
curs1=fetch(curs);
FF1 = curs1.Data;
F=FF1;
%% �ȱʧֵ
try
    ICut=isnan(F.FirstIndustryCode);
    F(ICut,:)=[];
catch err
end