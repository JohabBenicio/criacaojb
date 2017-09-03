# Steps to perform for Rolling forward a standby database using RMAN incremental backup when datafile is added to primary (Doc ID 1531031.1)

set serveroutput on lines 200
begin
for x in (SELECT INS.INSTANCE_NAME INSTANCIA,
    INS.STATUS,
    DAT.NAME ,
    DAT.OPEN_MODE,
    DAT.LOG_MODE,
    to_char(INS.STARTUP_TIME,'dd/mm/yyyy hh24:mi') STARTUP_TIME,
    VER.BANNER VERSAO,
    DAT.FORCE_LOGGING
FROM V$INSTANCE INS, V$DATABASE DAT, V$VERSION VER
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%') loop
dbms_output.put_line(chr(10)||chr(10)||chr(10)||'Nome da instancia:............ ' || x.INSTANCIA);
dbms_output.put_line('Nome do banco de dados:....... ' || x.name);
dbms_output.put_line('Status do banco:.............. ' || x.STATUS);
dbms_output.put_line('Startup Time:................. ' || x.STARTUP_TIME);
dbms_output.put_line('Open Mode:.................... ' || x.OPEN_MODE);
dbms_output.put_line('Modo Archive:................. ' || x.LOG_MODE);
dbms_output.put_line('Force logging:................ ' || x.FORCE_LOGGING);
if x.FORCE_LOGGING = 'NO' then
dbms_output.put_line(' ALTER DATABASE FORCE LOGGING; ');
end if;
dbms_output.put_line('Versao do RDBMS:.............. ' || x.VERSAO);
end loop;
end;
/



################################################################################
STANDBY
################################################################################
#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
1) On the standby database, stop the managed recovery process (MRP)

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE CANCEL;


#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
2) On the standby database, find the SCN which will be used for the incremental backup at the primary database:

col CURRENT_SCN for 999999999999
SELECT CURRENT_SCN FROM V$DATABASE;

CURRENT_SCN
-----------
 8584000405

select min(checkpoint_change#) from v$datafile_header;

MIN(CHECKPOINT_CHANGE#)
-----------------------
             8584000406



################################################################################
PRODUCAO
################################################################################
#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
3) In sqlplus, connect to the primary database and identify datafiles added:

define CURRENT_SCN_STANDBY=8584000405
SELECT FILE#, NAME FROM V$DATAFILE WHERE CREATION_CHANGE# > &&CURRENT_SCN_STANDBY;

< Caso não retornar nada, então pule para o passo 4.2.


#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
4) Using rman, create backup of missing datafiles and an incremental backup using the SCN derived in the previous step:

4.1)
RMAN> backup datafile #, #, #, # format '/tmp/ForStandby_%U' tag 'FORSTANDBY';


ou

4.2)


DIR_BKP=/backup/sgoijms/fisico
CURRENT_SCN_STANDBY=8584000405

cat <<EOF>/tmp/backup_incremental_standby.rcv
run{
allocate channel c1 device type disk maxpiecesize=8G;
allocate channel c2 device type disk maxpiecesize=8G;
backup as compressed backupset incremental from SCN $CURRENT_SCN_STANDBY database format '$DIR_BKP/ForStandby_%U' tag 'FORSTANDBY';
backup current controlfile for standby format '$DIR_BKP/ForStandbyCTRL.bck';
release channel c1;
release channel c2;
}
quit;
EOF



rm -f /tmp/backup_incremental_standby.log
nohup rman target / cmdfile /tmp/backup_incremental_standby.rcv msglog /tmp/backup_incremental_standby.log &
sleep 2
tail -200f /tmp/backup_incremental_standby.log




#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
5) Transfer all backup sets created on the primary system to the standby system.


DIR_STANDBY=/u01/backup/sgoijms/fisico
IP_STAND=10.12.31.73
scp $DIR_BKP/ForStandby* $IP_STAND:$DIR_STANDBY




################################################################################
STANDBY
################################################################################
#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
6) Preparar os scripts para a sincronizacao

DIR_STANDBY=/u01/backup/sgoijms/fisico

cat <<EOF>/tmp/backup_incremental_standby.rcv
shutdown immediate;
startup nomount;
restore standby controlfile from '$DIR_STANDBY/ForStandbyCTRL.bck';
alter database mount;
CATALOG START WITH '$DIR_STANDBY' noprompt;
quit;
EOF



sqlplus -S / as sysdba <<EOF>/tmp/datafiles_standby_$ORACLE_SID
set pages 0 lines 300 long 9999 feedback off
select 'catalog datafilecopy '||chr(39)||name||chr(39)||';' from v\$datafile order by 1;
EOF
echo "switch database to copy;">>/tmp/datafiles_standby_$ORACLE_SID


#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
7) Restaure o controlfile no lado do standby e aplique o backup.

# Confira a instancia que vc esta

echo $ORACLE_SID

