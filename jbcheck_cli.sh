

if [ -z "$1" ]; then
	echo "Digite: jbcheck_cli.sh <sid>"
	exit
fi

export ORACLE_SID=orcl

function check {
${ORACLE_HOME}/bin/sqlplus -S "/ as sysdba" << EOF

set serveroutput on
set feedback off;

declare
        x numeric(10);
begin
        select max(sequence#) into x from v\$log_history;
        dbms_output.put_line(x);
end;
/
exit
EOF
}

function check2 {

${ORACLE_HOME}/bin/sqlplus -S  "sys/oracle11g@STDBY as sysdba" << EOF

set feedback off;
set serveroutput on

declare
        x numeric(10);
begin
        select max(sequence#) into x from v\$log_history;
        dbms_output.put_line(x);
end;
/
exit
EOF
}
NUM1=$(check)
NUM2=$(check2)
RESULTADO=$(expr $NUM1 - $NUM2 )
echo ""; echo ""
echo "ARCHIVE PROD: $NUM1"
echo "ARCHIVE STANDBY: $NUM2"
echo ""
echo "Diferenca de archives $RESULTADO."
echo ""; echo ""

