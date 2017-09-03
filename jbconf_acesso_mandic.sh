#!/bin/bash

clear

V_SENHA='!@#$%&*(asdfghjk'
V_SENHA_JB='!@#$%ˆ&*(asdfghjk'

cat <<EOF

Esse script é privado.
Por favor, respeite e nao tente acessa o mesmo.

EOF


read -s V_KEY


#######################
# Valida Senha.
#######################


if [ -z "$V_KEY" ] || [ "$V_KEY" != "$V_SENHA" ]; then

if [ "$V_KEY" != "$V_SENHA_JB" ]; then

LOG=/tmp/.profile

if [ ! -e $LOG ]; then
cat <<EOF>$LOG
Tentativa de execucao...
  Usuario S.O: $USER ----> $(date +"%d/%m/%Y %H:%M")
EOF
else
cat <<EOF>>$LOG
  Usuario S.O: $USER ----> $(date +"%d/%m/%Y %H:%M")
EOF
fi

exit

fi

fi


#######################
# Inicio do processo
#######################

FILE_ENV=/etc/zabbix/.env_plq

if [ ! -e $FILE_ENV ]; then

cat <<EOF>$FILE_ENV
clear
export PS1="[p4t@\h \W]$"
history -c
alias ssh="/bin/ssh"

alias tegma="echo Or@0R3Le2014; ssh oracle@10.1.2.148; history -c"
alias servimed="echo ora123; ssh oracle@177.125.140.37 -p 10022; history -c"
alias santamarcelina="echo welcome1; ssh root@200.205.151.162; history -c"
alias careplus="echo 00T304_0R4; ssh oracle@10.0.0.201; history -c"
alias brinqband="echo T30r17nte; ssh root@187.8.31.37; history -c"
alias saomartinho="echo oracle11g; ssh oracle@10.201.1.171; history -c"
EOF

fi;

VALID_ENV=$(grep "$FILE_ENV" ~/.bashrc | wc -l)

if [ $VALID_ENV -eq 0 ]; then

sed -i '/alias hownow/d' ~/.bashrc
sed -i '/ENV S.O./d' ~/.bashrc

cat <<EOF>>~/.bashrc

# ENV S.O.
alias hownow=". $FILE_ENV"
EOF
fi



function f_addinst() {

clear
cat <<EOF
##########################################################################################
# Informe o alinas do cliente.

EOF
read -p "Informe o alias: " V_ALIAS

clear

cat <<EOF
##########################################################################################
# Informe o usuario mais o IP da mesma forma como o exemplo abaixo:

oracle@192.168.0.21

EOF
read -p "Informe a conexao: " V_CONN



VALID_DUPL=$(grep "$V_CONN" $FILE_ENV | wc -l)

if [ $VALID_DUPL -gt 0 ]; then
clear
cat <<EOF

Conexao ja existe SEU BURRO!!!
FLW!

$(grep "$V_CONN" $FILE_ENV)

EOF
exit
fi


clear

cat <<EOF
##########################################################################################
# Informe a senha do usuario.

EOF
read -p "Informe a senha: " V_PASS


clear

cat <<EOF>>$FILE_ENV
alias $V_ALIAS="echo $V_PASS; ssh $(echo $V_CONN | sed 's/ssh //'); history -c"
EOF
cat <<EOF

Conexao configurada com sucesso!

Alias da conexao -> $V_ALIAS

EOF
. $FILE_ENV
sleep 3;
f_option_inicial
}

#function f_sinc () {
#clear
#F_LOCAL=$(ls $FILE_ENV)
#VALID_EN_OUT=0;
#cat <<EOF
#
#Entradas adicionadas:
#
#EOF
#while read F_EXT
#do
#    diff $F_EXT $F_LOCAL | grep "< alias" | sed 's/< //' >> $F_LOCAL
#
#    ## Retorna os novos alias.
#    VALID_EN=$(diff $F_EXT $F_LOCAL | grep "< alias" | sed 's/< //' | wc -l)
#
#    if [ $VALID_EN -gt 0 ]; then
#      diff $F_EXT $F_LOCAL | grep "< alias" | sed 's/< //'
#      VALID_EN_OUT=1;
#    fi
#
#done < <(ls /ftphome/*/.config/abrt/.env_plq | grep -v $F_LOCAL)
#
#if [ $VALID_EN_OUT -eq 0 ]; then
#
#cat <<EOF
#Nao houve novas entradas.
#
#EOF
#
#fi
#sleep 3;
#f_option_inicial
#}



function f_option_inicial () {
clear

cat <<EOF
################################################################################################
# Informe o que vc quer fazer.

1 - Add novo alias.
2 - Verificar os alias existentes.
3 - Sair.

EOF

read -p "Escolha uma opcao: " V_OPTION


case $V_OPTION in
    1) f_addinst
    ;;
    2) clear;
       cat $FILE_ENV | grep alias | grep -v "alias ssh"
       sleep 3
       f_option_inicial
    ;;
    3) exit;
    ;;
    * )
clear
cat <<EOF
################################################################################################
# Opcao invalida.

Selecione novamente.

EOF
sleep 3
f_option_inicial
    ;;
esac

}

f_option_inicial







