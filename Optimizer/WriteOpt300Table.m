function WriteOpt300Table(Port,PortName,Type)
conn=connect_jydb();
Value=cell(size(Port));
Value(:,1)=cellstr(datestr(datenum(cellstr(num2str(Port(:,1))),'yyyymmdd'),'yyyy-mm-dd'));
Value(:,2:3)=num2cell(Port(:,2:3));
Value(:,4)=cellstr(repmat(PortName,[length(Port(:,1)),1]));
Value(:,5)=cellstr(repmat(Type,[length(Port(:,1)),1]));
write_into_sql_table(Value,{'Datatime','Num','Num','Str','Str'},'ShengYunDB..RM_OptWeight_300',conn);