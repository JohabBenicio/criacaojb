
rm -f /tmp/cjbstatus_standby

vi /tmp/cjbstatus_standby
i

clear

echo -e "\n"
ps -ef | grep smon | grep -v grep | awk '{print $NF}'
echo -e "\n"

read -p "Informe o nome da instancia de produção: " SID

read -p "Find TNSNAMES? Sim (1): " FINDTNS

if [ ! -z "$FINDTNS" ] && [ "$FINDTNS" -eq "1" ] 2>/dev/null ; then

echo -e "\n"

find $ORACLE_BASE -name tnsnames.ora 2>>/dev/null | grep -vi "samples" | while read tnsnames
do
cat $tnsnames | grep '=' -1 | grep -vi 'EXTPROC_CONNECTION_DATA\|DESCRIPTION\|ADDRESS_LIST\|ADDRES\|CONNECT_DATA\|(\|)' | sed "s/=//"
done

echo -e "\n"

fi

read -p "Informe o TNS do standby: " TNS_STD
read -p "Informe a senha do owner sys \"Standby\": " PASS

cat <<JB>/tmp/jbstatus_standby.sh

export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export PATH=$PATH
export ORACLE_SID=$SID

function prod {
sqlplus -S /nolog <<EOF
conn / as sysdba
set serveroutput on
set feedback off
declare
    x numeric(10);
begin
    SELECT SEQUENCE# into x FROM V\\\$LOG_HISTORY WHERE TO_CHAR(FIRST_TIME,'DD/MM/YYYY HH24:MI:SS')=(SELECT TO_CHAR(MAX(FIRST_TIME),'DD/MM/YYYY HH24:MI:SS') FROM V\\\$LOG_HISTORY );
    dbms_output.put_line(x);
end;
/
exit
EOF
}

function stand {
sqlplus -S  "sys/$PASS@$TNS_STD as sysdba" <<EOF
set feedback off
set serveroutput on
declare
    x numeric(10);
begin
    SELECT SEQUENCE# into x FROM V\\\$LOG_HISTORY WHERE TO_CHAR(FIRST_TIME,'DD/MM/YYYY HH24:MI:SS')=(SELECT TO_CHAR(MAX(FIRST_TIME),'DD/MM/YYYY HH24:MI:SS') FROM V\\\$LOG_HISTORY );
    dbms_output.put_line(x);
end;
/
exit
EOF
}

SEQPRD=\$(prod)
SEQSTD=\$(stand)
RESULT=\$(expr \$SEQPRD - \$SEQSTD )
echo -e "\nARCHIVE PROD: \$SEQPRD\nARCHIVE STANDBY: \$SEQSTD\nDiferenca de archive(s) \$RESULT.\n"


JB

echo -e "\n"
ls -l /tmp/jbstatus_standby.sh
echo -e "\n"

rm -f /tmp/cjbstatus_standby

chmod 775 /tmp/jbstatus_standby.sh

:wq!





sh /tmp/cjbstatus_standby
