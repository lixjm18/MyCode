%%
addpath('E:\work\MyClass\Optimizer');

Input=struct();
Input.Risks=struct();
Input.Cons=struct();
Input.Cons.Inds=[-0.5/100,0.5/100];
Input.Cons.SingleStock=[-1.5/100,1.5/100];
Input.Cons.Styles=struct();
Input.Cons.Styles.Size=[-0.6,0.6];
Input.Cons.Styles.NLSize=[-0.6,0.6];
Input.Cons.Styles.Beta=[-0.2,0.2];
Input.Paras.AveR=5e-4;
Input.Paras.RiskMult=10;
Input.Paras.AlphaMult=20;
Input.Paras.Turnover=0.25;
Input.PreviousHolding=[];
%%
conn=connect_jydb();

% str1=sprintf(['select *  '...
%     'from ShengYunDB..V_RM_Opt300HoldCap  '...
%      ]);
% curs=exec(conn, str1);
% curs=fetch(curs);
% HoldCap = curs.Data;
% OptPortOld=[HoldCap.InnerCode,HoldCap.Cap/sum(HoldCap.Cap)];
% DateT='2017-08-11';
%
% PortWeight=xlsread('E:\work\日内跟踪\关注组合\300\OldSignal\Opt\PortWeightTest.xlsx',1);
% OptPortOld=PortWeight(PortWeight(:,1)==max(PortWeight(:,1)),2:3);
% DateT=datestr(datenum(num2str(PortWeight(end,1)),'yyyymmdd'),'yyyy-mm-dd');
Input.PreviousHolding=OptPortOld;
%% Investment U
str1=sprintf(['select InnerCode  '...
    'from ShengYunDB..StatFM_InvestmentUniverse_300  '...
    'where TradingDay=(select max(TradingDay) from ShengYunDB..StatFM_InvestmentUniverse_300)  '...
     ]);
curs=exec(conn, str1);
curs=fetch(curs);
InvestU = curs.Data;
Input.InvestU=InvestU.InnerCode;
%% NonTradeable U
setdbprefs('datareturnformat','table')
str1=sprintf(['select InnerCode  '...
    'from ShengYunDB..Info_Suspend  '...
    'where TradingDay=(select max(TradingDay) from ShengYunDB..Info_Suspend)  '...
     ]);
curs=exec(conn, str1);
curs=fetch(curs);
NonTradeU = curs.Data;
Input.NonTradeU=NonTradeU.InnerCode;

%%
% Input.NonTradeU=OptPortOld(1:50,1);
%% Alpha & Risk
AlphaRaw=Optimizer_GetAlphaRaw(conn,DateT);
%
StockRiskRaw=Optimizer_GetStockRiskRaw(conn,DateT);

%% Factor Risk
FactorCorrRaw=Optimizer_GetFactorCorrRaw(conn,DateT);

%
FactorRiskRaw=Optimizer_GetFactorRiskRaw(conn,DateT);

%%
TDList=unique(AlphaRaw(:,1));
NT=length(TDList);
[IndexW]=RM_get_HS300W();
H=3;
%%

i1=1;
Input.Time=TDList(i1);
Input=UpdateClassInput(Input,AlphaRaw,IndexW,StockRiskRaw,FactorCorrRaw,FactorRiskRaw);

OptSetUp=Optimizer_Cplex_Sus(Input);
OptSetUp.Optimize();
OptPort=OptSetUp.OptPort;
% PortWeight=[PortWeight;OptPort];
T=20170811;
[Exposure,Risk]=get_port_active_exposures_LT(OptPort,'HS300W',datestr(datenum(num2str(T),'yyyymmdd'),'yyyy-mm-dd'));
