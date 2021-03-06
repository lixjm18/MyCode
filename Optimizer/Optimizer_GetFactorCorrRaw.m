function FactorCorrRaw=Optimizer_GetFactorCorrRaw(conn,DateT)
setdbprefs('datareturnformat','table')
str1=sprintf(['select cast(convert(varchar(8),A.TradingDay,112) as Int) as TradingDay '...
    ',BP '...
    ',Beta '...
    ',Liquidity '...
    ',ShortMomentum '...
    ',Size '...
    ',Vol '...
    ',WeightedMomentum '...
    ',[Industry_10.0] as Industry_10 '...
    ',[Industry_11.0] as Industry_11 '...
    ',[Industry_12.0] as Industry_12 '...
    ',[Industry_20.0] as Industry_20 '...
    ',[Industry_21.0] as Industry_21 '...
    ',[Industry_22.0] as Industry_22 '...
    ',[Industry_23.0] as Industry_23 '...
    ',[Industry_24.0] as Industry_24 '...
    ',[Industry_25.0] as Industry_25 '...
    ',[Industry_26.0] as Industry_26 '...
    ',[Industry_27.0] as Industry_27 '...
    ',[Industry_28.0] as Industry_28 '...
    ',[Industry_30.0] as Industry_30 '...
    ',[Industry_31.0] as Industry_31 '...
    ',[Industry_32.0] as Industry_32 '...
    ',[Industry_33.0] as Industry_33 '...
    ',[Industry_34.0] as Industry_34 '...
    ',[Industry_35.0] as Industry_35 '...
    ',[Industry_36.0] as Industry_36 '...
    ',[Industry_37.0] as Industry_37 '...
    ',[Industry_40.0] as Industry_40 '...
    ',[Industry_41.0] as Industry_41 '...
    ',[Industry_42.0] as Industry_42 '...
    ',[Industry_50.0] as Industry_50 '...
    ',[Industry_60.0] as Industry_60 '...
    ',[Industry_61.0] as Industry_61 '...
    ',[Industry_62.0] as Industry_62 '...
    ',[Industry_63.0] as Industry_63 '...
    ',[Industry_70.0] as Industry_70 '...
    'from ShengYunDB..RM_FactorCorrelation_LT A '...
    'where  A.TradingDay>=''%s'' '...
    'order by TradingDay,Factor '...
    ],DateT);
curs=exec(conn, str1);
curs1=fetch(curs);
FactorCorrRaw = curs1.Data;