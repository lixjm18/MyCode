%% Init
addpath('E:\work\MyCode\RiskAlpha');
conn=connect_jydb();
setdbprefs('datareturnformat','table')
str1=sprintf(['select max(TradingDay) as TradingDay  '...
    'from ShengYunDB..StockDailyTrading '...
    'where TradingDay>=''2015-07-01'' '...
     ]);
curs=exec(conn, str1);
curs1=fetch(curs);
TDList = curs1.Data;
TDList=TDList.TradingDay;

Mat=[];
conn=connect_jydb();
setdbprefs('datareturnformat','table')
i1=1;
F=RA_get_exposure_local(TDList{i1},conn);
%%
Excel = actxGetRunningServer('Excel.Application');
WorkBook=get(Excel,'ActiveWorkBook');
Sheets=get(WorkBook, 'Sheets');
SheetC=get(Sheets, 'Item', 'RT');
RangeData=get(SheetC, 'Range', 'E2:E1307');
%%
ColNum=11;
%%

Rets=cell2mat(RangeData.value);
F.Ret=Rets;
FRA=RA_get_factorReturnsLocal(F);
FRA=FRA';
RangeFRA=get(SheetC, 'Range', [N2C(ColNum),'2:',N2C(ColNum),'38']);
RangeFRA.value=FRA;
RangeT=get(SheetC, 'Range', [N2C(ColNum),'1']);
RangeT.value=m2xdate(now());
ColNum=ColNum+1;
