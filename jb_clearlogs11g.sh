


10080 = 7 dias
1440  = 1 dia



#+---------------------------------------------------------------------------------------------------------------+
## BACKUP FISICO                                                                                                 |
#+---------------------------------------------------------------------------------------------------------------+
# BANCO cdbprd1
#+---------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- --------------------------------------------------------------------------+


#+---------------------------------------------------------------------------------------------------------------+
## Limpeza de Logs                                                                                               |
#+---------------------------------------------------------------------------------------------------------------+
# Minute Hour MonthDay Month  Weekday Command
# ------ ---- -------- ------ ------- ---------------------------------------------------------------------------+
  00     01   *         *      *      /orabin01/app/oracle/admin/scripts/clearlogs11g.sh -t diag -d /orabin01/app/grid -m 10080

#+---------------------------------------------------------------------------------------------------------------+
## Limpeza de Logs                                                                                               |
#+---------------------------------------------------------------------------------------------------------------+
# Minute Hour MonthDay Month  Weekday Command
# ------ ---- -------- ------ ------- ---------------------------------------------------------------------------+
  00     02   *         *      *      /orabin01/app/oracle/admin/scripts/clearlogs11g.sh -t diag -d /orabin01/app/oracle -m 10080



du -m diag/ | tail -1


5018  /orabin01/app/grid/diag/
aloisk

$ORACLE_BASE/admin/scripts

$ORACLE_BASE/admin/scripts/clearlogs11g.sh -t diag -d /u01/app/grid -m 10080


chmod +x $ORACLE_BASE/admin/scripts/clearlogs11g.sh



rm -f $ORACLE_BASE/admin/scripts/clearlogs11g.sh
vi $ORACLE_BASE/admin/scripts/clearlogs11g.sh
i
#!/bin/bash
# -----------------------------------------------------------------------------------
# Autor               : Johab Benicio de Oliveira.
# Descrição           : Remover os traces, core dumps, alerts e audit files antigos.
# Nome do arquivo     : clearlogs11g.sh
# Data de criação     : 08/11/2017
# Data de atualização : 09/11/2017
# -----------------------------------------------------------------------------------

. ~/.bash_profile

export ORACLE_HOME=/orabin01/app/oracle/product/12.1.0.2/dbhome_1
export PATH=$PATH:$ORACLE_HOME/bin

if [ "$1" == "-h" ]; then
clear
cat <<EOF
Digite: $0 -t <DIAG|AUDIT> -d <diretorio> -m <minutos>

  -t <tipo>       Valores aceitos [ DIAG ou AUDIT ]
  -d <diretorio>  Informe o diretorio onde a pasta "diag" se encontra
                   ou o diretorio dos auditfiles no caso do AUDIT.
  -m <minutos>    Informe o tempo em mitudo que voce deseja manter esses dados.


EOF
exit;
fi

if [ -z $6 ]; then
clear
cat <<EOF
Digite: $0 -t <DIAG|AUDIT> -d <diretorio> -m <minutos>

  -t <tipo>       Valores aceitos [ DIAG ou AUDIT ]
  -d <diretorio>  Informe o diretorio onde a pasta "diag" se encontra
                   ou o diretorio dos auditfiles no caso do AUDIT.
  -m <minutos>    Informe o tempo em mitudo que voce deseja manter esses dados.


EOF
exit;
fi



if [ "$1" == "-t" ]; then
  TIPO=$2;
elif [ "$3" == "-t" ]; then
  TIPO=$4;
elif [ "$5" == "-t" ]; then
  TIPO=$6;
fi;

if [ "$1" == "-d" ]; then
  DIR=$2;
elif [ "$3" == "-d" ]; then
  DIR=$4;
elif [ "$5" == "-d" ]; then
  DIR=$6;
fi;

if [ "$1" == "-m" ]; then
  TIME=$2;
elif [ "$3" == "-m" ]; then
  TIME=$4;
elif [ "$5" == "-m" ]; then
  TIME=$6;
fi;


###################
# DIAG_DB

if [ "$TIPO" == "DIAG" -o "$TIPO" == "diag" ]; then

if [ ! -d "$DIR/diag" ]; then
cat <<EOF

Diretorio invalido.
Informe um diretorio antes da pasta "diag".

EOF
exit 1;
fi

adrci exec="set base $DIR; show home" | grep -v "Homes:" | while read homes
do
adrci exec="set base $DIR; set home $homes; purge -age $TIME -type alert; purge -age $TIME -type trace; purge -age $TIME -type cdump"
done

fi;


###################
# AUDIT

if [ "$TIPO" == "AUDIT" -o "$TIPO" == "audit" ]; then

if [ ! -d "$DIR" ]; then
cat <<EOF

Diretorio nao existe.

EOF
exit 1;
fi


VALID=$(ls $DIR/*.aud 2>>/dev/null | wc -l)
if [ $? -gt 0 ]; then
cat <<EOF

nao existe arquivo *.aud para ser removido.

EOF
exit;
fi

if [ $VALID -gt 0 ]; then
find $DIR -name "*.aud" -type f -mmin +$TIME | while read audit_file
do
rm -f $audit_file
echo "Arquivo removiso: $audit_file"
done
fi;

fi;

#
## Fim
#

