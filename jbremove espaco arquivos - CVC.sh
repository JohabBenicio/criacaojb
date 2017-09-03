rm -f /tmp/exec_scripts.sh
vi /tmp/exec_scripts.sh
i

clear

read -p "Informe o numero do chamado: " CHAMADO
echo " "
ps -ef | grep smon | grep -iv "grep\|+asm\|/" | sed 's/.*mon_\(.*\)$/\1/'
echo " "
read -p "Informe o nome da instancia do banco de dados: " BANCO

VORATAB=$(grep "$BANCO:" /etc/oratab | wc -l)
if [ "$VORATAB" -eq "1" ]; then
export ORAENV_ASK=NO ; ORACLE_SID=$BANCO ; . oraenv; export ORAENV_ASK=YES;
else
export ORACLE_SID=$BANCO
fi

read -p "Informe o nome do usuario: " USUARIO
if [ -z "$USUARIO" ]; then
echo -e "\n\nInforme o nome do usuario.\n\n"
fi

read -p "Informe a senha do usuario $USUARIO: " SENHA
sqlplus -S $USUARIO/$SENHA <<EOF
show user
quit;
EOF
if [ "$?" -gt "0" ]; then
echo -e "\n\nSenha incorreta.\n\n"
exit;
fi


read -p "Calcular o tamanho do usuario Sim (1): " VCALC
if [ -z "$VCALC" ]; then
VCALC=0;
fi
if [ "$VCALC" -eq "1" ]; then
SIZE_SCHEMA=$(sqlplus -S $USUARIO/$SENHA <<EOF
set serveroutput on feedback off
declare
x number;
begin
select nvl(round(sum(bytes)/1024/1024),0) into x from user_segments;
dbms_output.put_line(x);
end;
/
disconnect;
quit;
EOF
)
fi
echo -e "\n"
read -p "Deseja aborta as execucoes caso uma execucao falhe? (encontrar \"ORA-\") Não(1): " ABORTP

echo -e "\nDiretorio atual: $PWD\n\n"
read -p "Informe o diretorio onde se encontra os arquivos .sql: " DIR
echo -e "\n"
if [ -z "$DIR" ] || [ ! -d "$DIR" ] ; then
    echo -e "\nInforme o diretorio onde se encontra os arquivos .sql\n"
    exit;
fi
ls -1 $DIR
echo -e "\n"
read -p "Informe o nome do arquivo, caso seja mais de um, separe com virgula (file 1.sql,file 2.sql) SEM O DIRETORIO: " FILE
echo -e "\n\n\n\n"
clear
if [ -z "$FILE" ]; then
    echo -e "\n\nInforme o nome dos arquivos .sql SEM O DIRETORIO\n\n"
    exit;
fi
VALID=$(echo $FILE | grep "/" | wc -l)
if [ "$VALID" -gt "0" ]; then
    echo -e "\n\nInforme o nome dos arquivos .sql SEM O DIRETORIO\n\n"
    exit;
fi

DIR_LOG=$DIR/log
SCRIP=$DIR/exec_scripts_TEOR.sh

if [ ! -z "$ABORTP" ]; then
if [ "$ABORTP" -eq "1" ]; then
echo "ABORTP=0">$SCRIP
else
echo "ABORTP=1">$SCRIP
fi
else
echo "ABORTP=1">$SCRIP
fi

if [ ! -d "$DIR_LOG" ]; then
mkdir $DIR_LOG

if [ "$?" -gt "0" ]; then
    echo -e "\n\nFalha ao tentar criar o diretorio: $DIR_LOG\n\n"
    exit
fi
fi


VORATAB=$(grep "$BANCO:" /etc/oratab | wc -l)
if [ "$VORATAB" -eq "1" ]; then
echo "export ORAENV_ASK=NO ; ORACLE_SID=$BANCO ; . oraenv; export ORAENV_ASK=YES;" >> $SCRIP
else
echo "export ORACLE_SID=$BANCO" >> $SCRIP
fi

echo -e "\n # ORACLE_SID => $ORACLE_SID \n" >> $SCRIP



echo $FILE | sed 's/,/\\\\n/g' | while read vfile
do
echo -e "$vfile" | while read vsql
do
NEW=$DIR/$(echo $vsql | sed  's/ //g')
LOG=$DIR_LOG/$CHAMADO\-$(echo $vsql | sed  's/ //g').txt

if [ -e "$DIR/$vsql" ]; then

