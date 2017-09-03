
rm -f /tmp/jbconf_apl_arch.sh

vi /tmp/jbconf_apl_arch.sh
i

#!/bin/bash

if [ -z "$ORACLE_BASE" ]; then
cat <<EOF


Favor setar a variavel ORACLE_BASE para continuar a configuracao do script.

Processo abortado!



EOF
else


function f_configure (){

if [ -d "$ORACLE_BASE/admin/scripts" ]; then STDB_HOME=$ORACLE_BASE/admin/scripts/standby;
elif [ -d "$ORACLE_BASE/admin/script" ]; then STDB_HOME=$ORACLE_BASE/admin/script/standby;
fi


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


function f_bkp_s (){
clear
cat <<EOF
#####################################################################################
Descrição: Local das pecas de backup/archive STANDBY

Exemplo: /backup/oracle/orcl/fisico/standby

EOF
read -p "Informe o diretorio do lado do standby $ORACLE_SID: " DIR_BKP
if [ -z "$DIR_BKP" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_bkp_s
fi
}

f_bkp_s



read -p "Find TNSNAMES? Sim (1): " FINDTNS

if [ ! -z "$FINDTNS" ] && [ "$FINDTNS" -eq "1" ] 2>/dev/null ; then

echo -e "\n"

find $ORACLE_HOME -name "tnsnames.ora" 2>>/dev/null | grep -vi "samples" | while read tnsnames
do
cat $tnsnames | grep '=' -1 | grep -vi 'EXTPROC_CONNECTION_DATA\|DESCRIPTION\|ADDRESS_LIST\|ADDRES\|CONNECT_DATA\|(\|)' | sed "s/=//"
done

echo -e "\n"

fi

read -p "Informe o TNS do producao \"$ORACLE_SID\": " TNS_STD

read -p "Informe a senha do owner sys \"producao\": " PASS


clear

cat <<JHB




cat <<EOF>$STDB_HOME/config/$BANCO.conf
#-- -------------------------------------------------------------------------------
#-- Nome do banco de dados
#-- -------------------------------------------------------------------------------
oracle_sid=$BANCO

#-- -------------------------------------------------------------------------------
#-- Local das pecas de backup/archive STANDBY
#-- -------------------------------------------------------------------------------
dir_bkp=$DIR_BKP

#-- -------------------------------------------------------------------------------
#-- ...
#-- -------------------------------------------------------------------------------
tns_std=$TNS_STD

#-- -------------------------------------------------------------------------------
#-- ...
#-- -------------------------------------------------------------------------------
pass=$PASS

EOF




#+------------------------------------------------------------------------------------------------------------------------------+
## APLICA ARCHIVE                                                                                                               |
#+------------------------------------------------------------------------------------------------------------------------------+
## BANCO $ORACLE_SID
#+------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour   MonthDay  Month  Weekday Command
# ------ ------ --------- ------ ------- ---------------------------------------------------------------------------------------+
  */30   *      *         *      *       $STDB_HOME/AplArch.sh $ORACLE_SID


JHB


}


if [ "$1" = "conf" ]; then
f_configure
else


if [ -d "$ORACLE_BASE/admin/scripts" ]; then STDB_HOME=$ORACLE_BASE/admin/scripts/standby; mkdir -p $STDB_HOME 2>>/dev/null;
elif [ -d "$ORACLE_BASE/admin/script" ]; then STDB_HOME=$ORACLE_BASE/admin/script/standby; mkdir -p $STDB_HOME 2>>/dev/null;
else STDB_HOME=$ORACLE_BASE/admin/scripts/standby; mkdir -p $STDB_HOME; fi

mkdir -p $STDB_HOME/log 2>>/dev/null
mkdir -p $STDB_HOME/rcv 2>>/dev/null
mkdir -p $STDB_HOME/config 2>>/dev/null


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


#-- -------------------------------------------------------------------------------
#-- Local onde os scripts estao no servidor
#-- -------------------------------------------------------------------------------
export STDB_HOME=$STDB_HOME

PARFILE=\$STDB_HOME/config/\$1.conf

if [ ! -e "\$PARFILE" ]; then
  echo "Favor criar um arquivo de configuracao"
  exit
fi


#-- -------------------------------------------------------------------------------
#-- Carrega parameters
#-- -------------------------------------------------------------------------------

while read line
    do
    p=\${line%=*}
    v=\${line#*=}
    case \$p in
      pass)
          PASS=\$v
          ;;
      oracle_sid)
          ORACLE_SID=\$v
          ;;
      dir_bkp)
          DIR_BKP=\$v
          ;;
      tns_std)
          TNS_STD=\$v
          ;;
    esac
