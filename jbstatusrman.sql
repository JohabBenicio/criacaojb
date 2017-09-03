#-- -----------------------------------------------------------------------------------
#-- Autor                : Johab Benicio de Oliveira.
#-- Descrição            : Trazer status do backup via RMAN.
#-- Nome do arquivo      : jbstatusrman.sql
#-- Data de criação      : 02/04/2014
#-- -----------------------------------------------------------------------------------

set lines 200 long 200 pages 200
col name for a80
col status for a25
col START_DATA for a10
col START_HORA for a8
col "HORA FIM" for a15

select b.instance_name, a.object_type, a.status, to_char(a.start_time,'DD/MM/YYYY') start_data, to_char(a.start_time,'hh24:mi:ss') start_hora, 'ate as ' || to_char(a.end_time ,'hh24:mi:ss') "HORA FIM"
from v$rman_status a, v$instance b
where to_char(a.start_time,'mm')=to_char(sysdate,'mm') and a.operation='BACKUP' order by start_data,start_hora;





alter session set nls_date_format='dd/mm/yyyy hh24:mi';
select OBJECT_TYPE,OPERATION,START_TIME,END_TIME,status from v$rman_status where status!='COMPLETED' and OPERATION='BACKUP' order by 3;



alter session set nls_date_format='dd/mm/yyyy hh24:mi';
select OBJECT_TYPE,OPERATION,START_TIME,END_TIME from v$rman_status where OBJECT_TYPE='ARCHIVELOG' and OPERATION='BACKUP' order by 3;


set lines 200 pages 3000
alter session set nls_date_format='dd/mm/yyyy hh24:mi';
select OBJECT_TYPE,OPERATION,START_TIME,END_TIME from v$rman_status where OPERATION='BACKUP' order by 3 asc;


------------------------------  SOMENTE ERROS ---------------------------------


set lines 200 long 200 pages 70
col name for a80
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

select * from (
	select b.instance_name, a.status, a.start_time, a.end_time from v$rman_status a, v$instance b
	where a.status != 'COMPLETED' order by 3 desc
)
where rownum <=100 order by 3 asc;




set lines 200 long 200 pages 200
col name for a80
col status for a25
col START_DATA for a10
col START_HORA for a8
col "HORA FIM" for a15

select * from (
select b.instance_name, a.object_type, a.status, to_char(a.start_time,'DD/MM/YYYY') start_data, to_char(a.start_time,'hh24:mi:ss') start_hora, 'ate as ' || to_char(a.end_time ,'hh24:mi:ss') "HORA FIM"
from v$rman_status a, v$instance b
where to_char(a.start_time,'mm')=to_char(sysdate,'mm') order by start_data desc
)
where rownum <=100 order by 4,5 asc;












set lines 200 long 200 pages 200
col name for a80
col status for a25
col START_DATA for a10
col START_HORA for a8
col "HORA FIM" for a15

select b.instance_name, a.object_type, a.status, to_char(a.start_time,'DD/MM/YYYY') start_data, to_char(a.start_time,'hh24:mi:ss') start_hora, 'ate as ' || to_char(a.end_time ,'hh24:mi:ss') "HORA FIM"
from v$rman_status a, v$instance b
where to_char(a.start_time,'mm')=to_char(sysdate,'mm') and a.operation='BACKUP' and a.status!='COMPLETED' order by start_data,start_hora;




