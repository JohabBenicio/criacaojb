set lines 200 pages 2000 long 99999
set serveroutput on
declare
    VQTDPLAN number(3):=&MaisDeXXXPlan;
begin
if VQTDPLAN is null then
VQTDPLAN:=1;
end if;
dbms_output.put_line(chr(10)||chr(10)||chr(10));
for y in (select * from (select count(distinct plan_hash_value) qtd_plan, inst_id,sql_id from gv$sql_plan group by inst_id,sql_id) a where qtd_plan>VQTDPLAN ) LOOP
    dbms_output.put_line('SQL_ID:......................... ' || y.sql_id);
    dbms_output.put_line('INSTANCE ID:.................... ' || y.inst_id);
    dbms_output.put_line('QTD. DE PLANOS DE EXEC.:........ ' || y.qtd_plan);
    dbms_output.put_line('CORPO DA QUERY:................. select sql_fulltext from v$sql where sql_id=''' || y.sql_id || ''';' || chr(10));
end loop;
end;
/
