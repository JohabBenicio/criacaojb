-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Data de criação : 26/05/2014
-- -----------------------------------------------------------------------------------

set lines 120 pages 100
break on report
compute sum of TAMANHO_EM_GB on report
compute sum of TAMANHO_EM_MB on report

SELECT
	RPAD(OWNER,20,'-') OWNER,
	LPAD(SUM(BYTES) /1024/1024/1024,20,'-') TAMANHO_EM_GB,
	LPAD(SUM(BYTES) /1024/1024,14,'-') TAMANHO_EM_MB,
	LPAD(TABLESPACE_NAME,30,'-') "DEFAULT TABLESPACE"
FROM
	DBA_SEGMENTS
GROUP BY
	OWNER,TABLESPACE_NAME
having
	owner in ('TASY','TASY_VERSAO');
