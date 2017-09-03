# ========================================================================================================================================
# ==================================                                                              ========================================
# ==================================                       EMAIL SINCRONIA                        ========================================
# ==================================                                                              ========================================
# ========================================================================================================================================
rm -f /tmp/jbconf_send_sinc.sh
vi /tmp/jbconf_send_sinc.sh
i
#!/bin/bash

if [ -z "$ORACLE_BASE" ]; then
cat <<EOF


Favor setar a variavel ORACLE_BASE para continuar a configuracao do script.

Processo abortado!



EOF
else



function f_configure (){

if [ -d "$ORACLE_BASE/admin/scripts" ]; then MAIL_HOME=$ORACLE_BASE/admin/scripts/standby/mail;
elif [ -d "$ORACLE_BASE/admin/script" ]; then MAIL_HOME=$ORACLE_BASE/admin/script/standby/mail;
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
fi
}

f_instance

function f_nome_database (){
clear
read -p "Informe o nome do banco de dados para mostrar no EMAIL (Instancia: $BANCO): " vdb
if [ -z "$vdb" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_nome_database
fi
}

f_nome_database


function f_nome_cli (){
clear
read -p "Informe o nome do cliente: " vncli
if [ -z "$vncli" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_nome_cli
fi
}

f_nome_cli


function f_email (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe o endereco de email de quem vai ser alertado separado por virgula.

Exemplo: alfa@teor.inf.br,delta@teor.inf.br,seal@teor.inf.br

EOF
read -p "Informe os emails: " vemail
if [ -z "$vemail" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_email
fi
}

f_email


function f_tns_prd (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe o TNS_NAMES do ambiente de producao da instancia: $BANCO.

EOF

if [ -e "$ORACLE_HOME/network/admin/tnsnames.ora" ]; then
echo "TNS encontrados:"
cat $ORACLE_HOME/network/admin/tnsnames.ora | grep "=" | grep -v "(\|)"
fi

read -p "Informe o tnsnames de producao: " tns_prod
if [ -z "$tns_prod" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_tns_prd
fi
}

f_tns_prd


function f_tns_std (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe o TNS_NAMES do ambiente de standby da instancia: $BANCO.

EOF

if [ -e "$ORACLE_HOME/network/admin/tnsnames.ora" ]; then
echo "TNS encontrados:"
cat $ORACLE_HOME/network/admin/tnsnames.ora | grep "=" | grep -v "(\|)"
fi

read -p "Informe o tnsnames de standby: " tns_std
if [ -z "$tns_std" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_tns_std
fi
}

f_tns_std


function f_pass (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe a senha do usuario sys

EOF

read -p "Informe a senha do usuario sys: " pass
if [ -z "$pass" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_pass
fi
}

f_pass




function f_sendmail (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe o diretorio mais nome do sendemail

Exemplo: /u01/app/oracle/admin/scripts/standby/sendEmail

Aguarde a execucao do find e locate: find $ORACLE_BASE -name "*sendEmail*"

EOF
locate sendEmail 2>>/dev/null
find $ORACLE_BASE -name "*sendEmail*" 2>>/dev/null
echo -e "\n"
read -p "Informe o nome do sendEmail: " vsendemail
if [ -z "$vsendemail" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_sendmail
fi
}

f_sendmail


cat <<JB

cat <<EOF> $MAIL_HOME/config/$BANCO.conf

#-- -------------------------------------------------------------------------------
#-- Nome do Cliente
#-- -------------------------------------------------------------------------------
ncli="$vncli"

#-- -------------------------------------------------------------------------------
#-- Email de quem vai receber o email.
#-- -------------------------------------------------------------------------------
vto=$vemail

#-- -------------------------------------------------------------------------------
#-- TNS do produção
#-- -------------------------------------------------------------------------------
tns_prod=$tns_prod

#-- -------------------------------------------------------------------------------
#-- TNS do standby
#-- -------------------------------------------------------------------------------
tns_std=$tns_std

#-- -------------------------------------------------------------------------------
#-- Nome do banco de dados
#-- -------------------------------------------------------------------------------
vdb=$vdb

#-- -------------------------------------------------------------------------------
#-- ...
#-- -------------------------------------------------------------------------------
pass=$pass

#-- -------------------------------------------------------------------------------
#-- SendEmail
#-- -------------------------------------------------------------------------------
sendemail=$vsendemail

EOF

JB

}

if [ "$1" = "conf" ]; then
f_configure
else

if [ -d "$ORACLE_BASE/admin/scripts" ]; then MAIL_HOME=$ORACLE_BASE/admin/scripts/standby/mail; mkdir -p $MAIL_HOME 2>>/dev/null;
elif [ -d "$ORACLE_BASE/admin/script" ]; then MAIL_HOME=$ORACLE_BASE/admin/script/standby/mail; mkdir -p $MAIL_HOME 2>>/dev/null;
else MAIL_HOME=$ORACLE_BASE/admin/scripts/standby/mail; mkdir -p $MAIL_HOME; fi

mkdir -p $MAIL_HOME/log 2>>/dev/null;
mkdir -p $MAIL_HOME/config 2>>/dev/null;
mkdir -p $MAIL_HOME/tmp 2>>/dev/null;

cat <<JHB>$MAIL_HOME/MailSinc.sh


#!/bin/bash
#
# TEOR Tecnologia Orientada
# Funcao..: Envia o Status dos Archives Aplicados no Standby via Email.
# Sistema.: Oracle

#
# Variaveis Oracle
#


if [ -z "\$1" ]; then
  echo "Favor informar o nome do banco de dados."
  echo "\$0 <DB_NAME>"
  exit;
fi

if [ -z "\$2" ]; then
  SEND=1
elif [ "\$2" = "NO" ] || [ "\$2" = "no" ]; then
  SEND=0
else
  SEND=1
fi

#-- -------------------------------------------------------------------------------
#-- Local onde os scripts estao no servidor
#-- -------------------------------------------------------------------------------

DATA=\$(date +%d.%m.%Y)
MAIL_HOME=$MAIL_HOME
DIR_TEMP=\$MAIL_HOME/tmp

PARFILE=\$MAIL_HOME/config/\$1.conf

if [ ! -e "\$PARFILE" ]; then
  echo "Favor criar um arquivo de configuracao"
  exit
fi

#-- -------------------------------------------------------------------------------
#-- Carregar variaveis do bash_profile
#-- -------------------------------------------------------------------------------

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi

#
# Variaveis Locais
#

while read line
    do
    p=\${line%=*}
    v=\${line#*=}
    case \$p in
      tns_prod)
          TNS_PROD=\$v
          ;;
      tns_std)
          TNS_STD=\$v
          ;;
      pass)
          PASS=\$v
          ;;
      sendemail)
          SENDEMAIL=\$v
          ;;
      ncli)
        CLIENTE=\$v
          ;;
      vto)
        TO=\$v
          ;;
      vdb)
        DBNAME=\$v
          ;;
    esac
