-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- -----------------------------------------------------------------------------------
set lines 200
SELECT
	UPPER(I.INSTANCE_NAME) INSTANCE_NAME,
	SUBSTR(D.OPEN_MODE,1,11) "OPEN MODE",
	H.THREAD#,
	max(H.SEQUENCE#) "SEQUENCE#"
FROM
	V$LOG_HISTORY H,
	V$INSTANCE I,
	V$DATABASE D
WHERE
	H.THREAD# IN (1,2) AND
	to_char(H.FIRST_TIME,'yyyymmdd')>to_char(sysdate-1,'yyyymmdd')
group by I.INSTANCE_NAME,D.OPEN_MODE,H.THREAD#
ORDER BY 3;
