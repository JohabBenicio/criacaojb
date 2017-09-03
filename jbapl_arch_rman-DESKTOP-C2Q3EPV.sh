

vi /u01/app/oracle/admin/scripts/standby/deleteArchives.sh
i

#!/bin/bash

# Remove os archives jah aplicados ao DataGuard

source ~/.bash_profile

cd /u01/app/oracle/admin/scripts/standby

sqlplus -S / as sysdba << EOF
set term off
set echo off
set trimspool on
set feed off
set head off
set pages 9999 lines 200
spool deleteArchives.rcv
prompt run {
select '   allocate channel c1 device type disk ;' from dual ;
select '   delete noprompt archivelog sequence '||sequence#||' thread '||thread#||' ;'
from v\$archived_log
where applied = 'YES' and deleted = 'NO'
order by thread#, sequence# ;
prompt }
prompt exit
spool off
exit
EOF

rman target / nocatalog log deleteArchives.log @deleteArchives.rcv







========================================================================================================================================
========================================================================================================================================
========================================================================================================================================
==================================                                                              ========================================
==================================                     COPIA DOS ARCHIVES                       ========================================
==================================                                                              ========================================
========================================================================================================================================
========================================================================================================================================
========================================================================================================================================


export STDB_HOME=/oracle/admin/scripts/standby
mkdir -p $STDB_HOME



rm -f $STDB_HOME/ExCopArch.sh

vi $STDB_HOME/ExCopArch.sh
i


#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 105
# (11) 3797-8299
# São Paulo - SP
#
# Atualizado em 24/10/2014
#
# Efetua copia dos archives no standby
#
# Versao para Linux
# $1 ORACLE_SID

#
# Inicio
#

#-- -------------------------------------------------------------------------------
#-- Carregar variaveis do bash_profile
#-- -------------------------------------------------------------------------------

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi


#-- -------------------------------------------------------------------------------
#-- Local onde os scripts estao no servidor
#-- -------------------------------------------------------------------------------
export STDB_HOME=/oracle/admin/scripts/standby

#-- -------------------------------------------------------------------------------
#-- Analisar se instancia esta no ar
#-- -------------------------------------------------------------------------------
BANCO=`ps -ef | grep smon | grep $1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )$1( |$)"`

if [ -z "$1" ]; then
   echo "Digite: sh ExCopArch.sh <SID> ou ExCopArch.sh <SID>" ;
   exit

elif [ "$BANCO" = "$1" ]; then
   export ORACLE_SID=$1

else
   echo "Banco nao existe" ;
   exit

fi

#-- -------------------------------------------------------------------------------
#-- IP do servidor de standby
#-- -------------------------------------------------------------------------------
export STDB_IP=atlasdb01

#-- -------------------------------------------------------------------------------
#-- Log da copia das pecas de backup
#-- -------------------------------------------------------------------------------
export STDB_DATA=`date +%d%m%Y_%T`
export STDB_LOG=$STDB_HOME/log/copia_archive_$ORACLE_SID\_$STDB_DATA.log

#-- -------------------------------------------------------------------------------
#-- Local das pecas de backup/archive Producao
#-- -------------------------------------------------------------------------------
export DIR_BKP=/oradata/archive/mat1

#-- -------------------------------------------------------------------------------
#-- Local onde vai ser tranferido as pecas no servidor de standby
#-- -------------------------------------------------------------------------------
export STDB_DIR_BKP=/u02/oracle/oradata/mat1/archive

#-- -------------------------------------------------------------------------------
#-- Caracter set do S.O.
#-- -------------------------------------------------------------------------------
export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"

