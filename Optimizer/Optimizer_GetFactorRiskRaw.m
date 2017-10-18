function FactorRiskRaw=Optimizer_GetFactorRiskRaw(conn,DateT)
setdbprefs('datareturnformat','table')
str1=sprintf(['select cast(convert(varchar(8),A.TradingDay,112) as Int) as TradingDay '...
    ',A.DailyReturn '...
    ',A.DailySTD_LT '...
    'from ShengYunDB..RM_FactorReturnRisk A '...
    'where Factor in (''Beta'',	''BP'',	''Industry_10.0'',	''Industry_11.0'',	''Industry_12.0'',	''Industry_20.0'',	''Industry_21.0'',	''Industry_22.0'',	''Industry_23.0'',	''Industry_24.0'',	''Industry_25.0'',	''Industry_26.0'',	''Industry_27.0'',	''Industry_28.0'',	''Industry_30.0'',	''Industry_31.0'',	''Industry_32.0'',	''Industry_33.0'',	''Industry_34.0'',	''Industry_35.0'',	''Industry_36.0'',	''Industry_37.0'',	''Industry_40.0'',	''Industry_41.0'',	''Industry_42.0'',	''Industry_50.0'',	''Industry_60.0'',	''Industry_61.0'',	''Industry_62.0'',	''Industry_63.0'',	''Industry_70.0'',	''Liquidity'',	''ShortMomentum'',	''Size'',	''Vol'',	''WeightedMomentum'') '...
    'AND  A.TradingDay >=''%s'' '...
    'order by TradingDay,Factor '...
    ],DateT);
curs=exec(conn, str1);
curs1=fetch(curs);
FactorRiskRaw = curs1.Data;