function Result=UpdateClassInput(Input,AlphaRaw,IndexW,StockRiskRaw,FactorCorrRaw,FactorRiskRaw)
Result=Input;
AlphaIX=AlphaRaw(:,1)==Result.Time;
Result.AlphaSignal=AlphaRaw(AlphaIX,:);

BenchIX=IndexW(:,1)==Result.Time;
Result.BenchMarkWeight=IndexW(BenchIX,:);



StockRiskIX=StockRiskRaw.TradingDay==Result.Time;
Result.Risks.StockRiskRaw=StockRiskRaw(StockRiskIX,:);

FactorIX=FactorCorrRaw.TradingDay==Result.Time;
Result.Risks.FactorCorrRaw=FactorCorrRaw(FactorIX,:);

FactorIX=FactorRiskRaw.TradingDay==Result.Time;
Result.Risks.FactorRiskRaw=FactorRiskRaw(FactorIX,:);