#-- -------------------------------------------------------------------------------
#-- Nome do arquivo para procurar no find
#-- -------------------------------------------------------------------------------
FNAME=$DIR_BKP/*.dbf

#-- -------------------------------------------------------------------------------
#-- Analisar se o processo de copia esta em execucao
#-- -------------------------------------------------------------------------------
export STDB_STAT=$(ps -ef | grep "$STDB_IP $STDB_DIR_BKP" | grep -v grep | wc -l)


if [ "$STDB_STAT" -gt "0" ]
then
   echo "Ja esta copiando."
   exit;

fi

PERM=640
HEADER=$(find $FNAME 2>>/dev/null -type f -perm $PERM -print | wc -l)

if [ "$HEADER" -eq "0" ]; then
PERM=660
HEADER=$(find $FNAME 2>>/dev/null -type f -perm $PERM -print | wc -l)
fi

if [ "$HEADER" -eq "0" ]; then
   HOR_EXEC=`date`
   echo "Neste momento nao existe novas pecas de backup -- $HOR_EXEC"
   echo "Neste momento nao existe novas pecas de backup -- $HOR_EXEC" >> $STDB_HOME/log/copia_archive_$ORACLE_SID\_none.log
   exit
fi

echo ". Copiando archives para o servidor StandBy ($STDB_IP) ..." >> $STDB_HOME/log/copia_archive_$ORACLE_SID.log
find $FNAME 2>>/dev/null -type f -perm $PERM -print | while read arquivo
do
   echo "$arquivo -> $STDB_IP... "
      scp -pq $arquivo $STDB_IP:$STDB_DIR_BKP
      if [ $? -eq 0 ]; then
         HOR_EXEC=`date`
         chmod 600 $arquivo
         echo "$arquivo -> $STDB_IP, Ok. -- $HOR_EXEC"
         echo "$arquivo -> $STDB_IP, Ok. -- $HOR_EXEC" >> $STDB_HOME/log/copia_archive_$ORACLE_SID.log
      else
         HOR_EXEC=`date`
         echo "$arquivo -> $STDB_IP, ERRO.  -- $HOR_EXEC"
         echo "$arquivo -> $STDB_IP, ERRO.  -- $HOR_EXEC" >> $STDB_HOME/log/copia_archive_$ORACLE_SID\_erro.log
         exit
      fi
done

exit



:wq!





chmod 775 $STDB_HOME/ExCopArch.sh

ls -l $STDB_HOME/log

#+------------------------------------------------------------------------------------------------------------------------------+
## COPIA DOS ARCHIVES PARA STANDBY                                                                                              |
#+------------------------------------------------------------------------------------------------------------------------------+
# BANCO MAT1
#+------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- -----------------------------------------------------------------------------------------+
  */35   *     *        *      *       /oracle/admin/scripts/standby/ExCopArch.sh mat11 1>/dev/null 2>/dev/null







========================================================================================================================================
========================================================================================================================================
==================================================     APLICA ARCHIVE VIA SQLPLUS    ===================================================
========================================================================================================================================
========================================================================================================================================


export STDB_HOME=/u01/app/oracle/admin/prodb/scripts/standby


rm -f $STDB_HOME/jbpl_arc.sh

vi $STDB_HOME/jbpl_arc.sh
i

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 105
# (11) 3797-8299
# São Paulo - SP
#
# Efetua implementação dos archives no standby
#
# Versao para Linux
# $1 ORACLE_SID

#
# Inicio
#

BASH=~/.bash_profile

if [ -e "$BASH" ]; then
  . $BASH
else
  BASH=~/.profile
  . $BASH
fi

BANCO=`ps -ef | grep smon | grep $1 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$1( |$)"`

if [ "$1" = '' ]; then
   echo -e "\n\nDigite: sh jbpl_arc.sh <SID> ou jbpl_arc.sh <SID>\n\n"
   exit
elif [ "$BANCO" = "$1" ]; then
   export ORACLE_SID=$BANCO
else
   echo "Banco nao existe"
   exit
fi

# Variaveis Globais

export STDB_HOME=/u01/app/oracle/admin/prodb/scripts/standby
export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export STDB_DATA=`date +%d%m%Y_%T`
export MAILSINC=$STDB_HOME/log/recover_$ORACLE_SID\_24horas.log
export STDB_RCV=$STDB_HOME/recover_stand.sql
export STDB_DIR_BKP=/u02/oraarch/prod
export STDB_START=$(ps -ef | grep $STDB_RCV | grep -v grep | wc -l )

