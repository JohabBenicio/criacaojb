#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Restauração do standby automatico.
#-- Nome do arquivo     : jbrestore.sh
#-- Data de criação     : 30/03/2015
#-- -----------------------------------------------------------------------------------


rm -f /tmp/jbrestore_standby.sh

vi /tmp/jbrestore_standby.sh
i


clear

rm -rf /tmp/jbrestore_standby 1>>/dev/null 2>>/dev/null

mkdir /tmp/jbrestore_standby

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

LINUX=$(uname | grep "Linux" | wc -l)

if [ "$LINUX" -eq "0" ]; then
	echo -e "\n\nSistema criado e homologado para S.O. Linux!\n\n"
	exit;
fi

read -p "ASM (1) ou File system (2): " FSASM

if [ "$FSASM" != "1" ] && [ "$FSASM" != "2" ]; then
	echo -e "\n\nDigite 1 para ASM ou 2 para File System!\n\n";
	exit;
fi

read -p "Informe o nome da instancia: " ORACLE_SID

BANCO=`ps -ef | grep smon | grep $ORACLE_SID 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$ORACLE_SID( |$)" | wc -l`

if [ "$BANCO" -eq "1" ]; then
	echo -e "\n\n   Instancia ja esta no ar.\n   Veja se voce esta na maquina certa! \n\n"
	exit;
fi

SPFILE=$(ls -l $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora 2>>/dev/null | wc -l)
PFILE=$(ls -l $ORACLE_HOME/dbs/init$ORACLE_SID.ora 2>>/dev/null | wc -l)

if [ "$SPFILE" -eq "0" ] && [ "$PFILE" -eq "0" ]; then
	echo -e "\n\nEsta instancia não tem INIT (PFILE) e nem SPFILE!\nFavor criar um PFILE para restauração do standby.\n\n"
	exit
fi

read -p "O binário do Oracle é 9i? Se sim (1) se não (2): " BIN9i

if [ "$BIN9i" != "1" ] && [ "$BIN9i" != "2" ]; then
	echo "Digite 1 Para SIM ou 2 para NÃO!";
	exit;
fi

read -p "Informe o caminho mais a peça do backup do crontrolfile: " CONTR_RESTORE

if [ ! -f "$CONTR_RESTORE" ]; then echo -e "\n\nEste arquivo não existe!\n\n"; exit; fi;

read -p "Informe o diretório onde o backup se encontra: " CATALOG

if [ "$FSASM" -eq "1" ]; then
	read -p "Informe o nome do Diskgroup: " DIR
	VALID=$(echo $DIR | grep '+' | wc -l)
	if [ "$VALID" -eq "0" ]; then
		echo -e "\n\nFavor coloque o (+) no inicio do nome do diskgroup.\n\n"
		read -p "Informe o nome do Diskgroup: " DIR
		VALID=$(echo $DIR | grep '+' | wc -l)

		if [ "$VALID" -eq "0" ]; then
			echo -e "\n\nVocê não colocou o \"+\" no inicio do $DIR!\nProcesso abortado!\n\n";
			exit;
		fi

	fi

else
	read -p "Informe o diretório onde será armazenado os datafiles: " DIR
	if [ ! -d "$DIR" ]; then echo -e "\n\nEste diretorio nao existe!\n\n"; exit; fi

fi

echo -e "\n\n"

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



if [ "$BIN9i" -eq "1" ]; then

cat <<EOF>/tmp/jbrestore_standby/restore_controlfile.rcv
run{
	allocate channel c1 device type disk;
	restore controlfile to '$DIR/controlfile01.dbf' from '$CONTR_RESTORE';
	release channel c1;
}
EOF

else

cat <<EOF>/tmp/jbrestore_standby/restore_controlfile.rcv
run{
	allocate channel c1 device type disk;
	restore controlfile from '$CONTR_RESTORE';
	release channel c1;
}
EOF

fi


if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

printf "%-102s" "Criando arquivo para realização do setnewname."

cat <<EOF>/tmp/jbrestore_standby/datafiles.rcv
run{
	allocate channel c1 device type disk;
	report schema;
	release channel c1;
}
EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

printf "%-100s" "Subindo o banco de dados com spfile e atualizando o parametro 'control_files'."

cat <<EOF>/tmp/jbrestore_standby/alter_control.sql

create pfile from spfile;
create spfile from pfile;
startup nomount;
EOF

if [ "$FSASM" -eq "1" ]; then
	echo "alter system set control_files = '$DIR' comment='Set by Johab' scope=spfile;">>/tmp/jbrestore_standby/alter_control.sql
