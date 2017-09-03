connect / as sysdba
set linesize 1024;
set pagesize 0;
set timing on;
alter session set timed_statistics = true;
alter session set max_dump_file_size = unlimited;
alter session set events '10046 trace name context forever, level 12';
alter session set current_schema = ODHO_C;

<QUERY TEXT>

-- TRACE FILE NAME SELECT
set termout on;
select b.tracefile
from v$session a,
  v$process b
where a.sid =
  (
    select distinct sid
    from v$mystat
  )
  and b.addr = a.paddr;
rollback;
disconnect;
exit;
