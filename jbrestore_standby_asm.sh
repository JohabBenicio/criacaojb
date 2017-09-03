

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


cat <<EOF>/tmp/restore.rcv
run{
	allocate channel c1 device type disk;
	$CATALOG_RMAN
	restore database;
	recover database;
	release channel c1;
}
EOF







sqlplus -S /nolog <<EOF>/tmp/jbrestore_standby.log
conn / as sysdba
set echo on

create pfile from spfile;
create spfile from pfile;

startup nomount;

alter system set  control_files = '$DISKGROUP' comment='Set by Johab' scope=spfile;

show parameter control_files

shutdown immediate;

startup nomount;

quit;

EOF

echo -e "\n\n">>/tmp/jbrestore_standby.log 


rman target / cmdfile /tmp/restore_controlfile.rcv msglog /tmp/restore_controlfile.log


echo -e "\nRestauracao do controlfile do standby.\n ">>/tmp/jbrestore_standby.log


cat /tmp/restore_controlfile.log>>/tmp/jbrestore_standby.log 

echo -e "\n\n">>/tmp/jbrestore_standby.log 

export NEWCONT=$(cat /tmp/restore_controlfile.log | grep -i "output file name=" | wc -l)

if [ "$NEWCONT" -eq "1" ]; then
	export NEWCONT=$(cat /tmp/restore_controlfile.log | grep -i "output file name=" | sed 's/output file name=//')
else
	export NEWCONT=$(cat /tmp/restore_controlfile.log | grep -i "nome do arquivo de saída=" | sed 's/nome do arquivo de saída=//')
fi





sqlplus -S /nolog <<EOF>>/tmp/jbrestore_standby.log 
conn / as sysdba
set echo on
set feedback on

alter system set  control_files = '$NEWCONT' comment='Set by Johab' scope=spfile;
shutdown immediate;
startup nomount;
alter database mount standby database;

show parameter control_files

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

quit;

EOF

echo -e "\n\n">>/tmp/jbrestore_standby.log 


rman target / cmdfile /tmp/restore.rcv msglog /tmp/restore.log 

cat /tmp/restore.log >> /tmp/jbrestore_standby.log

echo -e "\n\n">>/tmp/jbrestore_standby.log 


sqlplus -S /nolog <<EOF>>/tmp/jbrestore_standby.log
conn / as sysdba

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



:wq!