echo -e "\n\n::Inicio da Atualizacao do banco de dados `date +%d/%m/%Y-%T`\n" >>$MAILSINC

if [ -e "$STDB_RCV" ]; then
   rm -f $STDB_RCV
fi

sqlplus -S sys/sysusd2003' as sysdba' <<EOF> $STDB_RCV

set lines 200
set feedback off
set serveroutput on
declare
   vsinc varchar2(90);
begin
   select 'recover automatic standby database until time '''||to_char(sysdate-1,'YYYY-MM-DD:HH24:MI:SS')||''';' into vsinc from dual;
   dbms_output.put_line(vsinc);
end;
/
EOF


if [ "$STDB_START" -eq "0" ]
then
sqlplus -S sys/sysusd2003' as sysdba' <<EOF
@$STDB_RCV
EOF
else
   echo -n "A sincronizacao ja esta ativa! Saindo - `date +%d/%m/%Y-%T` ..."  >>$MAILSINC
   exit;
fi


function check {
sqlplus -S sys/sysusd2003@'prod as sysdba' <<EOF

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

sqlplus -S sys/sysusd2003' as sysdba' <<EOF

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
echo -e "ARCHIVE PROD: $NUM1"  >>$MAILSINC
echo "ARCHIVE STANDBY: $NUM2"  >>$MAILSINC
echo -e "Diferenca de archives $RESULTADO."  >>$MAILSINC


find $STDB_HOME/log/* -mtime +3 -exec rm -f {} \;
#find $STDB_DIR_BKP/* -mtime +5 -exec rm -f {} \;


if [ -e "$STDB_RCV" ]; then
   rm -f $STDB_RCV
fi

exit



:wq!













chmod 775 jbpl_arc.sh recover_stand.rcv



##################################################################################################################################
#                                              TEOR TECNOLOGIA ORIENTADA                                                         #
#                                                ROTINA DE SINCRONISMO                                                           #
##################################################################################################################################
# Implementado em, 22 de Outubro de 2014.
# Johab Benicio de Oliveira
# DBA Oracle - TEOR
#
#+------------------------------------------------------------------------------------------------------------------------------+
## APLICA ARCHIVE                                                                                                               |
#+------------------------------------------------------------------------------------------------------------------------------+
## BANCO ORCL
#+------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour   MonthDay  Month  Weekday Command
# ------ ------ --------- ------ ------- ---------------------------------------------------------------------------------------+
  00     00-23  *         *      *       /u01/app/oracle/admin/orcl/scripts/jbpl_arc.sh orcl 1> /dev/null 2> /dev/null




























========================================================================================================================================
========================================================================================================================================
==================================================     APLICA ARCHIVE VIA RMAN    ======================================================
========================================================================================================================================
========================================================================================================================================








rm -f /tmp/jbconf_apl_aarch.sh

vi /tmp/jbconf_apl_aarch.sh
i


function f_instance (){
clear
echo -e "Instancias presentes no Servidor\n"
COUNT=0;
unset BANCO;
unset DATABASE;
unset INST1; unset INST2; unset INST3; unset INST4; unset INST5; unset INST6;
unset INST7; unset INST8; unset INST9; unset INST10; unset INST11; unset INST12;

while read instance
do
COUNT=$(echo $COUNT+1 | bc);
export INST$COUNT=$instance
echo "$COUNT: $instance"
done < <(ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/')

echo " "
read -p "Informe o nome da instancia do banco de dados: " NUM_DB

case $NUM_DB in
    1) BANCO=$INST1;;
    2) BANCO=$INST2 ;;
    3) BANCO=$INST3 ;;
    4) BANCO=$INST4 ;;
    5) BANCO=$INST5 ;;
    6) BANCO=$INST6 ;;
    7) BANCO=$INST7 ;;
    8) BANCO=$INST8 ;;
    9) BANCO=$INST9 ;;
    10) BANCO=$INST10;;
    11) BANCO=$INST11;;
    12) BANCO=$INST12;
esac

if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
echo " "
read -p "Escreva o nome da instancia do banco de dados: " BANCO
fi

if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
f_instance
else
ORACLE_SID=$BANCO
fi
}

f_instance

read -p "Informe onde se encontra as pecas de backup: " DIR_BKP

read -p "Find TNSNAMES? Sim (1): " FINDTNS

if [ ! -z "$FINDTNS" ] && [ "$FINDTNS" -eq "1" ] 2>/dev/null ; then

echo -e "\n"

find $ORACLE_BASE -name "tnsnames.ora" 2>>/dev/null | grep -vi "samples" | while read tnsnames
do
cat $tnsnames | grep '=' -1 | grep -vi 'EXTPROC_CONNECTION_DATA\|DESCRIPTION\|ADDRESS_LIST\|ADDRES\|CONNECT_DATA\|(\|)' | sed "s/=//"
done

echo -e "\n"

fi

read -p "Informe o TNS do producao: " TNS_STD

read -p "Informe a senha do owner sys \"producao\": " PASS


if [ -d "$ORACLE_BASE/admin/scripts" ]; then
    export STDB_HOME=$ORACLE_BASE/admin/scripts/standby/$ORACLE_SID
    mkdir -p $STDB_HOME/log 2>>/dev/null
    mkdir -p $STDB_HOME/rcv 2>>/dev/null

elif [ -d "$ORACLE_BASE/admin/script" ]; then
    export STDB_HOME=$ORACLE_BASE/admin/script/standby/$ORACLE_SID
    mkdir -p $STDB_HOME/log 2>>/dev/null
    mkdir -p $STDB_HOME/rcv 2>>/dev/null

else
    export STDB_HOME=$ORACLE_BASE/admin/scripts/standby/$ORACLE_SID
    mkdir -p $STDB_HOME/log 2>>/dev/null
    mkdir -p $STDB_HOME/rcv 2>>/dev/null

fi



cat <<JHB> $STDB_HOME/AplArch.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 105
# (11) 3797-8299
# São Paulo - SP
#
# Efetua implementação dos archives no standby
#
# Versao para Linux
# $1 ORACLE_SID

#
# Inicio
#

export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export PATH=$PATH

BANCO=\`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |$)"\`

if [ "\$1" = '' ]; then
   echo -e "\n\nDigite: sh AplArch.sh <SID> ou AplArch.sh <SID>\n\n"
   exit
elif [ "\$BANCO" = "\$1" ]; then
   export ORACLE_SID=\$BANCO
else
   echo "Banco nao existe"
   exit
fi

# Variaveis Globais

export STDB_HOME=$STDB_HOME
export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export STDB_DATA='date +%d%m%Y_%T'
export LOGSTAND=\$STDB_HOME/log/recover_\$ORACLE_SID.log

export STDB_CTL=\$STDB_HOME/rcv/catalog_stand.rcv
export STDB_RCV=\$STDB_HOME/rcv/recover_stand.rcv
export STDB_DEL=\$STDB_HOME/rcv/del_arch.rcv

export CTL_LOG=\$STDB_HOME/log/catalog_stand.log
export RCV_LOG=\$STDB_HOME/log/recover_stand.log
export DEL_LOG=\$STDB_HOME/log/del_arch.log
export DEL_HST=\$STDB_HOME/log/del_arch_hst.log

export STDB_DIR_BKP=$DIR_BKP/complet
export STDB_DIR_BKP_COPY=$DIR_BKP

if [ ! -d "\$STDB_DIR_BKP" ]; then
   mkdir -p \$STDB_DIR_BKP
fi

export STDB_START=\$(ps -ef | grep "\$STDB_RCV\|\$STDB_DEL\|\$STDB_CTL" | grep -v grep | wc -l )

find \$STDB_DIR_BKP -mtime +2 -exec rm -f {} \;

if [ "\$STDB_START" -gt "0" ]
then
   echo -e "\nA sincronizacao ja esta ativa! Saindo - \`$STDB_DATA\` ..."  >>\$LOGSTAND
   exit;
fi

find \$STDB_DIR_BKP_COPY/arch* -mmin +1 -exec mv {} \$STDB_DIR_BKP/ \;

echo -e "\n\n::Inicio da Atualizacao do banco de dados \`date +%d/%m/%Y-%T\`\n" >>\$LOGSTAND

if [ ! -e "\$STDB_CTL" ]; then
cat <<EOF> \$STDB_CTL
  run{
    allocate channel c1 device type disk;
    catalog start with '\$STDB_DIR_BKP' noprompt;
    release channel c1;
  }
EOF
fi

if [ ! -e "\$STDB_RCV" ]; then
cat <<EOF> \$STDB_RCV
  run{
    allocate channel c1 device type disk;
    recover database delete archivelog;
    release channel c1;
  }
EOF
fi


rman target \'/ as sysdba \' cmdfile \$STDB_CTL msglog \$CTL_LOG
rman target \'/ as sysdba \' cmdfile \$STDB_RCV msglog \$RCV_LOG

sqlplus -S /nolog <<EOF>\$STDB_DEL
conn / as sysdba
set serveroutput on feedback off
begin
dbms_output.put_line('run{'||chr(10)||'allocate channel c1 device type disk;');
dbms_output.put_line('crosscheck backup;');
dbms_output.put_line('crosscheck archivelog all;');
dbms_output.put_line('crosscheck copy;');
for x in (
select a.sequence#,a.thread#
from v\\\$archived_log a, v\\\$log_history b
where a.name is not null
  and a.sequence#=b.sequence#
  and a.thread#=b.thread#
)loop
dbms_output.put_line('delete force noprompt archivelog sequence '||x.sequence#||' thread '||x.thread#||';');
end loop;
dbms_output.put_line('delete noprompt backup completed before ''sysdate-1'';');
dbms_output.put_line('}');
end;
/
quit;
EOF


function producao {
sqlplus -S sys/$PASS@'$TNS_STD as sysdba' <<EOF

set serveroutput on
set feedback off;
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

function standby {

sqlplus -S /nolog <<EOF
conn / as sysdba
set feedback off;
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


PRD=\$(producao)
STD=\$(standby)

RESULTADO=\$(expr \$PRD - \$STD )
echo -e "ARCHIVE PROD: \$PRD"  >>\$LOGSTAND
echo "ARCHIVE STANDBY: \$STD"  >>\$LOGSTAND
echo -e "Diferenca de archives \$RESULTADO."  >>\$LOGSTAND

echo "Inicio do purge de archives... \$(date)" >>\$LOGSTAND

rman target \'/ as sysdba \' cmdfile \$STDB_DEL msglog \$DEL_LOG

echo "Fim do purge de archives. $(date)" >>\$LOGSTAND

cat <<EOF>>\$DEL_HST


Delete \$(date)

EOF
cat \$DEL_LOG | grep -1 "archive log filename" >>\$DEL_HST
exit



JHB

chmod 755 $STDB_HOME/AplArch.sh

cat <<FFF

##################################################################################################################################
#                                              TEOR TECNOLOGIA ORIENTADA                                                         #
#                                                ROTINA DE SINCRONISMO                                                           #
##################################################################################################################################
# Implementado em, `date +"%d %B de %Y"`.
# Johab Benicio de Oliveira
# DBA Oracle - TEOR
#
#+------------------------------------------------------------------------------------------------------------------------------+
## APLICA ARCHIVE                                                                                                               |
#+------------------------------------------------------------------------------------------------------------------------------+
## BANCO $ORACLE_SID
#+------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour   MonthDay  Month  Weekday Command
# ------ ------ --------- ------ ------- ---------------------------------------------------------------------------------------+
  */30   *      *         *      *       $STDB_HOME/AplArch.sh $ORACLE_SID

FFF



:wq!