else
	echo "alter system set control_files = '$DIR/controlfile01.dbf' comment='Set by Johab' scope=spfile;">>/tmp/jbrestore_standby/alter_control.sql
fi

cat <<EOF>>/tmp/jbrestore_standby/alter_control.sql
shutdown immediate;
startup nomount;
quit;

EOF


sqlplus -s /nolog <<EOF>/tmp/jbrestore_standby/jbrestore_standby.log
conn / as sysdba

@/tmp/jbrestore_standby/alter_control.sql

EOF

LOG=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep "ORA-\|RMAN-" | grep -v ORA-"01507\|ORA-01565\|ORA-27037" | wc -l);


if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby/jbrestore_standby.log";exit; fi


printf "%-100s" "Restaurando o controlfile."


nohup rman target / cmdfile /tmp/jbrestore_standby/restore_controlfile.rcv msglog /tmp/jbrestore_standby/jbrestore_standby.log 1>>/dev/null 2>>/dev/null


LOG=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep "ORA-\|RMAN-" | wc -l);

if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby/jbrestore_standby.log";exit; fi


printf "%-100s" "Montando o banco de dados."

if [ "$FSASM" -eq "1" ]; then

export NEWCONT=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep -i "output file name=" | wc -l)

if [ "$NEWCONT" -eq "1" ]; then
	export NEWCONT=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep -i "output file name=" | sed 's/output file name=//')
else
	export NEWCONT=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep -i "nome do arquivo de saída=" | sed 's/nome do arquivo de saída=//')
fi

sqlplus -S /nolog <<EOF>/tmp/jbrestore_standby/jbrestore_standby.log
conn / as sysdba
set echo on
set feedback on

alter system set  control_files = '$NEWCONT' comment='Set by Johab' scope=spfile;
shutdown immediate;
startup nomount;
alter database mount;

EOF

else

sqlplus -S /nolog <<EOF>/tmp/jbrestore_standby/jbrestore_standby.log 
conn / as sysdba

alter database mount;

quit;

EOF

fi


LOG=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep "ORA-\|RMAN-" | grep -v "ORA-01109\|ORA-01507" | wc -l);
if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby/jbrestore_standby.log";exit; fi


nohup rman target / cmdfile /tmp/jbrestore_standby/datafiles.rcv msglog /tmp/jbrestore_standby/datafiles.log 1>>/dev/null 2>>/dev/null


export LIN=$(cat -n /tmp/jbrestore_standby/datafiles.log | grep  "===============" | tail -1 | awk {'print $1'})
export LINMAX=$(cat -n /tmp/jbrestore_standby/datafiles.log | tail -1 | awk {'print $1'})
export LINTAIL=$(echo $LIN+2-$LINMAX | bc)
export LINHEAD=$(echo $LINTAIL+4 | bc)

cat <<EOF>/tmp/jbrestore_standby/restore.rcv
run{
   allocate channel c1 device type disk;
EOF

if [ "$FSASM" -eq "1" ]; then
	cat /tmp/jbrestore_standby/datafiles.log | grep "\*\*\*" | awk '{print "   set newname for datafile " $1 " to '\'$DIR\'';"}'>>/tmp/jbrestore_standby/restore.rcv
	cat /tmp/jbrestore_standby/datafiles.log | tail $LINTAIL | head $LINHEAD | awk '{print "   set newname for tempfile " $1 " to '\'$DIR\'';"}'>>/tmp/jbrestore_standby/restore.rcv

else
	cat /tmp/jbrestore_standby/datafiles.log | grep "\*\*\*" | awk '{print "   set newname for datafile " $1 " to '\'$DIR'/" $3 $1 ".dbf'\'';"}'>>/tmp/jbrestore_standby/restore.rcv
	cat /tmp/jbrestore_standby/datafiles.log | tail $LINTAIL | head $LINHEAD | awk '{print "   set newname for tempfile " $1 " to '\'$DIR'/" $3 $1 ".dbf'\'';"}'>>/tmp/jbrestore_standby/restore.rcv

fi

cat <<EOF>>/tmp/jbrestore_standby/restore.rcv
   $CATALOG_RMAN
   restore database;
   switch datafile all;
   release channel c1;
}
EOF



sqlplus  /nolog <<EOF>>/tmp/jbrestore_standby/jbrestore_standby.log 
conn / as sysdba

create pfile='$ORACLE_HOME/dbs/init$ORACLE_SID.ora' from spfile;
quit;

EOF


