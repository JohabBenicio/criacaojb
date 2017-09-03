

set lines 200 pages 2000
col MEMBER for a100
select distinct l.GROUP#, l.THREAD#, l.SEQUENCE#, l.ARCHIVED, l.STATUS, (l.BYTES/1024/1024) BYTES_MB, lf.MEMBER
from gv$log l join gv$logfile lf
on(l.GROUP#=lf.GROUP#)
--where l.thread#=2
order by 2,1;


-- alter system switch logfile;
-- alter system checkpoint;
-- alter database drop logfile group 4;
-- ALTER DATABASE ADD LOGFILE THREAD 1 GROUP 1 SIZE 1024M;
