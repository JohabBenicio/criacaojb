
rm -f jbacesso.sh
vi jbacesso.sh
i

#!/bin/bash

export ACESS_FILE_REG="$HOME/.acess_jb"
export ACESS_FILE="/tmp/.jbtemp"
export PAR1='#@#@qwertyuioplkj110002hgfdsazxcvbnm010QWERTYUI;OPMNBVCXZASDFGHJKL2456TGBNDJUYTG)HJK*&78901092!#a#@'
export PAR2='#rtyhnmjuiklop234516wy8sguQWERTYUIO;PLKJHGFDSAZXCZVBNM<Lco09876rs00001&%@%###%#W!#@#211T'
export IMP1='010GFQSCBDWaUYDA;VUBXIHWHSWOJAX KJAYSF)WGIKS AXAoiuytrewqasdfsvwbncme,loeijvhg2134567890###%@7decIds'
export IMP2='09876567UJNHYTRGBNMPQspoiuytrewqaqdcvbnm,lkjhgftyuiop;.,wxoiuytfzQWERTQFGDSBVXBK0987654321123456789)OIUHBDW'


clear
read -p "Deseja conectar em um cliente? Sim [ENTER] " CONNECT



if [ -f $ACESS_FILE_REG ]; then
clear
echo "Estamos descriptografando o arquivo de senha..."

# KEYS=$(cat $ACESS_FILE_REG)
# KEYS=${KEYS//"$PAR1"/}
# KEYS=${KEYS//"$PAR2"/}
# KEYS=${KEYS//"$IMP1"/}
# KEYS=${KEYS//"$IMP2"/}
# echo -e $KEYS | grep -v "^$" >$ACESS_FILE


KEYS=$(sed 's/"$PAR1"//g' $ACESS_FILE_REG)
echo $KEYS


| sed "s/$PAR2//g" | sed 's/"$IMP1"//g' | sed 's/"$IMP2"//g'

fi


function f_opcao (){

clear
cat <<EOF
#############################################################################
Deseja cadastrar dados de usuarios ou VPN?

EOF
read -p "Digite [ENTER] para VPN: " V_OPCAO

if [ -z $V_OPCAO ]; then
	f_cadastrar_vpn
else
	f_cadastrar_usuario
fi

}



function f_cadastrar_usuario (){
clear

if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
Cliente(s) cadastrados.

EOF
cat $ACESS_FILE | cut -d ";" -f 1 | sort | uniq

fi

cat <<EOF

#############################################################################
Informe o nome do cliente:

Exemplo: CVC

EOF
read -p "Digite o nome do cliente: " V_NOM_CLI

############################################################################################################################

clear

if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
IP(s) cadastrados.

EOF
grep "$V_NOM_CLI" $ACESS_FILE | grep -v ";VPN;" | cut -d ";" -f 2 | sort | uniq

fi

cat <<EOF

#############################################################################
Informe o IP para acessar o ambiente do cliente "$V_NOM_CLI"

Exemplo: 192.186.1.112

EOF
read -p "Digite o IP: " V_IP

############################################################################################################################


for i in {1..99}
do

clear


if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
Usuario(s) cadastrados.

EOF
grep "$V_NOM_CLI" $ACESS_FILE | grep -vi ";VPN;" | cut -d ";" -f 3 | sort | uniq

fi


for x in {1..99}
do

V_USER=$(eval echo \$V_USER_$x)

if [ -z $V_USER ]; then
	break
fi
echo $V_USER

done
cat <<EOF

#############################################################################
Informe o nome do usuario para acessar o IP [ $V_IP ]

Exemplo: oracle

Obs.: Digite [ENTER] para cessar.

EOF
read -p "Digite o nome do usuario: " V_USER_$i

V_USER=$(eval echo \$V_USER_$i)

if [ -z $V_USER ]; then
	break
fi

clear
cat <<EOF
#############################################################################
Informe o senha para acessar o usuario "$V_USER"

Exemplo: mudar123

EOF
read -p "Digite a senha do usuario [ $V_USER ]: " V_KEY_$i

done


############################################################################################################################

clear
cat <<EOF
#############################################################################
O primeiro acesso é via LocalWeb?

Digite [ENTER] para sim.

EOF
read -p "Digite sua opcao: " V_LOCALWEB

if [ -z $V_LOCALWEB ]; then
    V_LOCALWEB=1;
else
    V_LOCALWEB=2;
fi



############################################################################################################################

clear
if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
Descricoes existentes.

EOF
grep "$V_NOM_CLI" $ACESS_FILE | cut -d ";" -f 6 | sort | uniq

fi

cat <<EOF

#############################################################################
Informe uma descricao para essa conexao.

Exemplo: NAPEBSDB01 - Node 1

EOF
read -p "Digite a descricao: " V_DESC


############################################################################################################################


for i in {1..99}
do

V_USER=$(eval echo \$V_USER_$i)
V_KEY=$(eval echo \$V_KEY_$i)

if [ ! -z $V_USER ]; then

    LINE_CLIENT="$V_NOM_CLI;$V_IP;$V_USER;$V_KEY;$V_LOCALWEB;$V_DESC"

    LENG=$(echo "$LINE_CLIENT" | awk '{print length}')
    LINE="$LINE_CLIENT"

    for (( i=0; i<$LENG; i++ ))
    do
        if [ $(($i%2)) -eq '0' ]; then
            echo -n $PAR1${LINE:$i:1}$IMP1>>$ACESS_FILE_REG
        else
            echo -n $PAR2${LINE:$i:1}$IMP2>>$ACESS_FILE_REG
        fi
    done
    echo -n "\n">>$ACESS_FILE_REG

fi

done



}





