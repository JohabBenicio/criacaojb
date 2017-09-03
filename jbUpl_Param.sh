rm -f /tmp/jbUpl_Param.sh
vi /tmp/jbUpl_Param.sh
i
#!/bin/bash

#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Atualiza parametros do System Profiler
#-- Nome do arquivo     : jbUpl_Param.sh
#-- Data de criação     : 18/04/2017
#-- Versao              : 1.7
#-- -----------------------------------------------------------------------------------

NEW_PARAM=/tmp/a01_jbinit
cat <<EOF>$NEW_PARAM
upload_dest_server=ftp.p4t.com.br
upload_dest_credential=sprof.ftp,S15t3mP0r0f1l3r@P4T
smtp_user=sprof@p4t.com.br
smtp_password=42054a0d9b
smtp_server=smtp.p4t.com.br
smtp_server_IP=177.70.110.120
smtp_port=587
smtp_from_address=sprof@p4t.com.br
smtp_to_addresses=sprof_monitor@p4t.com.br
EOF


readonly ODU_COLOR_NORM="\033[0m";
readonly ODU_COLOR_BOLD="\033[1m";
readonly ODU_COLOR_GREEN="\033[1;32;40m";
readonly ODU_COLOR_RED="\033[1;31;40m";

export MSG_SUCESSO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"Ok"$ODU_COLOR_NORM"
export MSG_FALHA="$ODU_COLOR_BOLD$ODU_COLOR_RED"Falha"$ODU_COLOR_NORM"
export MSG_FINALIZADO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"FINALIZADO"$ODU_COLOR_NORM"


####################################################################################
####################################################################################
clear

if [ -z $OPTI_HOME ]; then
cat <<EOF

Parametro "OPTI_HOME" nao configurado.
Processo cancelado.

Obs.: Geralmente o parametro OPTI_HOME contem o valor "/opt/optimode" para Linux e "/var/opt/optimode" para AIX.

EOF

exit
fi


FTP=$(rpm -qa ftp | wc -l)
TELNET=$(rpm -qa telnet | wc -l)
SO=$(uname)

if [ $SO == AIX ]; then


cat <<EOF

Teste com TELNET com endereco: ftp.p4t.com.br 21

Obs.: Se demorar mais que 10 segundos, entao execute [ Control + C ]

EOF

telnet ftp.p4t.com.br 21 <<EOF
quit;
EOF


cat <<EOF

Teste com TELNET com endereco: 177.70.97.255

Obs.: Se demorar mais que 10 segundos, entao execute [ Control + C ]

EOF

telnet 177.70.97.255 21 <<EOF
quit;
EOF


elif [ $FTP -gt 0 ]; then

cat <<EOF

Teste com FTP com endereco: ftp.p4t.com.br

Obs.: Se demorar mais que 10 segundos, entao execute [ Control + C ]

EOF

ftp -n ftp.p4t.com.br <<EOF
user sprof.ftp S15t3mP0r0f1l3r@P4T
binary
prompt on
ls cursor.log
bye
EOF

cat <<EOF

Teste com FTP com endereco: 177.70.97.255

Obs.: Se demorar mais que 10 segundos, entao execute [ Control + C ]

EOF

ftp -n 177.70.97.255 <<EOF
user sprof.ftp S15t3mP0r0f1l3r@P4T
binary
prompt on
ls cursor.log
bye
EOF

elif [ $TELNET -gt 0 ]; then


cat <<EOF

Teste com TELNET com endereco: ftp.p4t.com.br 21

Obs.: Se demorar mais que 10 segundos, entao execute [ Control + C ]

EOF

telnet ftp.p4t.com.br 21 <<EOF
quit;
EOF


cat <<EOF

Teste com TELNET com endereco: 177.70.97.255

Obs.: Se demorar mais que 10 segundos, entao execute [ Control + C ]

EOF

telnet 177.70.97.255 21 <<EOF
quit;
EOF

else

cat <<EOF

Nao tem FTP e nem TELNET instalado no servidor.

