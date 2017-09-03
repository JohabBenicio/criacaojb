

alias siltcrt1="export ORAENV_ASK=NO ; ORACLE_SID=siltcrt1 ; . oraenv; export ORAENV_ASK=YES"

mkdir sh log rcv

asmcmd rm -rf +DGDATA/jhbsml

siltcrt


export DSTTNS=SILTCRT
export PASS=oracle


rman target sys/$PASS@DSTTNS







rm -f /u01/app/oracle/admin/jhbsml/scripts/atualizacao/sh/DuplActive.sh
vi /u01/app/oracle/admin/jhbsml/scripts/atualizacao/sh/DuplActive.sh
i

#!/bin/bash

source ~/.bash_profile

export ORACLE_SID=siltcrt

# DIRETORIOS
export DISKGROUP=+DGDATA
export DIR_SCRIPT=/u01/app/oracle/admin/jhbsml/scripts/atualizacao

# SCRIPTS/LOGs
export DUPRCV=$DIR_SCRIPT/rcv/duplicate_active_$ORACLE_SID.rcv
export LOG1=$DIR_SCRIPT/log/sqlplus_shut_start_$ORACLE_SID.log
export LOG2=$DIR_SCRIPT/log/rman_duplicate_$ORACLE_SID.log

# DADOS PRODUCAO
export PRDTNS=SILTCRT1
export PASS=oracle

# DADOS TREINAMENTO/HOMOLOG
export DSTTNS=SILTCRT


# INICIO DO PROCESSO DE CLONE

VALID=$(ps -ef | grep pmon | grep $ORACLE_SID | grep -v grep | wc -l)
if [ "$VALID" -eq "0" ]; then

SETASM=$(ps -ef | grep smon | grep -v opuser | grep -i "asm" | sed 's/.*mon_\(.*\)$/\1/')
export ORAENV_ASK=NO ; ORACLE_SID=$SETASM ; . oraenv; export ORAENV_ASK=YES

asmcmd rm -rf $DISKGROUP/$ORACLE_SID

sqlplus -S / as sysdba <<EOF>>$LOG1
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Horas from dual;
pro
pro startup nomount;
startup nomount;
pro
pro alter system set control_files='$DISKGROUP' scope=spfile;
alter system set control_files='$DISKGROUP' scope=spfile;
pro
pro shutdown immediate;
shutdown immediate;
pro
pro startup nomount
pro
startup nomount
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Horas from dual;

exit
EOF

else

sqlplus -S / as sysdba <<EOF>>$LOG1
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Horas from dual;
pro shutdown immediate;
shutdown immediate;
pro
pro startup mount restrict;
startup mount restrict;
pro
pro alter system set control_files='$DISKGROUP' scope=spfile;
alter system set control_files='$DISKGROUP' scope=spfile;
pro create pfile from spfile;
create pfile from spfile;
pro drop database;
drop database;
quit;
pro
pro startup nomount
pro
startup nomount
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Horas from dual;

exit
EOF

fi

cat <<EOF>$DIR_SCRIPT/rcv/duplicate_active_$ORACLE_SID.rcv
run{
allocate auxiliary channel ac1 device type disk;
allocate channel c1 device type disk;
duplicate target database to $ORACLE_SID from active database nofilenamecheck;
}
EOF

rman target sys/$PASS@$PRDTNS auxiliary sys/$PASS@$DSTTNS cmdfile $DUPRCV msglog $LOG2

sqlplus / as sysdba <<EOF>>$LOG1
shutdown immediate;
connect / as sysdba;
startup mount;
alter database noarchivelog;
alter database open;

exit
EOF



exit

# Fim












chmod 760 /u01/app/oracle/admin/jhbsml/scripts/atualizacao/sh/DuplActive.sh





SILTCRT



sqlplus / as sysdba <<EOF>>$LOG1
shutdown immediate;
connect / as sysdba;
startup mount;
alter database noarchivelog;
alter database open;

spool /tmp/desabilit_jobs.sql;

SET LINES 200;
SET LONG 9999;
set pages 9999;
SET SERVEROUTPUT ON;
SET FEEDBACK off;
BEGIN
    FOR X IN (SELECT JOB,LOG_USER
        FROM DBA_JOBS
        WHERE
        BROKEN='N' and
        LOG_USER in (
        'PSISPS',
        'APP_CBL',
        'APP_SYSCARE',
        'APP_SYSBI',
        'APP_SYSWEB',
        'APP_SYSODTPV') )  LOOP
DBMS_OUTPUT.PUT_LINE('EXEC DBMS_IJOB.BROKEN('||X.JOB||',TRUE);');
    END LOOP;

    for y in (SELECT 'EXEC DBMS_SCHEDULER.DISABLE('''||owner||'.'||job_name||''');' disable_job FROM dba_scheduler_jobs where enabled='TRUE' and owner in (
        'PSISPS',
        'APP_CBL',
        'APP_SYSCARE',
        'APP_SYSBI',
        'APP_SYSWEB',
        'APP_SYSODTPV')) LOOP
            DBMS_OUTPUT.PUT_LINE(y.disable_job);
        END LOOP;


END;
/
spool off;

set echo on

@/tmp/desabilit_jobs.sql

drop public database link WEB_CARE;
CREATE PUBLIC DATABASE LINK "WEB_CARE" CONNECT TO "APP_SYSCARE" IDENTIFIED BY VALUES '0556DD32A9C7F1AB86A495404B37FAD1126745B8B906DCB373' USING 'CARE_D7';

exit
EOF