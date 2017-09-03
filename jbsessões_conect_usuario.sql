

col comand for a50
col username for a20
col machine for a30

select s.status, p.spid ,s.machine,s.username,'alter system kill session '''||s.sid||','|| s.serial#||''' immediate;' comand
from v$session s, v$process p 
where s.username = 'SIUSD' 
and p.addr (+) = s.paddr;

