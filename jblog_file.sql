#-- -----------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer dados dos Log Files
#-- Nome do arquivo     : jblog_file.sql
#-- Data de criação     : 15/07/2014
#-- Data de atualização : 
#-- -----------------------------------------------------------------------------------------#

/*
alter database add logfile member '/u01/app/oracle/oradata/orcl/onlinelog/redo02_04.log' to group 4;
alter database add logfile member '/u01/app/oracle/oradata/orcl/onlinelog/redo02_05.log' to group 5;
*/

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
col BYTES for a10
col members for 9999
col member for a60
col status for a9
set lines 200

select lf.MEMBER,l.BYTES/1024/1024 || ' MB' BYTES,l.ARCHIVED,lf.TYPE,l.GROUP#,l.THREAD#,l.STATUS ,l.FIRST_TIME 
from v$log l, v$logfile lf
where l.group#=lf.group# order by GROUP#;
