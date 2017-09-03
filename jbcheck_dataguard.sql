SELECT a.thread# Thread,
  a.sequence# Producao,
  MAX(b.sequence#) Dataguard
FROM v$log a,
  v$archived_log b
WHERE a.status  = 'CURRENT'
AND b.applied   ='YES'
AND b.first_time>sysdate-1
AND a.thread#   =b.thread#
GROUP BY a.thread# ,
  a.sequence# ,
  b.thread# ;


