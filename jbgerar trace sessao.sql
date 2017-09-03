

##############################################################################################################
# Consultar dados da sessao informada na variavel "VSID"
##############################################################################################################

define vsid=1280


set lines 300 pages 2000
col tracefile for a90
col machine for a20
col osuser for a15
col min for 9999
col sid for 9999
col serial# for 999999
col inst_id for 9
select s.inst_id,s.sid,s.serial#,s.machine,s.osuser,round(s.last_call_et/60) Min,s.status,s.sql_id,p.inst_id,p.TRACEFILE
from gv$session s, gv$process p
where  sid=&&vsid
and s.PADDR=p.addr
order by 1 ;




##############################################################################################################
# Habilitar traces para sessao informada na variavel "VSID"
##############################################################################################################


col command for a100
set lines 300 pages 300
select 'EXEC SYS.DBMS_SYSTEM.SET_EV('||sid||','||serial#||',10046,12,'||chr(39)||chr(39)||');'||chr(10)|| 'EXEC SYS.DBMS_SYSTEM.SET_EV('||sid||','||serial#||',10046,0,'||chr(39)||chr(39)||');'||chr(10) command
from gv$session
where sid=&&vsid
union all
select
'EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||sid||','||serial#||',TRUE,TRUE);'||chr(10)||
'EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||sid||','||serial#||');' command
from v$session
where sid=&&vsid
/



##############################################################################################################
# Habilitar traces para todas sessoes
##############################################################################################################

define vowner=ODHO_C


col command for a100
set lines 300 pages 30000
select
'EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||sid||','||serial#||',TRUE,TRUE);' command
from v$session
where username='&&vowner' and status='INACTIVE'
/



##############################################################################################################
# Desabilita os traces para todas sessoes
##############################################################################################################

col command for a100
set lines 300 pages 30000
select
'EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||sid||','||serial#||');' command
from v$session
where username='&&vowner'
and sid not in (886,1285)
/


