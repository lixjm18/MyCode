classdef Optimizer_Cplex < handle
    properties
        T;
        Code;
        Alpha;
        PreHold
        BenchW;
        NotIn;
        DelWeight;
        StyleExp;
        IndExp;
        Exp;
        StockDelta;
        FactorCov;
        AveR;
        RiskMult;
        AlphaMult;
        Cons;
        OptPort;
        Turnover;
    end
    
    methods
        function obj=Optimizer_Cplex(Input)
            obj.T=Input.Time;
            obj.AveR=Input.Paras.AveR;
            obj.RiskMult=Input.Paras.RiskMult;
            obj.AlphaMult=Input.Paras.AlphaMult;
            obj.Turnover=Input.Paras.Turnover;
            obj.Cons=Input.Cons;
            AlphaCode=Input.AlphaSignal(:,2);
            AlphaV=Input.AlphaSignal(:,3);
            
            BenchCode=Input.BenchMarkWeight(:,2);
            BenchW0=Input.BenchMarkWeight(:,3);
            
            InvestableCode=union(AlphaCode,BenchCode);
            if isempty(Input.PreviousHolding)==0
                AllCode=union(InvestableCode,Input.PreviousHolding(:,1));
            else AllCode=InvestableCode;
            end
            
            LP=length(AllCode);
            % Alpha PreHold BenchW
            AllAlpha=zeros(size(AllCode));
            [~,IA,IB]=intersect(AlphaCode,AllCode,'stable');
            AllAlpha(IB)=AlphaV(IA);
            AllAlpha(isnan(AllAlpha))=0;
            
            
            AllPre=zeros(size(AllCode));
            if isempty(Input.PreviousHolding)==0
                PreCode=Input.PreviousHolding(:,1);
                PreWeight=Input.PreviousHolding(:,2);
                [~,IA,IB]=intersect(PreCode,AllCode,'stable');
                AllPre(IB)=PreWeight(IA);
            end
            
            AllBench=zeros(size(AllCode));
            [~,IA,IB]=intersect(BenchCode,AllCode,'stable');
            AllBench(IB)=BenchW0(IA);
            AllBench=AllBench/sum(AllBench);
            
            IX_In=ismember(AllCode,InvestableCode);
            IX_NotIn=~IX_In;
            
            
            DelWeight=sum(AllPre(IX_NotIn));
            
            StockRiskC=Input.Risks.StockRiskRaw(:,2:end);
            StockRiskCode=StockRiskC.InnerCode;
            StyleExp=nan(LP,7);
            [~,IA,IB]=intersect(StockRiskCode,AllCode,'stable');
            StyleExp(IB,:)=table2array(StockRiskC(IA,{'BP','Beta','Liquidity','ShortMomentum','Size','Vol','WeightedMomentum'}));
            StyleExp(isnan(StyleExp))=0;
            NL=nan(LP,1);
            NL(IB,:)=StockRiskC.NLSIZE(IA);
            NL(isnan(NL))=0;
            
            %         SHExp=nan(LP,1);
            %         SHExp(IB,:)=StockRiskC(IA,14);
            %         SHExp(isnan(SHExp))=0;
            %         Exp50=(BenchW>0)*1;
            
            IndC=zeros(LP,1);
            IndC(IB)=StockRiskC.FirstIndustryCode(IA);
            load('E:\work\riskmodel\Opt_port_update_since20150201.mat', 'IndList')
            IndExp=RM_get_Ind_dummy(IndC,IndList);
            
            
            StockDelta=nan(LP,1);
            StockDelta(IB)=StockRiskC.SpecificSTD_LT(IA);
            INA=isnan(StockDelta);
            StockDelta(INA)=mean(StockDelta(~INA));
            
            FactorCorrC=Input.Risks.FactorCorrRaw;
            FactorCorT=table2array(FactorCorrC(:,2:end));
            OrderRank=[];
            for iO=1:length(FactorCorT(:,1))
                OrderRank=[OrderRank,find(FactorCorT(iO,:)==1,1,'first')];
            end
            %FactorCor=FactorCorT(OrderRank,:);
            FactorCor=nan(size(FactorCorT));
            FactorCor(OrderRank,:)=FactorCorT;
            
            FactorRiskRaw=Input.Risks.FactorRiskRaw;
            FactorStdT=FactorRiskRaw.DailySTD_LT;
            FactorStd=nan(size(FactorStdT));
            FactorStd(OrderRank)=FactorStdT;
            
            FactorCov=FactorCor.*(FactorStd*FactorStd');
            
            obj.Code=AllCode;
            obj.Alpha=AllAlpha;
            obj.PreHold=AllPre;
            obj.BenchW=AllBench;
            obj.NotIn=IX_NotIn;
            obj.DelWeight=DelWeight;
            obj.StyleExp = array2table(StyleExp,...
                'VariableNames',{'BP','Beta','Liquidity','ShortMomentum','Size','Vol','WeightedMomentum'});
            obj.IndExp=IndExp;
            obj.Exp=[StyleExp,IndExp];
            obj.StockDelta=StockDelta;
            obj.FactorCov=FactorCov;
            obj.StyleExp.NLSize=NL;
            
            
            
        end
        
        function Optimize(obj)
            warning('off')
            op=sdpsettings('cachesolvers',1,'solver','cplex','cplex.timelimit',100,'verbose',0);
            
            r=obj.Alpha*obj.AveR;
            Q=(obj.Exp*obj.FactorCov*obj.Exp'+diag(obj.StockDelta.^2));
            QL=Q*obj.RiskMult;%10
            E=obj.Alpha*(1.5e-3)^2*obj.Alpha';
            EK=E*obj.AlphaMult;%20
            
            EQ=QL+EK;
            EQ=(EQ'+EQ)/2;
            n=length(r);
            W = sdpvar(n,1);
            %     d = binvar(n,1);
            Target=r'*W-W'*EQ*W;
            
            C=[sum(W)==0];
            C = C + [(W+obj.BenchW)>=0];%long port
            C = C + [obj.Cons.SingleStock(1)<=W<=obj.Cons.SingleStock(2)];%active weight
            C=C+[obj.Cons.Inds(1)<=obj.IndExp'*W<=obj.Cons.Inds(2)];%ÐÐÒµ
            
            StyleNames=fieldnames(obj.Cons.Styles);
            for i1=1:length(StyleNames)
                Name=StyleNames{i1};
                eval(['lb=obj.Cons.Styles.',Name,'(1);']);
                eval(['rb=obj.Cons.Styles.',Name,'(2);']);
                eval(['C=C+[',num2str(lb),'<=obj.StyleExp.',Name,'''*W<=',num2str(rb),'];']);
            end
            
            
            
            if sum(obj.NotIn)>0
                C = C + [(W(obj.NotIn)+obj.BenchW(obj.NotIn))==0];
            end
            if obj.DelWeight<0.1 && sum(obj.PreHold)>0
                C = C + [sum(abs(W+obj.BenchW-obj.PreHold))<=obj.Turnover];%turnover
            end
            
            
            O1=optimize(C,-Target,op);
            disp(O1.info);
            Wopt=value(W);
            WHold=Wopt+obj.BenchW;
            WHold(abs(WHold)<=0.001)=0;
            WHold=WHold/sum(WHold);
            TurnOver=sum(abs(WHold-obj.PreHold));
            disp(TurnOver);
            
            Optport=[repmat(obj.T,[n,1]),obj.Code,WHold];
            IXC=Optport(:,3)==0;
            Optport(IXC,:)=[];
            obj.OptPort=Optport;
        end
    end
end