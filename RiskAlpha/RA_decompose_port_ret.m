function [PortActRet,PortFactorRets,PortResidual]=RA_decompose_port_ret(PortWeight,Bench,DateT,FA)
conn=connect_jydb();
setdbprefs('datareturnformat','table');
F=RA_get_exposure_local(DateT,conn);
Inds=unique(F.FirstIndustryCode);
[~,IX]=ismember(F.FirstIndustryCode,Inds);
Sub=[[1:length(IX)]',IX];
IndMat=zeros(length(IX),length(Inds));
Sub1=Sub(Sub(:,1)>0&Sub(:,2)>0,:);
Index=sub2ind(size(IndMat),Sub1(:,1),Sub1(:,2));
IndMat(Index)=1;
AlphaF=F.Compu_t;
StyleF=table2array(F(:,5:11)); 
IndF=IndMat;
AlphaC=AlphaF;
StyleC=StyleF;
IndC=IndF;

X=[AlphaC,StyleC,IndC];


IndexW=RM_get_IndexWT(Bench,DateT);
WeightHold=zeros(length(X(:,1)),1);
WeightIndex=WeightHold;
[~,IA,IB]=intersect(PortWeight(:,2),F.InnerCode,'stable');
WeightHold(IB)=PortWeight(IA,3);
WeightHold=WeightHold/sum(WeightHold);
[~,IA,IB]=intersect(IndexW.InnerCode,F.InnerCode,'stable');
WeightIndex(IB)=table2array(IndexW(IA,3));
WeightIndex=WeightIndex/sum(WeightIndex);
ActiveW=WeightHold-WeightIndex;
PortXX=X'*ActiveW;

%% 
FactorList={ 'Compu_t '
    'Size  '
    'Beta  '
    'ShortMomentum  '
    'WeightedMomentum  '
    'Vol  '
    'Liquidity '
    'BP '
    'Industry_10.0'
    'Industry_11.0'
    'Industry_12.0'
    'Industry_20.0'
    'Industry_21.0'
    'Industry_22.0'
    'Industry_23.0'
    'Industry_24.0'
    'Industry_25.0'
    'Industry_26.0'
    'Industry_27.0'
    'Industry_28.0'
    'Industry_30.0'
    'Industry_31.0'
    'Industry_32.0'
    'Industry_33.0'
    'Industry_34.0'
    'Industry_35.0'
    'Industry_36.0'
    'Industry_37.0'
    'Industry_40.0'
    'Industry_41.0'
    'Industry_42.0'
    'Industry_50.0'
    'Industry_60.0'
    'Industry_61.0'
    'Industry_62.0'
    'Industry_63.0'
    'Industry_70.0'
    };

%% PortRet
str1=sprintf(['select InnerCode,cast(ClosePrice as float)/PrevClosePrice-1 as Ret '...
    'from ShengYunDB..StockDailyTrading '...
    'where TradingDay=''%s'' '...
    ],DateT);
curs=exec(conn, str1);
curs=fetch(curs);
StockRet = curs.Data;
PortStockRet=zeros(length(PortWeight(:,1)),1);
[~,IA,IB]=intersect(PortWeight(:,2),StockRet.InnerCode,'stable');
PortStockRet(IA)=StockRet.Ret(IB);
PortStockRet(abs(PortStockRet)>0.11)=0;
PortRet=PortWeight(:,3)'*PortStockRet;
%% Index Ret
switch Bench
    case 'CSI500W'
        SecuCode='000905';
    case 'HS300W'
        SecuCode='000300';
end

str1=sprintf(['select DailyRet '...
    'from ShengYunDB..IndexDailyTrading '...
    'where TradingDay=''%s'' and SecuCode=''%s'' '...
    ],DateT,SecuCode);
curs=exec(conn, str1);
curs=fetch(curs);
IndexRet = curs.Data;
IndexRet=IndexRet.DailyRet;
%%
PortActRet=PortRet-IndexRet;
PortFactorRets=PortXX'.*FA;
PortResidual=PortActRet-sum(PortFactorRets);
