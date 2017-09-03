


vi recover_stand.rcv
i

Run {
   catalog start with '/u01/oracle/oradata/xatlasrh/archive' noprompt;
   recover database delete archivelog;
}

:wq!




[oracle@oraclestd ~]$ cat /u01/app/oracle/admin/ave/stby/recover.sh
#!/bin/bash
#
# TEOR Tecnologia Orientada
#
# Cliente.: Atlas
# Funcao..: Aplica os archives no Standby
# Arquivo.: recover.sh
# Sistema.: Oracle
#
#
# Verifica se ja existe um recover sendo executado
#
. ~/.bash_profile

BANCO1=$( ps -ef | grep pmo[n] | grep $1 | sed 's/.*mon_\(.*\)$/\1/' )

if [ "$1" = '' ]; then
   echo "                           "
   echo "Digite: sh recover.sh <SID> ou recover.sh <SID>" ;
   exit 1;

elif [ "$BANCO1" = "$1" ]; then
   BANCO=$1
else
   echo "Banco nao existe ou esta Down" ;
   exit 1;
fi



#
# Variaveis globais
#

export STDB_ARCH=/u01/oracle/oradata/xatlasrh/archive
export STDB_DATA=`date +%d%m%Y_%T`
export STDB_HOME=/u01/app/oracle/admin/xatlasrh/scripts
export STDB_LOG=$STDB_HOME/log/recover_$ORACLE_SID\_$STDB_DATA.log
export STDB_RCV=$STDB_HOME/recover_stand.rcv

#
# Variaveis ORACLE
#

export ORACLE_SID=$BANCO
export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export STDB_START=$(ps -ef | grep recover.sh | grep -v grep | sed 's/.*/ok/')

if [ "$STDB_START" != 'ok' ]
then
   rman target / nocatalog cmdfile $STDB_RCV msglog $STDB_LOG
   find $STDB_HOME/log/* +mtime +10 -exec rm -f {} \;
   find $STDB_ARCH/* +mtime +2 -exec rm -f {} \;
fi

exit;

#
# Fim
#






################################################################################################################################################
#                                                     TEOR TECNOLOGIA ORIENTADA                                                                #
#                                                       ROTINA DE SINCRONISMO                                                                  #
################################################################################################################################################
# Implementado em, 08 de Setembro de 2014.             
# Marcos Mota
# DBA Oracle - TEOR                            
# 
#+---------------------------------------------------------------------------------------------------------------------------------------------+
## APLICA ARCHIVE                                                                                                                              |
#+---------------------------------------------------------------------------------------------------------------------------------------------+
## BANCO ORCL                          
#+---------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour   MonthDay  Month  Weekday Command
# ------ ------ --------- ------ ------- ------------------------------------------------------------------------------------------------------+
  */40   *      *         *      *       /u01/app/oracle/admin/xatlasrh/scripts/recover.sh xatlasrh 1> /dev/null 2> /dev/null

  
  