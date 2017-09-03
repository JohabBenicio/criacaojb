#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Consulta de verifiucação do banco de dados
#-- Nome do arquivo     : jbdb_ins.sql
#-- Data de criação     : 02/04/2014
#-- -----------------------------------------------------------------------------------

set feedback off;
set lines 200;
col STATUS for a15
col "OPEN MODE" for a11
col INSTANCIA for a15
col VERSAO for a80
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
	INS.PARALLEL RAC,
	INS.STATUS,
	DAT.NAME DATABASE,
	DAT.OPEN_MODE "OPEN MODE",
	DAT.LOG_MODE "MODO ARCHIVE",
	VER.BANNER VERSAO
FROM V$INSTANCE INS, V$DATABASE DAT, V$VERSION VER
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';
set feedback on;






set serveroutput on lines 200
begin
for x in (SELECT DISTINCT INS.INSTANCE_NAME INSTANCIA,
    INS.STATUS,
    DAT.NAME ,
    DAT.OPEN_MODE,
    DAT.LOG_MODE,
    INS.HOST_NAME,
    to_char(INS.STARTUP_TIME,'dd/mm/yyyy hh24:mi') STARTUP_TIME,
    VER.BANNER VERSAO,
    DAT.FORCE_LOGGING
FROM GV$INSTANCE INS, GV$DATABASE DAT, GV$VERSION VER
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%' ORDER BY 1) loop
dbms_output.put_line(chr(10)||chr(10)||chr(10)||'Nome da instancia:............ ' || x.INSTANCIA);
dbms_output.put_line('Nome do banco de dados:....... ' || x.name);
dbms_output.put_line('Status do banco:.............. ' || x.STATUS);
dbms_output.put_line('Startup Time:................. ' || x.STARTUP_TIME);
dbms_output.put_line('Nome do servidor:............. ' || x.HOST_NAME);
dbms_output.put_line('Open Mode:.................... ' || x.OPEN_MODE);
dbms_output.put_line('Modo Archive:................. ' || x.LOG_MODE);
dbms_output.put_line('Versao do RDBMS:.............. ' || x.VERSAO);
dbms_output.put_line('Force logging:................ ' || x.FORCE_LOGGING);
if x.FORCE_LOGGING = 'NO' then
dbms_output.put_line(' ALTER DATABASE FORCE LOGGING; ');
end if;

end loop;
end;
/






set lines 180 pages 10000
col WRL_PARAMETER for a66
select * from gv$encryption_wallet;


