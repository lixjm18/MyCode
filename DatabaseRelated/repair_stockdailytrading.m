%% Sql StockDailyTrading Repair
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select TradingDay,InnerCode,Fwd1Ret '...
    'from ShengYunDB..StockDailyTrading '...
    'where Fwd1Ret<-0.11 '...
    'and TradingDay>''2011-01-01'' '...
    'order by InnerCode,TradingDay '...
    ]);
curs=exec(conn, str1);
curs=fetch(curs);
Err = curs.Data;

%%
N=[1,2,3,4,5,10,20];
Cols={'Fwd1Ret '...
'Fwd2Ret '...
'Fwd3Ret '...
'Fwd4Ret '...
'Fwd5Ret '...
'Fwd10Ret '...
'Fwd20Ret '...
};
for i1=1:height(Err)
    Code=Err.InnerCode(i1);
    Date=Err.TradingDay{i1};
    str1=sprintf(['select cast(ClosePrice as float)/cast(PrevClosePrice as float)-1 as Ret '...
        'from JYDB..QT_DailyQuote A '...
        'where InnerCode=%d '...
        'and TradingDay=(select MIN(TradingDay) from JYDB..QT_DailyQuote where InnerCode=A.InnerCode and TradingDay>''%s'') '...
        ],Code,Date);
    curs=exec(conn, str1);
    curs=fetch(curs);
    RealRet = curs.Data;
    RealRet=RealRet.Ret;
    str1=sprintf(['update ShengYunDB..StockDailyTrading '...
        'set Fwd1Ret=%d where InnerCode=%d and TradingDay=''%s'' '...
        ],RealRet,Code,Date);
    curs=exec(conn, str1);
    
    str1=sprintf(['select TradingDay,Fwd1Ret,Fwd2Ret,Fwd3Ret,Fwd4Ret,Fwd5Ret,Fwd10Ret,Fwd20Ret '...
        'from ShengYunDB..StockDailyTrading where InnerCode=%d and TradingDay between dateadd(MONTH,-2,''%s'') and dateadd(MONTH,2,''%s'') '...
        ],Code,Date,Date);
    curs=exec(conn, str1);
    curs=fetch(curs);
    Hist = curs.Data;
    
    Old=table2array(Hist(:,2:end));
    New=Old;
    for i2=2:length(N);
        Nc=N(i2);
        for i3=1:length(New)-Nc
            Rels=New(i3:i3+Nc-1,1);
            New(i3,i2)=exp(sum(log(Rels+1)))-1;
        end
    end
    IX=abs(New-Old)>1/10000;
    
    IXN=find(IX);
    [A,B]=ind2sub(size(New),IXN);
    
    for i3=1:length(A)
        Date=Hist.TradingDay{A(i3)};
        ColName=Cols{B(i3)};
        V=New(IXN(i3));
        str1=sprintf(['update ShengYunDB..StockDailyTrading '...
            'set %s=%d where InnerCode=%d and TradingDay=''%s'' '...
            ],ColName,V,Code,Date);
        curs=exec(conn, str1);
    end
end