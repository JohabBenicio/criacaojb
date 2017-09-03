#-- /backup/logix/logico


rm -f /tmp/jbconf_bkp_logico.sh

vi /tmp/jbconf_bkp_logico.sh
i
#!/bin/bash


clear

if [ -z "$ORACLE_BASE" ]; then
cat <<EOF


Favor setar a variavel ORACLE_BASE para continuar a configuracao do script.

Processo abortado!



EOF
exit;
fi
NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"

echo " "
ps -ef | grep smon | grep -iv "grep\|+\|-\|/" | sed 's/.*mon_\(.*\)$/\1/'
echo " "



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
done < <(ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | sort)

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


read -p "Quantos dias de retencao? : " VRENT
read -p "Deseja compactar as peças de backup? Sim (1): " VCOMP

if [ "$VCOMP" != "1" ]; then
VCOMP=2
fi

sqlplus -S / as sysdba <<EOF
SET TERMOUT OFF;
COLUMN current_instance NEW_VALUE current_instance NOPRINT;
SELECT rpad(instance_name, 17) current_instance FROM v\$instance;
SET TERMOUT ON;
PROMPT +------------------------------------------------------------------------+
PROMPT | Report   : Oracle Directories                                          |
PROMPT | Instance : &current_instance                                           |
PROMPT +------------------------------------------------------------------------+

SET ECHO        OFF
SET FEEDBACK    6
SET HEADING     ON
SET LINESIZE    180
SET PAGESIZE    50000
SET TERMOUT     ON
SET TIMING      OFF
SET TRIMOUT     ON
SET TRIMSPOOL   ON
SET VERIFY      OFF

CLEAR COLUMNS
CLEAR BREAKS
CLEAR COMPUTES

COLUMN owner            FORMAT a10   HEADING 'Owner'
COLUMN directory_name   FORMAT a30   HEADING 'Directory Name'
COLUMN directory_path   FORMAT a85   HEADING 'Directory Path'

SELECT
    owner
  , directory_name
  , directory_path
FROM
    dba_directories
ORDER BY
    owner
  , directory_name;
quit;
EOF

read -p "Informe o nome para variavel DIRECTORY: " VDIRECTORY
read -p "Informe o diretorio onde sera armazenado as peças de backup: " DIRBKP

if [ -d "$ORACLE_BASE/admin/scripts" ]; then DIR_BKP=$ORACLE_BASE/admin/scripts/backup/$ORACLE_SID/logico; mkdir -p $DIR_BKP 2>>/dev/null;
elif [ -d "$ORACLE_BASE/admin/script" ]; then DIR_BKP=$ORACLE_BASE/admin/script/backup/$ORACLE_SID/logico; mkdir -p $DIR_BKP 2>>/dev/null;
else DIR_BKP=$ORACLE_BASE/admin/script/backup/$ORACLE_SID/logico; mkdir -p $DIR_BKP; fi

cat <<JHB>$DIR_BKP/expdp_full.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
# Atualizado em 08/01/2016
#
# Efetua backup full do banco de dados utilizando utilitario EXPDP
#
# Versao para Linux
# $1 ORACLE_SID

#######################################################################
# VARIAVEIS DE GLOBAIS                                                |
#######################################################################
#

if [ -z "\$1" ]; then
   echo -e "\n\nDigite: sh \$0 <SID> ou \$0 <SID> \n\n"
   exit
fi

BANCO=\`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |\$)"\`

if [ -z "\$BANCO" ]; then
   echo "Banco nao existe"
   exit
fi

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi


VORATAB=\$(grep "\$BANCO:" /etc/oratab | wc -l)
if [ "\$VORATAB" -eq "1" ]; then
export ORAENV_ASK=NO ; ORACLE_SID=\$BANCO ; . oraenv; export ORAENV_ASK=YES;
else
export ORACLE_SID=\$BANCO
fi
VCOMP=$VCOMP

$(
sqlplus -S / as sysdba <<JB
set serveroutput on
set feedback off
declare
x varchar2(90);
begin

select 'export NLS_LANG=' || a.NLS_LANGUAGE || '_' || b.NLS_TERRITORY || '.' || c.NLS_CHARACTERSET NLS_LANG into x from
(SELECT VALUE$ NLS_LANGUAGE FROM SYS.PROPS\$ WHERE NAME = 'NLS_LANGUAGE') a,
(SELECT VALUE$ NLS_TERRITORY FROM SYS.PROPS\$ WHERE NAME = 'NLS_TERRITORY') b,
(SELECT VALUE$ NLS_CHARACTERSET FROM SYS.PROPS\$ WHERE NAME = 'NLS_CHARACTERSET') c;

dbms_output.put_line(x);

end;
/

JB
)

#######################################################################
# LOCAL DAS PEÇAS DE BACKUP                                           |
#######################################################################
#
DIR=$DIRBKP

DAT=\$(date +"%w_%d%m%y_%H%M")
DESTINO=expdp_full_\$ORACLE_SID
BKPDMP=\$DESTINO\_\$DAT\_%U.dmp
BKPLOG=\$DESTINO\_\$DAT.log
EXPDP=$VDIRECTORY

#######################################################################
# RETENCAO DO BACKUP                                                  |
#######################################################################
#
find \$DIR -name "expdp_full_*.gz" -mtime +$VRENT -exec rm -f {} \;
find \$DIR -name "*.dmp" -mtime +$VRENT -exec rm -f {} \;
find \$DIR -name "*.log" -mtime +10 -exec rm -f {} \;

VALID=\$(ps -ef | grep expdp | grep -v "grep\|\$0" | grep $ORACLE_SID | wc -l)
if [ "\$VALID" -gt "0" ]; then
  echo "Backup ja esta em execucao - \$(date)">>\$DIR/\$BKPLOG
  exit;
fi

expdp \'/ as sysdba\'  full=Y directory=\$EXPDP dumpfile=\$BKPDMP logfile=\$BKPLOG filesize=8G

if [ "\$VCOMP" -eq "1" ]; then
gzip \$DIR/*.dmp
fi

JHB



cat <<EOF

#+----------------------------------------------------------------------------------------------------------------------------------------------+
## BACKUP LOGICO                                                                                                                                |
##        Caminho dos logs do backup logico - $DIRBKP
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# BANCO $(echo "$ORACLE_SID" | tr [a-z] [A-Z])
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour     MonthDay  Month  Weekday Command
# ------ -------- --------- ------ ------- -----------------------------------------------------------------------------------------------------+
  00     22       *         *      *       $DIR_BKP/expdp_full.sh $ORACLE_SID

EOF




chmod -R 755 $DIR_BKP/expdp_full.sh

#rm -f  /tmp/jbconf_bkp_logico.sh


:wq!


 bash /tmp/jbconf_bkp_logico.sh
