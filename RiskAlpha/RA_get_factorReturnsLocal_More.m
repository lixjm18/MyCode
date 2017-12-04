function [FRA]=RA_get_factorReturnsLocal_More(F)
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
Rets=F.Ret;
Cap=F.MktCap;
NewAlpha=table2array(F(:,14:end)); 
for i1=1:length(NewAlpha(1,:))
    NewAlpha(:,i1)=get_norm_rank(NewAlpha(:,i1),0);
end



RC=Rets;
AlphaC=AlphaF;
StyleC=StyleF;
IndC=IndF;


W=Cap.^0.5;
W=W/sum(W);
% X=[AlphaC,StyleC,IndC,NewAlpha];
X=[StyleC,IndC,NewAlpha];
mdl = fitlm(X,RC,'Weights',W,'Intercept',false);
FR=mdl.Coefficients.Estimate;
FRA=FR';