EOF


fi



####################################################################################
####################################################################################


while read INIT_PAR
do

cat <<EOF

##########################################################
# Ajuste do arquivo de parametro "$INIT_PAR"

EOF



printf "%-130s" "Backup do init.par"

INIT_PAR_BKP=$INIT_PAR.bkp_$(date +"%d-%m-%Y_%H%M%S")

cp $INIT_PAR $INIT_PAR_BKP
if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi
ls -ltr $INIT_PAR*

cat <<EOF

EOF
while read line_new
do

  PARAM_NEW=$(echo $line_new | cut -d "=" -f 1)
  VALUE_NEW=$(echo $line_new | cut -d "=" -f 2)

  while read line_old
  do

    if [ $line_old == $line_new ]; then
      printf "%-130s" "Valor ja esta atualizado. $line_old"
      echo -e "[    $MSG_SUCESSO    ]"
    else
      printf "%-130s" "Atualizando parametro \"$line_old\" para \"$line_new\"."
      sed "s/$line_old/$line_new/" $INIT_PAR > $INIT_PAR.temp

      if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi
      cp $INIT_PAR.temp $INIT_PAR
      rm -f $INIT_PAR.temp
    fi

  done < <(grep -i $PARAM_NEW $INIT_PAR )


done < $NEW_PARAM

cat <<EOF

##################################################
#     Restart do Arente
##################################################

EOF

printf "%-130s" "Parando o agente do SystemProfiler."
sprof -u -p $INIT_PAR >>/dev/null

if [ "$?" -eq "0" ]; then
  echo -e "[    $MSG_SUCESSO    ]";

  printf "%-130s" "Iniciando o agente do SystemProfiler."
  sprof -s -p $INIT_PAR >>/dev/null
  if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

else
  echo -e "[   $MSG_FALHA  ]";
fi


cat <<EOF

#
## Fim.
#

############################################################################
Teste de envio de email.

Teste deve demorar cerca de 1 minuto...

Obs.: NAO CANCELE COM [ CTRL + C ]!!!!

EOF

printf "%-130s" "Teste de envio de email."
SAIDA_COMANDO=$(sprof -m -p $INIT_PAR)

if [ "$?" -eq "0" ]; then
  echo -e "[    $MSG_SUCESSO    ]"
cat <<EOF

Saida do envio de email:

$SAIDA_COMANDO

EOF
else
  echo -e "[   $MSG_FALHA  ]"

  VALID_PARAM=$(grep smtp_server_IP $NEW_PARAM | wc -l)

  if [ $VALID_PARAM -gt 0 ]; then
    PARAM_NEW="smtp_server=$(grep smtp_server_IP $NEW_PARAM | cut -d "=" -f 2)"
    PARAM_OLD=$(grep smtp_server $INIT_PAR)
    sed "s/$PARAM_OLD/$PARAM_NEW/" $INIT_PAR > $INIT_PAR.temp
    cp $INIT_PAR.temp $INIT_PAR
    rm -f $INIT_PAR.temp

    printf "%-130s" "   Teste de envio de email com o IP."
    sprof -m -p $INIT_PAR >>/dev/null
    if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi
  fi

fi





cat <<EOF

############################################################################

Para voltar o backup.

cp $INIT_PAR_BKP $INIT_PAR

sprof -u -p $INIT_PAR
sprof -s -p $INIT_PAR

EOF

while read logs_sprof
do
  echo "tail -30f $logs_sprof | grep \"UPLD:\""
done < <(ls $OPTI_HOME/sprof/log/messages*)

cat <<EOF

############################################################################

EOF
done < <(ls $OPTI_HOME/sprof/admin/*.par | grep -vi Template)



cat <<EOF


Favor validar o upload dos arquivos a partir do log.

EOF

while read logs_sprof
do
  echo "tail -30f $logs_sprof | grep \"UPLD:\""
done < <(ls $OPTI_HOME/sprof/log/messages*)


cat <<EOF




EOF

