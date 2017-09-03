
define vdias = 1

#--select JOB_NAME,STATUS,LOG_DATE from dba_scheduler_job_log where job_name like 'STATS%' and LOG_DATE > sysdate-7 order by 3 ;

pro
pro Tabelas
pro
SET lines 200 pages 9999
SELECT owner,
  TOT_TAB "Total de Tabelas",
  TOT_ANL "Total de Tabelas Analisadas",
  TOT_TAB-TOT_ANL "Tabelas nao Analisadas",
  to_char((TOT_ANL*100)/TOT_TAB,'999999.99') || '%' as "% Analisado"
FROM
  (SELECT a.owner owner,
    COUNT(a.LAST_ANALYZED) TOT_ANL,
    b.TOT_TAB
  FROM dba_tables a,
    ( SELECT owner,COUNT(1) TOT_TAB FROM dba_tables WHERE temporary='N' GROUP BY owner
    ) b
  WHERE to_char(a.LAST_ANALYZED,'yyyymmdd') > to_char(sysdate-&&vdias,'yyyymmdd')
  AND a.owner=b.owner(+)
  AND a.temporary='N'
  GROUP BY a.owner,
    b.TOT_TAB
  )
ORDER BY 4,2 DESC;
pro
pro

/*
pro Indices
pro
SET lines 200 pages 9999
SELECT owner,
  TOT_IDX "Total de Indices",
  TOT_ANL "Total de Indices Analisados",
  TOT_IDX-TOT_ANL "Indices nao Analisados",
  to_char((TOT_ANL*100)/TOT_IDX,'999999.99') || '%' as "% Analisado"
FROM
  (SELECT a.owner owner,
    COUNT(a.LAST_ANALYZED) TOT_ANL,
    b.TOT_IDX
  FROM dba_indexes a,
    ( SELECT owner,COUNT(1) TOT_IDX FROM dba_indexes WHERE temporary='N' GROUP BY owner
    ) b
  WHERE a.LAST_ANALYZED BETWEEN sysdate-&&vdias AND sysdate
  AND a.owner=b.owner
  AND a.temporary='N'
  GROUP BY a.owner,
    b.TOT_IDX
  )
ORDER BY 4,2 DESC;

*/



( SELECT owner,COUNT(1) TOT_TAB FROM dba_tables WHERE temporary='N' GROUP BY owner
    ) b


SET lines 200 pages 9999
SELECT owner,
  TOT_TAB "Total de Tabelas",
  TOT_ANL "Total de Tabelas Analisadas",
  TOT_TAB-TOT_ANL "Tabelas nao Analisadas",
  to_char((TOT_ANL*100)/TOT_TAB,'999999.99') || '%' as "% Analisado"
FROM
  (SELECT owner,
    COUNT(LAST_ANALYZED) TOT_ANL,
    COUNT(*) TOT_TAB
  FROM dba_tables
  WHERE LAST_ANALYZED BETWEEN sysdate-&&vdias AND sysdate
  AND temporary='N'
  GROUP BY owner
  )
ORDER BY 4,2 DESC;
