function f_cadastrar_vpn (){
clear

if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
Cliente(s) cadastrados.

EOF
cat $ACESS_FILE | cut -d ";" -f 1 | sort | uniq

fi

cat <<EOF

#############################################################################
Informe o nome do cliente:

Exemplo: CVC

EOF
read -p "Digite o nome do cliente: " V_NOM_CLI

############################################################################################################################

for i in {1..99}
do

clear


if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
Usuarios de VPN(s) cadastrados.

EOF
grep "$V_NOM_CLI" $ACESS_FILE | grep -i ";VPN;" | cut -d ";" -f 3 | sort | uniq

fi


for x in {1..99}
do

V_USER=$(eval echo \$V_USER_$x)

if [ -z $V_USER ]; then
	break
fi
echo $V_USER

done
cat <<EOF

#############################################################################
Informe o nome do usuario para acessar a VPN.

Exemplo: teor

Obs.: Digite [ENTER] para cessar.

EOF
read -p "Digite o nome do usuario: " V_USER_$i

V_USER=$(eval echo \$V_USER_$i)

if [ -z $V_USER ]; then
	break
fi

clear
cat <<EOF
#############################################################################
Informe o senha para acessar o usuario "$V_USER"

Exemplo: mudar123

EOF
read -p "Digite a senha do usuario [ $V_USER ]: " V_KEY_$i

done


############################################################################################################################


for i in {1..99}
do

V_USER=$(eval echo \$V_USER_$i)
V_KEY=$(eval echo \$V_KEY_$i)

if [ ! -z $V_USER ]; then

    LINE_CLIENT="$V_NOM_CLI;VPN;$V_USER;$V_KEY"

    LENG=$(echo "$LINE_CLIENT" | awk '{print length}')
    LINE="$LINE_CLIENT"

    for (( i=0; i<$LENG; i++ ))
    do
        if [ $(($i%2)) -eq '0' ]; then
            echo -n $PAR1${LINE:$i:1}$IMP1>>$ACESS_FILE_REG
        else
            echo -n $PAR2${LINE:$i:1}$IMP2>>$ACESS_FILE_REG
        fi
    done
    echo -n "\n">>$ACESS_FILE_REG

fi

done



}








function f_conectar (){
clear




f_consulta



if [ -f $ACESS_FILE ]; then
cat <<EOF
#############################################################################
Cliente(s) cadastrados.

EOF

V_COUNT=0;

while read V_CLI
do
    V_COUNT=$(($V_COUNT+1))
    export V_CLI_$V_COUNT="$V_CLI"
    echo "$V_COUNT - $V_CLI"
done < <(cat $ACESS_FILE | cut -d ";" -f 1 | sort | uniq )

else
cat <<EOF
#############################################################################
Nao existe clientes cadastrados.

EOF
fi
cat <<EOF

EOF
read -p "Qual cliente vc deseja acessar? " V_COUNT

V_CLI=$(eval echo \$V_CLI_$V_COUNT)

if [ -z $V_CLI ]; then
    f_conectar
fi

############################################################################################################################


clear
cat <<EOF
##############################################################################
## Acesso ao cliente $V_CLI.

EOF
while read V_ACESSO
do

V_IP=$(echo $V_ACESSO | cut -d ";" -f 2 )
V_USER=$(echo $V_ACESSO | cut -d ";" -f 3 )
V_KEY=$(echo $V_ACESSO | cut -d ";" -f 4 )
V_LOCALWEB=$(echo $V_ACESSO | cut -d ";" -f 5 )
V_DESC=$(echo $V_ACESSO | cut -d ";" -f 6 )

if [ $V_LOCALWEB -eq 1 ]; then
cat <<EOF
#
##### Acesso via LocalWeb
EOF
fi

cat <<EOF
#
## $V_DESC
#

ssh $V_USER@$V_IP
Senha abaixo:
$V_KEY

sshpass -p '$V_KEY' ssh $V_USER@$V_IP

-----------------------------------------------------

EOF

done < <(grep "$V_CLI" $ACESS_FILE | sort | uniq)


}


#############################################################################################################################

if [ -z $CONNECT ]; then
	f_conectar
else
	f_opcao
fi


rm -f $ACESS_FILE

#
## Fim
#
