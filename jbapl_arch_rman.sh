

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

cat <<EOF>>$MAILSINC

::Inicio da Atualizacao do banco de dados `date +%d/%m/%Y-%T`

EOF

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


if [ -z $1 ]; then
clear
cat <<EOF
Uso: $0 [OPCAO]

[OPCAO]
 conf,              Configurar uma nova instancia.
 inst,              Instalar o sistema de aplicação de archives.


EOF
exit
fi


function f_configure (){

if [ -d "$ORACLE_BASE/admin/scripts" ]; then STDB_HOME=$ORACLE_BASE/admin/scripts/standby;
elif [ -d "$ORACLE_BASE/admin/script" ]; then STDB_HOME=$ORACLE_BASE/admin/script/standby;
fi



function f_instance (){
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


function f_instal_aply (){


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

export LOGSTAND=\$DIR_LOG/historico_\$ORACLE_SID.log
export CTL_LOG=\$DIR_LOG/catalog_stand.log
export RCV_LOG=\$DIR_LOG/recover_stand.log
export DEL_LOG=\$DIR_LOG/del_arch.log
export DEL_HST=\$DIR_LOG/del_arch_hst.log

export STDB_DIR_BKP=\$DIR_BKP/

if [ ! -d "\$STDB_DIR_BKP" ]; then
   mkdir -p \$STDB_DIR_BKP
fi

export STDB_START=\$(ps -ef | grep "\$STDB_RCV\|\$STDB_DEL\|\$STDB_CTL" | grep -v grep | wc -l )

find \$STDB_DIR_BKP -mtime +2 -exec rm -f {} \;

if [ "\$STDB_START" -gt "0" ]
then
cat <<EOF>>\$LOGSTAND

  A sincronizacao ja esta ativa! Saindo - \`$STDB_DATA\` ...
EOF
exit;
fi

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



#
## Consulta a sequencia atual do Standby
#


function sinc_producao {
sqlplus -S sys/\$PASS@\$TNS_STD as sysdba <<EOF
set serveroutput on
set feedback off
declare
    v_result varchar2(90);
    v_thread number;
begin
    select count(distinct thread#) into v_thread from V\\\$LOG_HISTORY;
    for y in (
        SELECT distinct a.thread#,a.SEQUENCE#
        FROM V\\\$LOG_HISTORY a,
            (
                SELECT TO_CHAR(MAX(FIRST_TIME),'yyyymmddhh24miss') FIRST_TIME,thread#
                FROM V\\\$LOG_HISTORY group by thread#
            ) b
        WHERE TO_CHAR(a.FIRST_TIME,'yyyymmddhh24miss')=b.FIRST_TIME and a.thread#=b.thread#
        ORDER BY 1 asc
    )
    LOOP
    if v_result is null then
        v_result:=v_thread||';'||y.thread#||','||y.SEQUENCE#;
    else
        v_result:=v_result||';'||y.thread#||','||y.SEQUENCE#;
    end if;

    END LOOP;
    dbms_output.put_line(v_result);
end;
/
quit;

EOF
}

function sinc_standby {
sqlplus -S / as sysdba <<EOF
set serveroutput on
set feedback off
declare
    v_result varchar2(90);
    v_thread number;
begin
    select count(distinct thread#) into v_thread from V\\\$LOG_HISTORY;
    for y in (
        SELECT distinct a.thread#,a.SEQUENCE#
        FROM V\\\$LOG_HISTORY a,
            (
                SELECT TO_CHAR(MAX(FIRST_TIME),'yyyymmddhh24miss') FIRST_TIME,thread#
                FROM V\\\$LOG_HISTORY group by thread#
            ) b
        WHERE TO_CHAR(a.FIRST_TIME,'yyyymmddhh24miss')=b.FIRST_TIME and a.thread#=b.thread#
        ORDER BY 1 asc
    )
    LOOP
    if v_result is null then
        v_result:=v_thread||';'||y.thread#||','||y.SEQUENCE#;
    else
        v_result:=v_result||';'||y.thread#||','||y.SEQUENCE#;
    end if;

    END LOOP;
    dbms_output.put_line(v_result);
end;
/
quit;

EOF
}

PROD=\$(sinc_producao)
STD=\$(sinc_standby)

VALID_PROD=\$(echo \$PROD | sed 's/,//g' | sed 's/;//g')
VALID_STD=\$(echo \$STD | sed 's/,//g' | sed 's/;//g')

if [ \$VALID_PROD -ge 0 ] && [ \$VALID_STD -ge 0 ]; then

QTDT=\$(echo \$PROD | cut -d ';' -f 1)
QTD=\$((QTDT+1))

V_PRD_S=""
V_STD_S=""

for (( x=1; x>0; x++ ));
do

if [ \$x -gt 1 ]; then

V_PRD_S=\$(echo \$PROD | cut -d ';' -f \$x | cut -d ',' -f 2 )
V_STD_S=\$(echo \$STD | cut -d ';' -f \$x | cut -d ',' -f 2 )

if [ \$x -eq 2 ]; then
VDIF=\$((\$V_PRD_S-\$V_STD_S))
else
VDIF=\$VDIF';'\$((\$V_PRD_S-\$V_STD_S))
fi

fi

if [ \$x -eq \$QTD ]; then
break
fi
done


for (( x=1; x>0; x++ ));
do

V_NEW=\$(echo \$VDIF | cut -d ';' -f \$x )
if [ -z \$V_NEW ]; then
V_NEW=0
fi

if [ \$x -eq 1 ]; then
V_MAIOR=\$V_NEW
else
if [ \$V_MAIOR -lt \$V_NEW ]; then
V_MAIOR=\$V_NEW
fi
fi
if [ \$x -eq \$QTD ]; then
break
fi

done

fi

cat <<EOF>>\$LOGSTAND
**********************************************************************************
                    SINCRONIA DO BANCO DE DADOS: \$ORACLE_SID
----------------------------------------------------------------------------------
                    STATUS SERVIDOR STANDBY ORACLE
----------------------------------------------------------------------------------

A diferença entre o standby database e a base de producao e de \$V_MAIOR archive(s).


EOF



echo "Inicio do purge de archives... \$(date)" >>\$LOGSTAND

rman target \'/ as sysdba \' cmdfile \$STDB_DEL msglog \$DEL_LOG

echo "Fim do purge de archives. $(date)" >>\$LOGSTAND

cat <<EOF>>\$DEL_HST


Delete \$(date)

EOF
cat \$DEL_LOG | grep -1 "archive log filename" >>\$DEL_HST

sed -i 's/-e//g' \$LOGSTAND
exit



JHB
chmod 755 $STDB_HOME/AplArch.sh

clear
cat <<EOF
######################################################################
Arquivo criado: $STDB_HOME/AplArch.sh

EOF


}

if [ "$1" = "conf" ]; then
f_configure
elif [ "$1" = "inst" ]; then
f_instal_aply
else
cat <<EOF

Opcao nao valida.
Processo abortado.

EOF
fi



# IF do ORACLE_BASE
fi




#
## Fim
#



