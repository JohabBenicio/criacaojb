

rm -f /tmp/jbcorrig_bkp_teor.sh

vi /tmp/jbcorrig_bkp_teor.sh
i

clear

readonly ODU_COLOR_NORM="\033[0m"
readonly ODU_COLOR_BOLD="\033[1m"
readonly ODU_COLOR_GREEN="\033[1;32;40m"
readonly ODU_COLOR_RED="\033[1;31;40m"

export MSG_SUCESSO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"Ok"$ODU_COLOR_NORM"
export MSG_FALHA="$ODU_COLOR_BOLD$ODU_COLOR_RED"Falha"$ODU_COLOR_NORM"
export MSG_FINALIZADO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"FINALIZADO"$ODU_COLOR_NORM"

LINUX=$(uname | grep "Linux" | wc -l)
crontab -l | grep -i "# BANCO" | uniq | sort
if [ "$LINUX" -eq "0" ]; then
  echo -e "\n\nScript criado e homologado para S.O. Linux! \n\n"
  exit;
fi
echo -e "\n"
ps -ef | grep smon | grep -v "grep\|asm" | sed 's/.*mon_\(.*\)$/\1/' 
echo -e "\n"
read -p "Informe o nome da instancia: " ORACLE_SID

VINSTANCIA=`ps -ef | grep smon | grep $ORACLE_SID 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$ORACLE_SID( |$)" | wc -l`

if [ "$VINSTANCIA" -eq "0" ]; then echo -e "\n\ninstancia não esta no ar! \n\n";  exit; fi

POSSIVEL_HOME=$(crontab -l | grep "$ORACLE_SID" | grep "bkp_full" | awk '{ if ($6 == "sh") print $7; else print $6}' | sed 's/\/sh\(.*\)//' ) 

if [ ! -z "$POSSIVEL_HOME" ]; then
  echo -e "\n\n $POSSIVEL_HOME \n\n"
fi

read -p "Informe o diretório onde será armazenado os scripts do backup: " BACKUP_HOME

if [ ! -d "$BACKUP_HOME" ]; then echo -e "\n\nEste diretorio nao existe! \n\n"; exit; fi

export BACKUP_DIR=$(cat $BACKUP_HOME/data/bkp_full.rcv | grep -i "format '" | grep -i "\(.*\)full\(.*\)" | sed 's/\/full\(.*\)//' | sed 's/\/FULL\(.*\)//' | cut -f2 -d "'")

if [ ! -d "$BACKUP_DIR" ]; then echo -e "\n\nEste diretorio nao existe! \n---->$BACKUP_DIR\n"; exit; fi

cp $BACKUP_HOME/data/bkp_full.rcv $BACKUP_HOME/data/bkp_full.rcv_$(date +"%d%m%Y").bkp

rm -f $BACKUP_HOME/data/bkp_full.rcv_$(date +"%d%m%Y").bkp.gz

gzip $BACKUP_HOME/data/bkp_full.rcv_$(date +"%d%m%Y").bkp

if [ "$?" -gt "0" ]; then
  echo -e "\n\nErro ao compactar! \n\n";
  exit;
fi

cat <<EOF> $BACKUP_HOME/data/bkp_full.rcv

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
#
# Funcao..: Realiza backup do banco de dados via RMAN
# Arquivo.: backup.rcv
#
#
# Executa o Backup do Banco de Dados
#

run
{
  allocate channel c1 device type disk maxpiecesize=4096M;
  
  backup as compressed backupset
  format '$BACKUP_DIR/full_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_FULL' database;
  sql 'alter system switch logfile';
  backup as compressed backupset
  format '$BACKUP_DIR/arch_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_ARCHIVELOG' archivelog all not backed up 1 times skip inaccessible;
  backup as compressed backupset  
  format '$BACKUP_DIR/spfile_%s_%p_%t' tag='BKP_SPFILE' spfile ;
  backup as compressed backupset 
  format '$BACKUP_DIR/control_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_CONTROLFILE' current controlfile;  
  
  release channel c1;
}

#
# Gera o backup do controlfile em formato texto
#

SQL "Alter Database Backup ControlFile To Trace As ''$BACKUP_DIR/controlfile_trace_$ORACLE_SID.sql'' Reuse" ;

#
# Gera um backup do Spfile se Utilizado
#

SQL "Create Pfile=''$BACKUP_DIR/pfile_$ORACLE_SID.ora'' From Spfile";

Exit

#
# Fim
#


EOF


echo -e "\nArquivo atualizado: $BACKUP_HOME/data/bkp_full.rcv\n\n"

cat $BACKUP_HOME/data/bkp_full.rcv

:wq!

sh /tmp/jbcorrig_bkp_teor.sh