find $ORACLE_HOME/dbs/init$ORACLE_SID.ora -exec sed -i '/_CONVERT/d' {} \; 
find $ORACLE_HOME/dbs/init$ORACLE_SID.ora -exec sed -i '/_convert/d' {} \; 


if [ "$FSASM" -eq "1" ]; then

DIROLD=$(cat /tmp/jbrestore_standby/datafiles.log | grep "SYSTEM" | awk {'print $NF'} | sed 's/\/\(.*\)//')
VALASM=$(echo $DIROLD | grep '+' | wc -l)
if [ "$VALASM" -eq "0" ]; then
	DIROLD=$(cat /tmp/jbrestore_standby/datafiles.log | grep "SYSTEM" | awk {'print $NF'} | sed 's/\/SYSTE\(.*\)//' | sed 's/\/syste\(.*\)//')
fi

cat <<EOF>>$ORACLE_HOME/dbs/init$ORACLE_SID.ora
DB_FILE_NAME_CONVERT='$DIROLD','$DIR'
LOG_FILE_NAME_CONVERT='$DIROLD','$DIR'
EOF

else
DIROLD=$(cat /tmp/jbrestore_standby/datafiles.log | grep "SYSTEM" | awk {'print $NF'} | sed 's/\/SYSTE\(.*\)//' | sed 's/\/syste\(.*\)//')
VALASM=$(echo $DIROLD | grep '+' | wc -l)
if [ "$VALASM" -eq "1" ]; then
	DIROLD=$(cat /tmp/jbrestore_standby/datafiles.log | grep "SYSTEM" | awk {'print $NF'} | sed 's/\/\(.*\)//')
fi


cat <<EOF>>$ORACLE_HOME/dbs/init$ORACLE_SID.ora
DB_FILE_NAME_CONVERT='$DIROLD','$DIR'
LOG_FILE_NAME_CONVERT='$DIROLD','$DIR'
EOF

fi





printf "%-100s" "Adicionando parametro DB_FILE_NAME_CONVERT e LOG_FILE_NAME_CONVERT."

sqlplus -S /nolog <<EOF>/tmp/jbrestore_standby/jbrestore_standby.log 
conn / as sysdba
shutdown immediate;

create spfile from pfile='$ORACLE_HOME/dbs/init$ORACLE_SID.ora';
startup nomount;
alter database mount;

quit;

EOF

LOG=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep "ORA-\|RMAN-" | grep -v "ORA-01109" | wc -l);
if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby/jbrestore_standby.log";exit; fi

printf "%-100s" "Restaurando o banco de dados."

nohup rman target / cmdfile /tmp/jbrestore_standby/restore.rcv msglog /tmp/jbrestore_standby/jbrestore_standby.log 1>>/dev/null 2>>/dev/null

LOG=$(cat /tmp/jbrestore_standby/jbrestore_standby.log | grep "ORA-\|RMAN-" | wc -l);
if [ "$LOG" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; echo "Analise o log /tmp/jbrestore_standby/jbrestore_standby.log";exit; fi

printf "%-100s" "Aplicando os archives."

cat <<EOF>/tmp/jbrestore_standby/recover.rcv
run{
	allocate channel c1 device type disk;
	recover database;
	release channel c1;
}

EOF

nohup rman target / cmdfile /tmp/jbrestore_standby/recover.rcv msglog /tmp/jbrestore_standby/recover.log 1>>/dev/null 2>>/dev/null

sqlplus -S /nolog <<EOF>/tmp/jbrestore_standby/jbrestore_standby.log
conn / as sysdba
pro alter database open RESETLOGS;
alter database open RESETLOGS;
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

pro create pfile from spfile;
create pfile from spfile;
pro
col NAME for a25
col value for a120
select NAME,VALUE from v\$parameter where name like '%name_convert';
pro


quit;

EOF

echo -e "[$MSG_FINALIZADO]"


nohup rman target / cmdfile /tmp/jbrestore_standby/datafiles.rcv msglog /tmp/jbrestore_standby/datafilesnew.log 1>>/dev/null 2>>/dev/null


LIN=$(cat -n /tmp/jbrestore_standby/datafilesnew.log | grep  "===============" | tail -1 | awk {'print $1'})
LINHEAD=$(echo $LIN-2 | bc)


cat /tmp/jbrestore_standby/datafilesnew.log | head -$LINHEAD >> /tmp/jbrestore_standby/jbrestore_standby.log

cat /tmp/jbrestore_standby/jbrestore_standby.log

rm -rf /tmp/jbrestore_standby 1>>/dev/null 2>>/dev/null

:wq!


alias jbrestore_standby='sh /tmp/jbrestore_standby.sh'

sleep 2

jbrestore_standby
