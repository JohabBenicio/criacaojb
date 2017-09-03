rm -f /tmp/lsorabkp.sh
vi /tmp/lsorabkp.sh
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
# Digite 2 para executar o DRYRAN de todos os jobs.
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
    "2")
    f_dryrum_all_jobs
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


function f_dryrum_all_jobs() {
clear
ls $ODS_HOME/config/ | grep -vi default.conf | while read arqfile
do
DB=$(echo $arqfile | cut -d "." -f 1 )
cat $ODS_HOME/config/$arqfile | grep -i job_type | while read vjob
do
JOB=$(echo $vjob | cut -d "." -f 1 )
cat <<EOF
############################################################################################################################
# DRYRUN do job de backup $DB.$JOB
############################################################################################################################

EOF
$ODS_HOME/bin/orabkp backup -d $DB -j $JOB -dryrun
done
done
f_first_question
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

LOGJ=/tmp/check_backup_$DBN\_$JOBN.log
cat <<EOF> $LOGJ
############################################################################################
# Digite q (quit) para sair.

############################################################################################
# Arquivo de configuracao: $ODS_HOME/config/$DBN.conf
############################################################################################

EOF
cat $ODS_HOME/config/$DBN.conf | grep $JOBN >> $LOGJ
cat <<EOF>> $LOGJ


############################################################################################
# Bulletin do job: $ODS_HOME/bulletin/$DBN.$JOBN
############################################################################################

EOF
cat $ODS_HOME/bulletin/$DBN.$JOBN >> $LOGJ
cat <<EOF>> $LOGJ


############################################################################################
# Logs do RMAN - Execucoes do job de backup $DBN.$JOBN
############################################################################################

EOF
ls -ltr $ODS_HOME/logs/$DBN\_backup_$JOBN* | awk '{print $NF }' | tail -50 | while read files
do
DRYRUN=$(grep "DRY-RUN" $files | wc -l)
if [ "$DRYRUN" -eq "0" ]; then
ls -l $files >> $LOGJ
echo -e "\n" >> $LOGJ
tail -40 $files >> $LOGJ
echo -e "\n\n" >> $LOGJ
fi;
done
less $LOGJ
clear
cat <<EOF
############################################################################################
# Deseja manter o log $LOGJ ?
# Digite 0 para manter.
# Tecle ENTER para apagar.
############################################################################################

EOF
unset OPC
read -p "Digite sua opcao: " OPC
if [ -z "$OPC" ]; then
    OPC=1
fi

case $OPC in
    "0")
cat <<EOF
############################################################################################
# Log "$LOGJ" mantido.

EOF
sleep 2
        ;;
    "*")
    rm -f $LOGJ
        ;;
esac

clear
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
cat <<EOF
############################################################################################################################
# Deseja atualizar o arquivo de configuracao? "$ODS_HOME/config/$DBN.conf"
# Digite 1 para Sim.
# Tecle ENTER para nao.
############################################################################################################################

EOF
unset OPC
read -p "Digite sua opcao: " OPC
if [ -z "$OPC" ]; then
    OPC=2
fi

case $OPC in
    "1")
    f_dryrum_jobs
    ;;
esac

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
# Digite 2 para executar o DRYRAN de todos os jobs.
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
    "2")
    f_dryrum_all_jobs
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
