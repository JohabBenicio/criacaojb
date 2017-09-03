14.211.072

9920
16777216

64


set lines 200 pages 2000
col DESCRIPTION for a22
col name for a20

select
   a.ksppinm name,
   substr(b.ksppstvl,1,14) value,
   a.ksppdesc description
   4*
from
   x$ksppi a,
   x$ksppcv b
where
   a.indx = b.indx
and
   a.ksppinm = '_ksmg_granule_size';


desc v$SYSSTAT