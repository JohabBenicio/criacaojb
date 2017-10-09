#--select JOB_NAME,STATUS,LOG_DATE from dba_scheduler_job_log where job_name like 'STATS%' and LOG_DATE > sysdate-7 order by 3 ;
#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer QTD de objetos que sofreram a renovação das estatísticas.
#-- Nome do arquivo     : jbtab_colet_statistic.sql
#-- Data de atualização : 27/09/2016
#-- ---------------------------------------------------------------------------------------------------------#

define vdias = 1
pro Tabelas
pro
SET lines 200 pages 9999
COL PCT FOR a9 HEADING '%|Analisado' JUSTIFY RIGHT

SELECT
   nvl(a.owner,b.owner) owner
  ,nvl(a.TOT_ANL,0)+nvl(b.TOT_NAN,0) "Total de Tabelas"
  ,nvl(a.TOT_ANL,0) "Total de Tabelas Analisadas"
  ,nvl(b.TOT_NAN,0) "Tabelas nao Analisadas"
  ,nvl(TO_CHAR((TOT_ANL*100)/(nvl(b.TOT_NAN,0)+nvl(a.TOT_ANL,0)),'999.99'),to_char('0','999.99')) ||'%' AS "PCT"
FROM
  (SELECT owner,
    COUNT(nvl(LAST_ANALYZED,sysdate)) TOT_ANL
  FROM dba_tables
  WHERE TEMPORARY='N'
  and TO_CHAR(nvl(LAST_ANALYZED,sysdate-400),'yyyymmddhh24miss') > TO_CHAR(sysdate-&&vdias,'yyyymmddhh24miss')
  GROUP BY owner
  ) a
  full outer join
  (SELECT owner,
    COUNT(nvl(LAST_ANALYZED,sysdate)) TOT_NAN
  FROM dba_tables
  WHERE TEMPORARY='N'
  and TO_CHAR(nvl(LAST_ANALYZED,sysdate-400),'yyyymmddhh24miss') < TO_CHAR(sysdate-&&vdias,'yyyymmddhh24miss')
  GROUP BY owner
  ) b
on a.owner=b.owner
ORDER BY PCT,2 DESC;



select * from
(SELECT COUNT(nvl(LAST_ANALYZED,sysdate)) TOT_ANL FROM dba_tables WHERE TEMPORARY='N' and TO_CHAR(nvl(LAST_ANALYZED,sysdate-400),'yyyymmddhh24miss') > TO_CHAR(sysdate-&&vdias,'yyyymmddhh24miss')) a
, (SELECT COUNT(nvl(LAST_ANALYZED,sysdate)) TOT_NAN FROM dba_tables WHERE TEMPORARY='N' and TO_CHAR(nvl(LAST_ANALYZED,sysdate-400),'yyyymmddhh24miss') < TO_CHAR(sysdate-&&vdias,'yyyymmddhh24miss')) b;


