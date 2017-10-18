function Result=Optimizer_GetAlphaRaw(conn,DateT)
setdbprefs('datareturnformat','table')
str1=sprintf(['select TradingDay,InnerCode,TotalScore  '...
    'from ShengYunDB..StatFM_Info  '...
    'where TradingDay>=''%s'' '...
    'order by TradingDay,InnerCode  '...
    ],DateT);
curs=exec(conn, str1);
curs=fetch(curs);
Alpha = curs.Data;
Result=[str2double(cellstr(datestr(datenum(Alpha.TradingDay,'yyyy-mm-dd'),'yyyymmdd'))),table2array(Alpha(:,2:3))];