-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Data de criação : 26/05/2014
-- -----------------------------------------------------------------------------------



==============================TAMANHO ARCHIVE DIA==================================================


break on report
compute sum of MB on report
set pagesize 50

select
	to_char(completion_time,'mm') M,
	to_char(completion_time,'dd/mm/yyyy') DATA,
	to_char(sum((blocks*block_size)/1048576),'999,999')  MB
from
	v$archived_log
where
	to_char(completion_time,'dd/mm/yyyy') between '07/10/2016' and to_char(to_date(sysdate), 'dd/mm/yyyy')
group by
	to_char(completion_time,'dd/mm/yyyy'),to_char(completion_time,'mm')
	order by 1;




==============================TAMANHO DE CADA ARCHIVE==================================================

set lines 200 long 200 pages 100
col name for a100
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
break on report
compute sum of MB on report

select
	to_char(completion_time,'DD/MM/YYYY HH24:MI:SS') DATA,
	THREAD#,
	SEQUENCE#,
	(blocks*block_size)/1048576 MB,
	name
from
	v$archived_log
where
	--to_char(completion_time,'dd/mm/yyyy') = ('07/10/2017')
	to_char(completion_time,'yyyymmdd') >= to_char(sysdate-1,'yyyymmdd')
order by 1;


==============================MEDIA DO TAMANHO ARCHIVE DIA=============================================

break on report
compute sum of MB on report

select
	to_char(completion_time,'dd/mm/yyyy') DATA,
	AVG((blocks*block_size)/1048576) MB
from
	v$archived_log
where
	to_char(completion_time,'dd/mm/yyyy') between '26/03/2014' and '27/01/2014'
group by
	to_char(completion_time,'dd/mm/yyyy')
	order by 1;







select sysdate-5/250,sysdate from dual;

select sysdate-5/250,sysdate from dual;

SYSDATE-5/250	 SYSDATE
---------------- ----------------
10/11/2015 09:02 10/11/2015 09:31



alter session set nls_date_format='dd/mm/rrrr hh24:mi';


select count(*) "QTD. Arch. entre ", 'Periodo das '||to_date(sysdate-5/250)||' as '||sysdate "Periodo" from v$archived_log where FIRST_TIME between sysdate-5/250 and sysdate;










break on report
compute sum of MB on report
set pagesize 50

select
	to_char(completion_time,'mm') M,
	to_char(completion_time,'dd/mm/yyyy') DATA,
	to_char(sum((blocks*block_size)/1048576),'999,999')  MB
from
	v$archived_log
where
	to_char(completion_time,'dd/mm/yyyy') between '01/01/2016' and to_char(to_date(sysdate), 'dd/mm/yyyy')
group by
	to_char(completion_time,'dd/mm/yyyy'),to_char(completion_time,'mm')
	order by 1;








set lines 200 long 200 pages 100
col name for a80
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
break on report
compute sum of MB on report

select
	to_char(completion_time,'DD/MM/YYYY HH24:MI:SS') DATA,
	THREAD#,
	SEQUENCE#,
	(blocks*block_size)/1048576 MB,
	name
from
	v$archived_log
where
	name is not null
order by 1;
