set lines 200 pages 2000 long 99999
set serveroutput on
declare
    VQTDPLAN number(3):=&MaisDeXXXPlan;
begin
if VQTDPLAN is null then
VQTDPLAN:=1;
end if;
for x in (select sql_id,hash_value from gv$sql where upper(SQL_FULLTEXT) like '%GV$DATAPUMP_JOB%') loop
for y in (select count(distinct plan_hash_value) qtd_plan, inst_id from gv$sql_plan where sql_id=x.sql_id group by inst_id) LOOP
if y.qtd_plan > VQTDPLAN then
    dbms_output.put_line('SQL_ID:......................... ' || x.sql_id);
    dbms_output.put_line('INSTANCE ID:.................... ' || y.inst_id);
    dbms_output.put_line('QTD. DE PLANOS DE EXEC.:........ ' || y.qtd_plan);
    dbms_output.put_line('CORPO DA QUERY:................. select sql_fulltext from v$sql where sql_id=''' || x.sql_id || ''';' || chr(10));
end if;
end loop;
end loop;
end;
/
