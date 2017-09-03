

rm -f /tmp/jbrestore_standby.rcv

vi /tmp/jbrestore_standby.rcv
i


clear

readonly ODU_COLOR_CYAN="\033[1;36;40m"
readonly ODU_COLOR_NORM="\033[0m"
readonly ODU_COLOR_BOLD="\033[1m"
readonly ODU_COLOR_BLINK="\033[5m"
readonly ODU_COLOR_GREEN="\033[1;32;40m"
readonly ODU_COLOR_ORANGE="\033[33;40m"
readonly ODU_COLOR_RED="\033[1;31;40m"
readonly ODU_COLOR_BLUE="\033[1;34;40m"

export MSG_SUCESSO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"Ok"$ODU_COLOR_NORM"
export MSG_FALHA="$ODU_COLOR_BOLD$ODU_COLOR_RED"Falha"$ODU_COLOR_NORM"
export MSG_FINALIZADO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"FINALIZADO"$ODU_COLOR_NORM"

read -p "Informe o nome da instancia: " ORACLE_SID

BANCO=`ps -ef | grep smon | grep $ORACLE_SID 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$ORACLE_SID( |$)" | wc -l`

if [ "$BANCO" -eq "1" ]; then
	echo -e "\n\n   Instancia ja esta no ar.\n   Veja se voce esta na maquina certa! \n\n"
	exit;
fi

read -p "Informe o caminho mais a peça do backup do crontrolfile para standby: " CONTR_STANDBY
read -p "Informe o diretório onde o backup se encontra: " CATALOG
read -p "Informe o diretório onde será armazenado os datafiles: " DIR

export DISKGROUP=$(echo $DIR | sed 's/+//' | awk '{print "+"$DIR}')


echo -e "\n\n\n"

printf "%-100s" "Fazendo backup do init."

cp $ORACLE_HOME/dbs/init$ORACLE_SID.ora $ORACLE_HOME/dbs/init$ORACLE_SID.ora.`date +"%d%m%Y_%H%M"`.bkp 1>>/dev/null 2>>/dev/null

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi


printf "%-100s" "Fazendo backup do spfile."

mv $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora.`date +"%d%m%Y_%H%M"`.bkp 1>>/dev/null 2>>/dev/null

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi


if [ ! -z "$CATALOG" ]; then
	export CATALOG_RMAN="catalog start with '$CATALOG' noprompt;"
else
	export CATALOG_RMAN=''
fi


printf "%-100s" "Criando arquivo para restaurar o controlfile."

cat <<EOF>/tmp/restore_controlfile.rcv
run{
	allocate channel c1 device type disk;
	restore standby controlfile from '$CONTR_STANDBY';
	release channel c1;
}
EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

printf "%-102s" "Criando arquivo para realização do setnewname."

cat <<EOF>/tmp/datafiles.rcv
run{
	allocate channel c1 device type disk;
	report schema;
	release channel c1;
}
EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

printf "%-100s" "Subindo o banco de dados com spfile e atualizando o parametro 'control_files'."

sqlplus -s /nolog <<EOF>/tmp/jbrestore_standby.log
conn / as sysdba

create spfile from pfile;
startup nomount;
alter system set  control_files = '$DISKGROUP' comment='Set by Johab' scope=spfile;
shutdown immediate;
startup nomount;
quit;

EOF

LOG=$(cat /tmp/jbrestore_standby.log | grep "ORA-\|RMAN-" | grep -v ORA-"01507" | wc -l);


if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby.log";exit; fi


printf "%-100s" "Restaurando o controlfile."


nohup rman target / cmdfile /tmp/restore_controlfile.rcv msglog /tmp/jbrestore_standby.log 1>>/dev/null 2>>/dev/null

LOG=$(cat /tmp/jbrestore_standby.log | grep "ORA-\|RMAN-" | wc -l);

if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby.log";exit; fi


printf "%-100s" "Montando o banco de dados."

sqlplus -S /nolog <<EOF>>/tmp/jbrestore_standby.log 
conn / as sysdba

alter database mount standby database;
quit;

EOF

LOG=$(cat /tmp/jbrestore_standby.log | grep "ORA-\|RMAN-" | wc -l);
if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby.log";exit; fi



nohup rman target / cmdfile /tmp/datafiles.rcv msglog /tmp/datafiles.log 1>>/dev/null 2>>/dev/null


cat <<EOF>/tmp/restore.rcv
run{
   allocate channel c1 device type disk;
EOF
cat /tmp/datafiles.log | grep "\*\*\*" | awk '{print "   set newname for datafile " $1 " to '\'$DISKGROUP\'';"}'>>/tmp/restore.rcv
cat /tmp/datafiles.log | grep "TEMP" | awk '{print "   set newname for tempfile " $1 " to '\'$DISKGROUP\'';"}'>>/tmp/restore.rcv
cat <<EOF>>/tmp/restore.rcv
   $CATALOG_RMAN
   restore database;
   switch datafile all;
   release channel c1;
}
EOF



printf "%-100s" "Restaurando o banco de dados."

nohup rman target / cmdfile /tmp/restore.rcv msglog /tmp/jbrestore_standby.log 1>>/dev/null 2>>/dev/null

LOG=$(cat /tmp/jbrestore_standby.log | grep "ORA-\|RMAN-" | wc -l);
if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby.log";exit; fi



printf "%-100s" "Aplicando os archives."

cat <<EOF>/tmp/recover.rcv
run{
	allocate channel c1 device type disk;
	recover database;
	release channel c1;
}

EOF

nohup rman target / cmdfile /tmp/recover.rcv msglog /tmp/recover.log 1>>/dev/null 2>>/dev/null




sqlplus -S /nolog <<EOF>/tmp/jbrestore_standby.log
conn / as sysdba
pro
pro
set lines 500 long 500;
col STATUS for a15
col "OPEN MODE" for a11
col VERSAO for a58
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
  INS.PARALLEL RAC, 
  INS.STATUS, 
  DAT.NAME DATABASE, 
  DAT.OPEN_MODE "OPEN MODE", 
  DAT.LOG_MODE "MODO ARCHIVE", 
  VER.BANNER VERSAO 
FROM v\$INSTANCE INS, v\$DATABASE DAT, v\$VERSION VER 
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';

SELECT 
	UPPER(I.INSTANCE_NAME) INSTANCE_NAME, 
	SUBSTR(D.OPEN_MODE,1,11) "OPEN MODE",  
	H.THREAD#, 
	MAX(H.SEQUENCE#) SEQUENCE# 
FROM 
	V\$LOG_HISTORY H, 
	V\$INSTANCE I, 
	V\$DATABASE D 
WHERE 
	H.THREAD# IN (1,2) 
GROUP BY 
	H.THREAD#, 
	I.INSTANCE_NAME, 
	D.OPEN_MODE
ORDER BY 3;

create pfile from spfile;

quit;

EOF

echo -e "[$MSG_FINALIZADO]"


cat /tmp/jbrestore_standby.log

rm -f /tmp/*.rcv 1>>/dev/null 2>>/dev/null

:wq!


sleep 3

sh /tmp/jbrestore_standby.rcv
