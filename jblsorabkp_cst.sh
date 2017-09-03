rm -f /tmp/lsorabkp_cst.sh
vi /tmp/lsorabkp_cst.sh
i
#!/bin/bash

clear
cat <<EOF
##############################################################
# Welcome to the lsorabkp - 1.0

EOF
sleep 2


function f_first_question() {
clear
cat <<EOF
####################################################################
# Digite 1 ou ENTER Para analisar um outro job de backup.
# Digite 0 Para Sair.
####################################################################

EOF
unset OPC
read -p "Digite sua opcao: " OPC

if [ -z "$OPC" ]; then
    f_inicio_lsorabkp
else
case $OPC in
    "1")
    f_inicio_lsorabkp
        ;;
    "0")
clear
cat <<EOF
####################################################################
# Saindo!!!

EOF
    exit;
    ;;
    "*")
    clear
cat <<EOF

####################################################################
# Opcao nao selecionada.

# Saindo!!!

EOF
    exit;
    ;;
esac
fi
}


function f_dryrum_jobs() {

if [ "$OPC" -eq "1" ]; then
vi $ODS_HOME/config/$DBN.conf
clear


fi
echo -e "\n"
cat <<EOF
############################################################################################################################
# Deseja atualizar o arquivo de configuracao? "$ODS_HOME/config/$DBN.conf"
# Digite 1 para Sim.
# Tecle ENTER para nao.
############################################################################################################################

EOF
unset OPC
read -p "Digite sua opcao: " OPC

case $OPC in
    "1" )
    f_dryrum_jobs
        ;;
esac
}


function f_jobs_bkp() {

clear
cat <<EOF
####################################################################
# Jobs de backup pertencentes ao banco de dados $DBN

EOF

cat $ODS_HOME/config/$DBN.conf | grep -i job_type | cut -d "." -f 1 >/tmp/.LSJOBS.out
cat /tmp/.LSJOBS.out | grep -n ^ | tr ':' ' '

echo -e "\n"
unset VN
read -p "Informe o job a ser analisado: " VN
if [ -z "$VN" ]; then
    exit;
fi
JOBN=$(cat /tmp/.LSJOBS.out | grep -n ^ | grep "$VN:" | cut -d ":" -f "2")
rm -f /tmp/.LSJOBS.out


while read -r BKP_LOG;
do
    CAMPO=${BKP_LOG%: *}
    VALOR=${BKP_LOG#*: }
    case $CAMPO in
        EST_END_TIME)
            if [ "$VALOR" = "UNAVAILABLE" ] ; then
                ALERT="7";
                EST_END_TIME="999999999999";
            else
                EST_END_TIME="${VALOR:6:4}${VALOR:3:2}${VALOR:0:2}${VALOR:11:2}${VALOR:14:2}";
            fi;
        ;;
        NEXT_START_TIME)
            if [ "$VALOR" = "UNAVAILABLE" ] ; then
                ALERT="7";
                NEXT_START_TIME="999999999999";
            else
                NEXT_START_TIME="${VALOR:6:4}${VALOR:3:2}${VALOR:0:2}${VALOR:11:2}${VALOR:14:2}";
            fi;
        ;;
        STATUS)
            BKP_STATUS=$VALOR
            ;;
        RMAN_STATUS)
            RMAN_STATUS=$VALOR
        ;;
    esac
done < $ODS_HOME/bulletin/$DBN.$JOBN


case $BKP_STATUS in
    "RUNNING")
    if [ "$DATA_ATUAL" -gt "$EST_END_TIME" ]; then
cat <<JHB1



CONTATO

Nome:
Fernando Ortiz de Oliveira

Telefoene:
11 2135-3379

Email:
fortiz@grsa.com.br


AÇÕES EXECUTADAS (resumo)
========================
1) - Analise de logs.

DADOS COLETADOS
================
1) - Bulletin do job: $ODS_HOME/bulletin/$DBN.$JOBN