# Restaurar o controlfile
nohup rman target / cmdfile /tmp/backup_incremental_standby.rcv > /tmp/SincStandby.log &
sleep 1
tail -200f /tmp/SincStandby.log


# Catalogar os datafiles e executar o SWITCH
nohup rman target / cmdfile /tmp/datafiles_standby_$ORACLE_SID >> /tmp/SincStandby.log &
sleep 1
tail -200f /tmp/SincStandby.log

#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
9) Recover the standby database with the cataloged incremental backup:

cat <<EOF>/tmp/recoverDG.rcv
recover database noredo;
EOF

nohup rman target / cmdfile /tmp/recoverDG.rcv > /tmp/SincStandby.log &
sleep 1
tail -200f /tmp/SincStandby.log


#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
10) If the standby database needs to be configured for FLASHBACK use the below step to enable.
<<<<<<<<<<<<<NAO NECESSARIO>>>>>>>>>>>>>>>


#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
11) On standby database, clear all standby redo log groups:


set lines 200 pages 2000
select * from v$standby_log;

col command_txt for a200
select distinct 'ALTER DATABASE CLEAR LOGFILE GROUP '||group#||';' command_txt from v$standby_log;



SQL> ALTER DATABASE CLEAR LOGFILE GROUP 1;
SQL> ALTER DATABASE CLEAR LOGFILE GROUP 2;
SQL> ALTER DATABASE CLEAR LOGFILE GROUP 3;
....


set lines 200 pages 2000
col member for a130
select group#, MEMBER from v$logfile where GROUP# in (select GROUP# from v$standby_log);




#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+#+
12) On the standby database, start the MRP

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE DISCONNECT FROM SESSION;

ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;

Segue abaixo algumas consultas para ajudar na analise do status do dataguard.



alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

select * from v$managed_standby;
select * from v$recovery_progress;


-- Processo MRP<numero> é o processo responsavel por aplicar os archives.
select program,module from v$session where username is null and program like '%MRP%';


set lines 300 pages 20000
col message for a130
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select * from v$dataguard_status;









db_create_online_log_dest_1          string      +DSKDATA
db_create_online_log_dest_2          string
db_create_online_log_dest_3          string
db_create_online_log_dest_4          string

NAME                                 TYPE        VALUE
------------------------------------ ----------- ------------------------------
db_create_online_log_dest_5          string
db_recovery_file_dest                string      +DSKDATA



  standby_archive_dest     = /u01/app/oracle/archivelog/





tail -200f /backup02/tasy/Dump/tasy_schemas.log


Mon Oct 10 15:32:54 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'
Mon Oct 10 15:34:51 BRT 2016
NOTE: ASMB process exiting due to lack of ASM file activity for 189 seconds
Mon Oct 10 15:34:51 BRT 2016
Stopping background process RBAL
Mon Oct 10 15:47:40 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 21: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_21_czqmgocp_.log'
Mon Oct 10 16:01:50 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'
Mon Oct 10 16:16:44 BRT 2016


104.857.600.000




startup nomount;
alter database mount standby database;

alter database recover managed standby database cancel;

alter database recover managed standby database using current logfile disconnect;


  standby_archive_dest     = /u01/app/oracle/archivelog/
  fal_client               = STDBY
  fal_server               = SVP
  db_file_multiblock_read_count= 16
  db_create_file_dest      =
  db_create_online_log_dest_1= +DSKDATA
  db_create_online_log_dest_2=
  db_recovery_file_dest    = +DSKDATA


alter system set db_recovery_file_dest='/u01/app/oracle/archivelog' scope=both;
alter system set db_create_online_log_dest_1='/u01/app/oracle/archivelog' scope=both;



Mon Oct 10 15:32:54 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'
Mon Oct 10 15:34:51 BRT 2016
NOTE: ASMB process exiting due to lack of ASM file activity for 189 seconds
Mon Oct 10 15:34:51 BRT 2016
Stopping background process RBAL
Mon Oct 10 15:47:40 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 21: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_21_czqmgocp_.log'
Mon Oct 10 16:01:50 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'
Mon Oct 10 16:16:44 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 21: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_21_czqmgocp_.log'
Mon Oct 10 16:30:01 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'
Mon Oct 10 16:34:28 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 21: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_21_czqmgocp_.log'
Mon Oct 10 16:45:39 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'
Mon Oct 10 16:46:35 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 21: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_21_czqmgocp_.log'
Mon Oct 10 16:48:04 BRT 2016
Primary database is in MAXIMUM PERFORMANCE mode
RFS[2]: Successfully opened standby log 23: '/u02/onlinelog/svp/STDBY/onlinelog/o1_mf_23_czqmj5f1_.log'


Completed:


ps -ef | grep arc | grep -v grep | awk '{print "kill -9 "$2" # "$8}'
 tail -50f /opt/app/oracle/product/10.2.0/db_1/admin/svp/bdump/alert_stdby.log
