Bruno Santana
16 3363-8384
16 997-663-006

set lines 300
set pages 9999
col MACHINE for a20
alter session set nls_date_format='DD/mm/YYYY HH24:MI:ss';
select inst_id,sid,serial#,username,osuser,machine,program,logon_time,last_call_et,
decode(sql_hash_value,0,'NAO EXEC. ALGO')
from gv$session
where logon_time >= '14/01/2016 16:32:00';

1378


set lines 300
set pages 9999
col MACHINE for a20
alter session set nls_date_format='DD/mm/YYYY HH24:MI:ss';
select inst_id,sid,serial#,username,osuser,machine,program,logon_time,last_call_et,
decode(sql_hash_value,0,'NAO EXEC. ALGO')
from gv$session
where upper(osuser) like '%SANTANA%';


CENTROVIAS

santana




set lines 300
set pages 9999
col MACHINE for a20
alter session set nls_date_format='DD/mm/YYYY HH24:MI:ss';
select distinct osuser
from gv$session;


select distinct machine ,count(*) from gv$session where osuser='root' group by machine;



where upper(osuser) like '%SANTANA%';