done < \$PARFILE

SUBJECT="[STATUS] [\$CLIENTE] Standby Database \$DBNAME - \$DATA"


#
# Consulta a sequencia atual do Standby
#


function sinc_producao {
sqlplus -S sys/\$PASS@\$TNS_PROD as sysdba <<EOF
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
exit;

EOF
}

function sinc_standby {
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
exit;

EOF
}

PROD=\$(sinc_producao)
STD=\$(sinc_standby)

VALID_PROD=\$(echo \$PROD | sed 's/,//g' | sed 's/;//g')
VALID_STD=\$(echo \$STD | sed 's/,//g' | sed 's/;//g')

if [ \$VALID_PROD -ge 0 ] 2>>/dev/null && [ \$VALID_STD -ge 0 ] 2>>/dev/null; then

QTDT=\$(echo \$PROD | cut -d ';' -f 1)
QTD=\$((QTDT+1))
unset V_PRD_S
unset V_STD_S
for (( x=1;x>0;x++));
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


for (( x=1;x>0;x++));
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

cat <<EOF>\$DIR_TEMP/mail.\$\$
**********************************************************************************
                             MONITOR ORACLE
----------------------------------------------------------------------------------
                    STATUS SERVIDOR STANDBY ORACLE
----------------------------------------------------------------------------------

A diferença entre o standby database e a base de producao e de \$V_MAIOR archives.

**********************************************************************************
              TEOR Tecnologia Orientada Informatica ltda.
                      Sao Paulo/SP - 11 2578-7688
**********************************************************************************
EOF


#
# Envia o Email
#

if [ "\$SEND" -eq "1" ]; then
\$SENDEMAIL -f dbmonitor@teor.inf.br -t \$TO -s smtp.teor.inf.br:587 -u "\$SUBJECT" -o message-file=\$DIR_TEMP/mail.\$\$ -xu "dbmonitor@teor.inf.br" -xp "ju5u6hxi"
else
cat \$DIR_TEMP/mail.\$\$
fi

#
# Remove o Arquivo Temporario de Email
#

rm -f \$DIR_TEMP/mail.\$\$


JHB

chmod +x $MAIL_HOME/MailSinc.sh
f_configure


cat <<EOF

#+----------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay  Month  Weekday Command
# ------ ----- --------- ------ ------- --------------------------------------------------------------------------------------------------------+
  00     */6   *         *      *       $MAIL_HOME/MailSinc.sh $BANCO


EOF


fi

fi