done < \$PARFILE

export ORAENV_ASK=NO ; ORACLE_SID=\$ORACLE_SID ; . oraenv; export ORAENV_ASK=YES

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export STDB_DATA='date +%d%m%Y_%T'

DIR_RCV=\$STDB_HOME/rcv/\$ORACLE_SID

if [ ! -d "\$DIR_RCV" ]; then
  mkdir \$DIR_RCV
fi

export STDB_CTL=\$DIR_RCV/catalog_stand.rcv
export STDB_RCV=\$DIR_RCV/recover_stand.rcv
export STDB_DEL=\$DIR_RCV/del_arch.rcv

DIR_LOG=\$STDB_HOME/log/\$ORACLE_SID

if [ ! -d "\$DIR_LOG" ]; then
  mkdir \$DIR_LOG
fi

export LOGSTAND=\$DIR_LOG/recover_\$ORACLE_SID.log
export CTL_LOG=\$DIR_LOG/catalog_stand.log
export RCV_LOG=\$DIR_LOG/recover_stand.log
export DEL_LOG=\$DIR_LOG/del_arch.log
export DEL_HST=\$DIR_LOG/del_arch_hst.log

export STDB_DIR_BKP=\$DIR_BKP/complet
export STDB_DIR_BKP_COPY=\$DIR_BKP

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

find \$STDB_DIR_BKP_COPY/ -name "*arch*" -mmin +3 -exec mv {} \$STDB_DIR_BKP/ \;
find \$STDB_DIR_BKP_COPY/ -name "*ARCH*" -mmin +3 -exec mv {} \$STDB_DIR_BKP/ \;

echo -e "\n\n::Inicio da Atualizacao do banco de dados \`date +%d/%m/%Y-%T\`\n" >>\$LOGSTAND

cat <<EOF> \$STDB_CTL
  run{
    allocate channel c1 device type disk;
    catalog start with '\$STDB_DIR_BKP' noprompt;
    release channel c1;
  }
EOF


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
sqlplus -S sys/\$PASS@\$TNS_STD as sysdba <<EOF
set serveroutput on
set feedback off
declare
    v_count number:=0;
begin
    for y in (
        SELECT distinct a.thread#,a.SEQUENCE#
        FROM GV\\\$LOG_HISTORY a,
            (
                SELECT TO_CHAR(MAX(FIRST_TIME),'yyyymmddhh24miss') FIRST_TIME,thread#
                FROM GV\\\$LOG_HISTORY group by thread#
            ) b
        WHERE TO_CHAR(a.FIRST_TIME,'yyyymmddhh24miss')=b.FIRST_TIME and a.thread#=b.thread#
    )
    LOOP
        v_count:=v_count+y.SEQUENCE#;
    END LOOP;
    dbms_output.put_line(v_count);
end;
/
exit
EOF
}

function standby {
sqlplus -S /nolog <<EOF
conn / as sysdba
set serveroutput on
set feedback off
declare
    v_count number:=0;
begin
    for y in (
        SELECT distinct a.thread#,a.SEQUENCE#
        FROM GV\\\$LOG_HISTORY a,
            (
                SELECT TO_CHAR(MAX(FIRST_TIME),'yyyymmddhh24miss') FIRST_TIME,thread#
                FROM GV\\\$LOG_HISTORY group by thread#
            ) b
        WHERE TO_CHAR(a.FIRST_TIME,'yyyymmddhh24miss')=b.FIRST_TIME and a.thread#=b.thread#
    )
    LOOP
        v_count:=v_count+y.SEQUENCE#;
    END LOOP;
    dbms_output.put_line(v_count);
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

f_configure

# IF do CONFIG

fi

# IF do ORACLE_BASE
fi




:wq!



