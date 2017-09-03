

#!/bin/bash

. /home/oracle/.bash_profile

STAND_HOME=/u01/app/oracle/admin/unimed/scripts/standby
STAND_RCV=$STAND_HOME/rcv/duplicate_active_standby.rcv
STAND_LOG=$STAND_HOME/log/duplicate_active_standby.log
STAND_SID=unimed

if [ ! -e "$STAND_RCV" ]; then
cat <<EOF>$STAND_RCV
duplicate target database for standby from active database dorecover nofilenamecheck;
EOF
fi

alias SET_ASM="export ORAENV_ASK=NO ; ORACLE_SID=+ASM ; . oraenv; export ORAENV_ASK=YES"
alias SET_SID="export ORAENV_ASK=NO ; ORACLE_SID=$STAND_SID ; . oraenv; export ORAENV_ASK=YES"

SET_SID

sqlplus / as sysdba <<EOF
alter system set control_files='+DGDATA' scope=spfile;
shutdown immediate;
startup nomount;
exit;
EOF

SET_ASM

asmcmd -p rm -rf +DGDATA/$STAND_SID/

SET_SID

rman target sys/oracle11g@PROD auxiliary sys/oracle11g@STBY cmdfile $STAND_RCV msglog $STAND_LOG
exit;
