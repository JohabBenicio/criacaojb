

rm -f /tmp/jbexec_sql
vi /tmp/jbexec_sql
i
#!/bin/bash

clear
unset CHAMADO
DIR_LOC=$(basename $PWD)
VALID=$(echo $DIR_LOC | grep "cst\|chamado" | wc -l)
if [ "$VALID" -gt "0" ]; then
CHAMADO=${DIR_LOC#*cst};CHAMADO=${CHAMADO#*chamado}
else
CHAMADO=0
fi

VALJB=$1

if [ "$CHAMADO" -eq "0" ]; then
read -p "Informe o numero do chamado: " CHAMADO

fi

read -p "Informe seu nome: " VALJB

VALID=0


function f_instance (){


## ##################################################################################################################################
## ##################################################################################################################################
##  Nome das instancias
## ##################################################################################################################################
## ##################################################################################################################################
clear

echo -e "Instancias presentes no Servidor\n"
COUNT=0;
unset BANCO;

while read instance
do
COUNT=$(($COUNT+1));
export INST$COUNT=$instance
echo "$COUNT: $instance"
done < <(ps -ef | grep ora_smon | grep -iv "grep" | grep -iv "/" | sed 's/.*smon_\(.*\)$/\1/' | sort)

echo " "
read -p "Informe o nome da instancia do banco de dados: " NUM_DB

for i in {1..99}
do
case $NUM_DB in
    $i) BANCO=$(eval echo \$INST$NUM_DB)
esac
done

if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep ora_smon | sed 's/.*smon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
echo " "
read -p "Escreva o nome da instancia do banco de dados: " BANCO
fi

if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep ora_smon | sed 's/.*smon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
f_instance
fi

}

f_instance



VORATAB=$(grep "$BANCO:" /etc/oratab | wc -l)
if [ "$VORATAB" -eq "1" ]; then
export ORAENV_ASK=NO ; ORACLE_SID=$BANCO ; . oraenv; export ORAENV_ASK=YES;
else
export ORACLE_SID=$BANCO
fi



## ##################################################################################################################################
## ##################################################################################################################################
##  Usuario e senha
## ##################################################################################################################################
## ##################################################################################################################################
clear

cat <<EOF
Voce vai executar o script com usuario SYS?
Digite [ 1 ] Para sim
Digite [ ENTER ] Para NAO

EOF
read -p "Digite sua escolha: " VALID_USU

if [ ! -z "$VALID_USU" ]; then
if [ "$VALID_USU" -eq "1" ]; then
VCONN="/ as sysdba"
fi
fi

if [ $VALJB == j ]; then
VCONN="apps/smurf"

elif [ -z "$VALID_USU" ]; then
read -p "Informe o nome do usuario: " USUARIO

if [ -z "$USUARIO" ]; then
echo -e "\n\nInforme o nome do usuario.\n\n"
exit
fi

read -p "Informe a senha do usuario $USUARIO: " SENHA

VCONN="$USUARIO/$SENHA"

fi



sqlplus -S $VCONN <<EOF
show user
quit;
EOF
if [ "$?" -gt "0" ]; then
echo -e "\n\nSenha incorreta.\n\n"
exit;
fi


sqlplus -S / as sysdba<<EOF>/tmp/nls_$ORACLE_SID.txt
col NLS_LANG for a60
select 'export NLS_LANG=' || a.NLS_LANGUAGE || '_' || b.NLS_TERRITORY || '.' || c.NLS_CHARACTERSET NLS_LANG from
(SELECT VALUE$ NLS_LANGUAGE FROM SYS.PROPS$ WHERE NAME = 'NLS_LANGUAGE') a,
(SELECT VALUE$ NLS_TERRITORY FROM SYS.PROPS$ WHERE NAME = 'NLS_TERRITORY') b,
(SELECT VALUE$ NLS_CHARACTERSET FROM SYS.PROPS$ WHERE NAME = 'NLS_CHARACTERSET') c;
quit;
EOF



## ##################################################################################################################################
## ##################################################################################################################################
##  Calcular tamanho do usuario
## ##################################################################################################################################
## ##################################################################################################################################
clear

echo -e "Deseja calcular o tamanho do usuario para realizacao do backup logico?\n"
read -p "Sim [1] ou Nao [ENTER]: " VCALC
if [ -z "$VCALC" ]; then
VCALC=0;
fi
if [ "$VCALC" -eq "1" ]; then
SIZE_SCHEMA=$(sqlplus -S $VCONN <<EOF
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


## ##################################################################################################################################
## ##################################################################################################################################
##  Cancelar em caso de falhas
## ##################################################################################################################################
## ##################################################################################################################################
clear

echo -e "Deseja cancelar as proximas execucoes caso uma execucao falhe?     (encontrar \"ORA-\")\n"
read -p "Nao [1] ou Sim [ENTER]: " ABORTP

clear

if [ $VALJB == j ]; then
DIR=$PWD
else
cat <<EOF
Informe o diretorio onde se encontra os arquivos .sql

Digite [ENTER] para selecionar diretorio atual: $PWD


EOF

read -p "Informe sua escolha: " DIR

if [ -z "$DIR" ]; then
DIR=$PWD
fi

fi
echo -e "\n"
if [ -z "$DIR" ] || [ ! -d "$DIR" ] ; then
    clear
    echo -e "\nInforme o diretorio onde se encontra os arquivos .sql\n"
    exit;
fi


## ##################################################################################################################################
## ##################################################################################################################################
##  Arquivos do diretorio
## ##################################################################################################################################
## ##################################################################################################################################
clear

cat <<EOF
Arquivos existentes no local mencionado:

Informe o nome do arquivo, caso seja mais de um, separe com virgula (file 1.sql,file 2.sql)

Ons.: SEM O DIRETORIO

EOF
ls -1 $DIR

read -p "Informe a lista: " FILE


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
sqlplus $VCONN <<EOF> $LOG
set serveroutput on size unlimited;
set define off;
set sqlblanklines on;
set timing on;
set echo on
set linesize 200
set pages 9999
set long 99999
pro
pro INSTANCIA $ORACLE_SID
pro
show user
pro
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

Erro na execucao do script "$NEW":
\$(cat $LOG | grep -B10 "ORA-" )

Proximas execucoes abortadas!

JHB90

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
echo -e "\n\n $SCRIP\n\n nohup $SCRIP & \n\n"

cat /tmp/nls_$ORACLE_SID.txt

echo -e "\n\n"


fi


if [ "$VCALC" -eq "1" ]; then
if [ "$SIZE_SCHEMA" -lt "51200" ]; then

sqlplus -S / as sysdba <<EOF
#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descricao           : Consulta de verifiucacao do banco de dados
#-- Nome do arquivo     : jbdb_ins.sql
#-- Data de criacao     : 02/04/2014
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


# Fim