FILE_SP=$( echo $DIR/$vsql | grep ' ' | wc -l)
if [ "$FILE_SP" -gt "0" ]; then
mv "$(echo $DIR/$vsql | sed 's/ /\ /g')" $NEW
fi
if [ ! -e "$NEW" ]; then
echo -e "\n\nFalha ao renomear o arquivo $DIR/$vsql -- para --> $NEW "
break
exit;
else
echo "$DIR/$vsql -- Renomeado para --> $NEW   Arquivo ok."

cat <<JHB>>$SCRIP
sqlplus $USUARIO/$SENHA <<EOF> $LOG
set serveroutput on;
set sqlblanklines on;
set timing on;
set echo on
pro
pro INSTANCIA $ORACLE_SID
pro
show user
select to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss') as start_date from dual;
@$NEW
select to_char (sysdate, 'dd/mm/yyyy hh24:mi:ss') as end_date from dual;
disconnect;
exit;
EOF

if [ "\$ABORTP" -eq "1" ]; then
VALID=\$(cat $LOG | grep "ORA-" | wc -l)
if [ "\$VALID" -gt "0" ]; then
cat <<JHB90

Erro na execução do script "$NEW":
\$(cat $LOG | grep -B10 "ORA-" )

Proximas execuções abortadas!

JHB90
sed -i 's/$USUARIO\/$SENHA/$USUARIO\/XXXXXXX/g' $SCRIP
exit;
fi

fi

JHB
fi
else
echo "$NEW --> Arquivo nao encontrado."
fi
done
done


if [ -e "$SCRIP" ]; then
echo -e "\n\nAguarde 5 segundos..."
sleep 5
less $SCRIP
chmod 750 $SCRIP
cd $DIR
echo -e "\n\n$SCRIP\n\n"

cat <<EOF>>$SCRIP

sed -i 's/$USUARIO\/$SENHA/$USUARIO\/XXXXXXX/g' $SCRIP
sed -i '/sed/d' $SCRIP

EOF
fi


if [ "$VCALC" -eq "1" ]; then
if [ "$SIZE_SCHEMA" -lt "51200" ]; then

sqlplus -S / as sysdba <<EOF
#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Consulta de verifiucação do banco de dados
#-- Nome do arquivo     : jbdb_ins.sql
#-- Data de criação     : 02/04/2014
#-- -----------------------------------------------------------------------------------
pro
pro
pro #######################################
pro # DADOS DO BANCO DE DADOS
set feedback off;
set lines 200;
col STATUS for a15
col "OPEN MODE" for a11
col INSTANCIA for a15
col VERSAO for a100
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
    INS.PARALLEL RAC,
    INS.STATUS,
    DAT.NAME DATABASE,
    DAT.OPEN_MODE "OPEN MODE",
    DAT.LOG_MODE "MODO ARCHIVE",
    VER.BANNER VERSAO
FROM V\$INSTANCE INS, V\$DATABASE DAT, V\$VERSION VER
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';
set feedback on;

pro
pro
pro #######################################
pro # DIRECTORY DO BANCO DE DADOS
-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2012 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : dba_directories.sql                                             |
-- | CLASS    : Database Administration                                         |
-- | PURPOSE  : Provides a summary report of all Oracle Directory objects.      |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET ECHO OFF FEEDBACK 6 HEADING ON LINESIZE 200 PAGESIZE 200 TERMOUT ON TIMING OFF TRIMOUT ON TRIMSPOOL ON VERIFY OFF
CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES
COLUMN owner            FORMAT a10   HEADING 'Owner'
COLUMN directory_name   FORMAT a30   HEADING 'Directory Name'
COLUMN directory_path   FORMAT a85   HEADING 'Directory Path'
SELECT owner, directory_name, directory_path
FROM dba_directories
ORDER BY owner, directory_name;

pro
pro
pro #######################################
pro # TAMANHO DO SCHEMA
pro
pro $SIZE_SCHEMA MB
pro
pro
disconnect;
quit;
EOF


echo "#######################################"
echo -e "# BACKUP LOGICO \n"


echo expdp \\\'/ as sysdba \\\' directory=DIRECTORY_DB schemas=$USUARIO dumpfile=expdp_$USUARIO\_$(date +'%d%m%Y').dmp logfile=expdp_$USUARIO\_$(date +'%d%m%Y').log consistent=y
echo -e "\n\n"

fi
fi
