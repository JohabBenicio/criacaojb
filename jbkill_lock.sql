-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Identificar lock e matar os mesmos.
-- Nome do arquivo     : jbkill_lock.sql
-- Data de criação     : 01/07/2014
-- -----------------------------------------------------------------------------------

set serveroutput on
declare

TLOCK_MIN numeric(10):=&MINUTOS;

begin

TLOCK_MIN:=TLOCK_MIN*60;

for x in (
	select s.inst_id,s.sid,s.serial#,s.prev_hash_value,s.sql_hash_value,s.username,s.status, s.osuser,s.machine,
	l.ctime,l.id1,l.id2
	from gv$session s,gv$lock l where s.sid=l.sid and l.block>0 and l.ctime > TLOCK_MIN and s.username not in ('SYS','SYSTEM','OUTLN','SCOTT','ADAMS','JONES','CLARK','BLAKE','HR','OE','SH','DEMO','ANONYMOUS','AURORA$ORB$UNAUTHENTICATED','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','PERFSTAT','TRACESVR','TSMSYS','XDB','SYSMAN','WKSYS','WKPROXY','OLAPSYS','OWBSYS','MGMT_VIEW','SI_INFORMTN_SCHEMA','WMSYS') 
) loop	

	execute immediate 'alter system kill session '''||x.sid||','||x.serial#||''' immediate';
	dbms_output.put_line('SESSOES DERRUBADAS: SID= '||x.sid||'; SERIAL= '||x.serial#||'; NODE= '||x.inst_id||'; HASH_VALUE= '||x.sql_hash_value);
	
end loop;

end;
/