JHB1

cat $ODS_HOME/bulletin/$DBN.$JOBN

cat <<JHB2

2) - Log RMAN: $(ls -ltrh $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1 | sed 's/.*oinstall\ //')

(...)
JHB2

tail -10 $(ls -tr $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1)

cat <<JHB3

Seu backup se encontra em execução.
Iremos aguardar a finalização do backup para darmos continuidade no atendimento do chamado.

Att,
Johab Benicio.
DBA Oracle.

JHB3

fi;

if [ "$EST_END_TIME" -eq "999999999999" ]; then
cat <<JHB


7 - Configurar a estimativa de tempo para job de backup JOB_NAME.



JHB
    else

cat <<JHB1



CONTATO

Nome:
Fernando Ortiz de Oliveira

Telefoene:
11 2135-3379

Email:
fortiz@grsa.com.br


AÇÕES EXECUTADAS (resumo)
========================
1) - Analise de logs.

DADOS COLETADOS
================
1) - Bulletin do job: $ODS_HOME/bulletin/$DBN.$JOBN

JHB1

cat $ODS_HOME/bulletin/$DBN.$JOBN

cat <<JHB2

2) - Log RMAN: $(ls -ltrh $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1 | sed 's/.*oinstall\ //')

(...)
JHB2

tail -20 $(ls -tr $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1)

cat <<JHB3

Com base na confirmação de que o job de backup de $JOBN foi executado com sucesso, estamos encaminhando este chamado para o encerramento.


Att,
Johab Benicio.
DBA Oracle.

JHB3

    fi;
    ;;
    "COMPLETED")
    if [ "$DATA_ATUAL" -gt "$(($NEXT_START_TIME+5))" ]; then
        echo "2";
    fi;
    if [ "$NEXT_START_TIME" -eq "999999999999" ]; then
        echo "7";
    else

cat <<JHB1



CONTATO

Nome:
Fernando Ortiz de Oliveira

Telefoene:
11 2135-3379

Email:
fortiz@grsa.com.br


AÇÕES EXECUTADAS (resumo)
========================
1) - Analise de logs.

DADOS COLETADOS
================
1) - Bulletin do job: $ODS_HOME/bulletin/$DBN.$JOBN

JHB1

cat $ODS_HOME/bulletin/$DBN.$JOBN

cat <<JHB2

2) - Log RMAN: $(ls -ltrh $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1 | sed 's/.*oinstall\ //')

(...)
JHB2

tail -20 $(ls -tr $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1)

cat <<JHB3

Com base na confirmação de que o job de backup de $JOBN foi executado com sucesso, estamos encaminhando este chamado para o encerramento.


Att,
Johab Benicio.
DBA Oracle.

JHB3

    fi;
    ;;
    "NOT STARTED")
    if [ "$DATA_ATUAL" -gt "$(($NEXT_START_TIME+5))" ]; then
        echo "2";
    fi;
    if [ "$NEXT_START_TIME" -eq "999999999999" ]; then
cat <<JHB


7 - Configurar a estimativa de tempo para job de backup JOB_NAME.



JHB
    else

cat <<JHB1



CONTATO

Nome:
Fernando Ortiz de Oliveira

Telefoene:
11 2135-3379

Email:
fortiz@grsa.com.br


AÇÕES EXECUTADAS (resumo)
========================
1) - Analise de logs.

DADOS COLETADOS
================
1) - Bulletin do job: $ODS_HOME/bulletin/$DBN.$JOBN

JHB1

cat $ODS_HOME/bulletin/$DBN.$JOBN

cat <<JHB2

2) - Log RMAN: $(ls -ltrh $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1 | sed 's/.*oinstall\ //')

(...)
JHB2

tail -20 $(ls -tr $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1)

cat <<JHB3

Com base na confirmação de que o job de backup de $JOBN foi executado com sucesso, estamos encaminhando este chamado para o encerramento.


Att,
Johab Benicio.
DBA Oracle.

