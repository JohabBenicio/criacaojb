
--# Flush dos multiplos planos: Homologado para Oracle 11g

set serveroutput on size unlimited;
declare
  v_howmany number := to_number ('2');
begin
  for cursor1 in
  (
    select /*+ leading (b) */ a.address || ',' || a.hash_value as ahv,b.sql_id
    from v$sqlarea a,
    (
      select distinct sql_id
      from v$sql
      where parsing_schema_name NOT IN ('SYS','SYSTEM','OUTLN','SCOTT','ANONYMOUS','AURORA$ORB$UNAUTHENTICATED','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','TRACESVR','TSMSYS','XDB','SYSMAN','WKSYS','WKPROXY','OLAPSYS','OWBSYS','MGMT_VIEW','WMSYS')
      group by sql_id,child_number
      having count (distinct plan_hash_value) >= v_howmany or child_number > 0
    ) b
    where a.sql_id = b.sql_id
      and b.sql_id not in (select sql_id from gv$session where sql_id is not null)
  )
  loop
    dbms_shared_pool.purge (cursor1.ahv, 'C', 1);
    dbms_output.put_line ('Flush do plano de execucao do SQL_ID: '||cursor1.sql_id);
  end loop;
end;
/








define vsql_id=4twyqpc9x73xd


set verify off
set pagesize 999 lines 200
col username format a13
col prog format a22
col sid format 99999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

SELECT inst_id,
  sql_id,
  child_number,
  plan_hash_value plan_hash,
  executions execs,
  elapsed_time /1000000 etime,
  (elapsed_time/1000000)/DECODE(NVL(executions,0),0,1,executions) avg_etime,
  u.username
  FROM gv$sql s,
       dba_users u
WHERE sql_id LIKE NVL('&&vsql_id',sql_id)
AND u.user_id = s.parsing_user_id
/


spool /tmp/sac_session.sql
select 'alter system kill session '||chr(39)||sid||','||serial#||chr(39)||' immediate;' from v$session where sql_id='&&vsql_id';
spool off;

@/tmp/sac_session.sql

DECLARE
  name varchar2(50);
  version varchar2(3);
BEGIN
  select regexp_replace(version,'\..*') into version from v$instance;

  if version = '10' then
    execute immediate
      q'[alter session set events '5614566 trace name context forever']'; -- bug fix for 10.2.0.4 backport
  end if;

  select address||','||hash_value into name
  from v$sqlarea
  where sql_id like '&&vsql_id';

  sys.dbms_shared_pool.purge(name,'C',1);

END;
/

set verify off
set pagesize 999 lines 200
col username format a13
col prog format a22
col sid format 99999
col child_number format 99999 heading CHILD
col ocategory format a10
col avg_etime format 9,999,999.99
col etime format 9,999,999.99

SELECT inst_id,
  sql_id,
  child_number,
  plan_hash_value plan_hash,
  executions execs,
  elapsed_time /1000000 etime,
  (elapsed_time/1000000)/DECODE(NVL(executions,0),0,1,executions) avg_etime,
  u.username
  FROM gv$sql s,
       dba_users u
WHERE sql_id LIKE NVL('&&vsql_id',sql_id)
AND u.user_id = s.parsing_user_id
/




