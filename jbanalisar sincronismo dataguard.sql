alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select thread#, sequence#, first_time, next_time, applied
from   gv$archived_log
where thread# in (1,2) and to_char(first_time,'yyyymmdd') > to_char(sysdate - 5 ,'yyyymmdd')
order by first_time;


set linesize 200 pages 200
col message for a100 trunc
select FACILITY,SEVERITY,to_char(TIMESTAMP,'DDMonYY hh24:mi:ss'),message from V$DATAGUARD_STATUS order by 3 ;