JHB3

    fi;
    ;;
    "FAILURE")
    if [ "$RMAN_STATUS" = "COMPLETED" ]; then
        echo "5";
    else

cat <<JHB1



CONTATO

Nome:
Fernando Ortiz de Oliveira

Telefoene:
11 2135-3379

Email:
fortiz@grsa.com.br


AÇÕES EXECUTADAS (resumo)
========================
1) - Analise de logs.

DADOS COLETADOS
================
1) - Bulletin do job: $ODS_HOME/bulletin/$DBN.$JOBN

JHB1

cat $ODS_HOME/bulletin/$DBN.$JOBN

cat <<JHB2

2) - Log RMAN: $(ls -ltrh $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1 | sed 's/.*oinstall\ //')

(...)
JHB2

tail -20 $(ls -tr $ODS_HOME/logs/$DBN\_backup_$JOBN* | tail -1)

cat <<JHB3


Prezado Cliente, bom dia.

O job de backup $JOBN do banco de dados $DBN foi executado, porém, o mesmo encontra-se invalido.

Por favor, siga o plano de ação descrito abaixo.
Iremos aguardar a execução desta(s) ação(ões) para darmos continuidade no atendimento:

PLANO DE AÇÃO DO CLIENTE
========================
1) - Favor acionar a IBM para execução do job de backup informado acima.


Att,
Johab Benicio.
DBA Oracle.

JHB3

fi
    ;;
    *)
        echo "2000";
esac


cat <<EOF



EOF

#############JOHAB#############################JOHAB#############################JOHAB################


cat <<EOF
############################################################################################################################
# Deseja analisar outro job de backup do banco de dados $DBN ?
# Digite 1 para Sim.
# Tecle ENTER para Nao.

EOF
unset OPC
read -p "Digite sua opcao: " OPC
if [ -z "$OPC" ]; then
    OPC=0
fi

case $OPC in
    "1")
    clear;
    f_jobs_bkp
    ;;
esac

clear

f_first_question
}


##############################################################################################################
# Execucao principal.
##############################################################################################################

function f_inicio_lsorabkp() {
clear
cat <<EOF
####################################################################
# Bancos com job de backup

EOF

ls $ODS_HOME/config/ | grep -vi default.conf |  cut -d "." -f 1 >/tmp/.LSINS.out
cat /tmp/.LSINS.out | grep -n ^ | tr ':' ' '

echo -e "\n"
read -p "Informe o banco de dados: " VN
if [ -z "$VN" ]; then
    exit;
fi
unset VALID
VALID=$(cat /tmp/.LSINS.out | grep -n ^ | cut -d ":" -f "1" | grep "$VN" | wc -l )
if [ "$VALID" -eq "0" ]; then
rm -f /tmp/.LSINS.out
cat <<EOF

####################################################################
# Escolha a posicao do banco de dados.

# Saindo!!!

EOF
exit;
fi

export DBN=$(cat /tmp/.LSINS.out | grep -n ^ | grep "$VN:" | cut -d ":" -f "2")
rm -f /tmp/.LSINS.out
f_jobs_bkp
}


clear
if [ -z "$ODS_HOME" ]; then
cat <<EOF
############################################################################################################################
# Parametro ODS_HOME nao esta configurado.
############################################################################################################################

EOF
exit
fi

clear
cat <<EOF
####################################################################
# Digite 1 ou ENTER Para analisar um job de backup.
# Digite 0 Para Sair.
####################################################################

EOF
unset OPC
read -p "Digite sua opcao: " OPC

if [ -z "$OPC" ]; then
    OPC=1
fi
case $OPC in
    "1")
    f_inicio_lsorabkp
    ;;
    "0")
clear
cat <<EOF
####################################################################
# Saindo!!!

EOF
    exit;
    ;;
    "*")
clear
cat <<EOF

####################################################################
# Opcao nao selecionada.

# Saindo!!!

EOF
    ;;
esac
