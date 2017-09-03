#========================================================================================================================================
#==================================                                                              ========================================
#==================================                     COPIA DOS ARCHIVES                       ========================================
#==================================                                                              ========================================
#========================================================================================================================================
#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Copia archive para o standby
#-- Nome do arquivo     : jbExCopArch.sh/jbconf_copy_arch.sh
#-- Data de criação     : 01/07/2015
#-- Data de atualização : 22/03/2017
#-- -----------------------------------------------------------------------------------


rm -f /tmp/jbconf_copy_arch.sh

vi /tmp/jbconf_copy_arch.sh
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
fi

}

f_instance



function f_bkp_p (){
clear
cat <<EOF
#####################################################################################
Descrição: Local das pecas de backup/archive Producao

Exemplo: /backup/oracle/orcl/fisico

EOF

read -p "Informe o diretorio de backup da base $BANCO: " v_dirbkp_p
if [ -z "$v_dirbkp_p" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_bkp_p
fi
}

f_bkp_p



function f_bkp_s (){
clear
cat <<EOF
#####################################################################################
Descrição: Local das pecas de backup/archive STANDBY

Exemplo: /backup/oracle/orcl/fisico/standby

EOF
read -p "Informe o diretorio do lado do standby: " v_dirbkp_s
if [ -z "$v_dirbkp_s" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_bkp_s
fi
}

f_bkp_s




function f_ip (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe o IP do standby.

Exemplo: 192.168.50.4

EOF
read -p "Informe o IP do servidor de standby: " v_ip
if [ -z "$v_ip" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_ip
fi
}

f_ip




function f_alias (){
clear
cat <<EOF
##########################################################################################
Descrição: Informe uma parte do backup para servir como identificador das peças de backup.

Exemplo:
Nome do backup: db41_archive_4hrrl52g_1_1.rbkp

O Alias pode ser: arch

Backups atuais no diretorio $v_dirbkp_p. (Ultimos 5)
EOF
ls -lthr $v_dirbkp_p | grep -vi "full\|control" | tail -5
cat <<EOF


EOF
read -p "Informe o alias do backup: " v_alias
if [ -z "$v_ip" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_alias
fi
}

f_alias



clear

cat <<JHB




cat <<EOF>$STDB_HOME/config/$BANCO.conf
#-- -------------------------------------------------------------------------------
#-- IP do servidor de standby
#-- -------------------------------------------------------------------------------
stdb_ip=$v_ip

#-- -------------------------------------------------------------------------------
#-- Nome do banco de dados
#-- -------------------------------------------------------------------------------
oracle_sid=$BANCO

#-- -------------------------------------------------------------------------------
#-- Local das pecas de backup/archive Producao
#-- -------------------------------------------------------------------------------
dir_bkp=$v_dirbkp_p

#-- -------------------------------------------------------------------------------
#-- Local onde vai ser tranferido as pecas no servidor de standby
#-- -------------------------------------------------------------------------------
stdb_dir_bkp=$v_dirbkp_s

#-- -------------------------------------------------------------------------------
#-- Identificador do backup
#-- -------------------------------------------------------------------------------
bkp_alias=$v_alias

EOF






#+------------------------------------------------------------------------------------------------------------------------------+
## COPIA DOS ARCHIVES PARA STANDBY                                                                                              |
#+------------------------------------------------------------------------------------------------------------------------------+
# BANCO $BANCO
#+------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- -----------------------------------------------------------------------------------------+
  */35   *     *        *      *       $STDB_HOME/ExCopArch.sh $BANCO




JHB


}


if [ "$1" = "conf" ]; then
f_configure
else


if [ -d "$ORACLE_BASE/admin/scripts" ]; then STDB_HOME=$ORACLE_BASE/admin/scripts/standby; mkdir -p $STDB_HOME 2>>/dev/null;
elif [ -d "$ORACLE_BASE/admin/script" ]; then STDB_HOME=$ORACLE_BASE/admin/script/standby; mkdir -p $STDB_HOME 2>>/dev/null;
else STDB_HOME=$ORACLE_BASE/admin/scripts/standby; mkdir -p $STDB_HOME; fi

mkdir -p $STDB_HOME/log 2>>/dev/null;
mkdir -p $STDB_HOME/config 2>>/dev/null;


cat <<JHB> $STDB_HOME/ExCopArch.sh
#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 105
# (11) 3797-8299
# São Paulo - SP
#
# Atualizado em 24/10/2014
#
# Efetua copia dos archives no standby
#
# Versao para Linux
# \$1 ORACLE_SID

#
# Inicio
#


if [ -z "\$1" ]; then
  echo "Favor informar o nome do banco de dados."
  echo "\$0 <DB_NAME>"
  exit;
fi

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
#-- Carregar variaveis do bash_profile
#-- -------------------------------------------------------------------------------

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi


#-- -------------------------------------------------------------------------------
#-- Carrega parameters
#-- -------------------------------------------------------------------------------

while read line
    do
    p=\${line%=*}
    v=\${line#*=}
    case \$p in
      stdb_ip)
          STDB_IP=\$v
          ;;
      oracle_sid)
          SID=\$v
          ;;
      dir_bkp)
          DIR_BKP=\$v
          ;;
      stdb_dir_bkp)
          STDB_DIR_BKP=\$v
          ;;
      bkp_alias)
          BKP_ALIAS=\$v
    esac
done < \$PARFILE

export ORACLE_SID=\$SID

#-- -------------------------------------------------------------------------------
#-- Log da copia das pecas de backup
#-- -------------------------------------------------------------------------------
export STDB_DATA=\$(date +%d%m%Y_%T)
export STDB_LOG=\$STDB_HOME/log/copia_archive_\$ORACLE_SID\_\$STDB_DATA.log

#-- -------------------------------------------------------------------------------
#-- Nome do arquivo para procurar no find
#-- -------------------------------------------------------------------------------
FNAME="\$DIR_BKP/*\$BKP_ALIAS*"

#-- -------------------------------------------------------------------------------
#-- Analisar se o processo de copia esta em execucao
#-- -------------------------------------------------------------------------------
export STDB_STAT=\$(ps -ef | grep scp | grep "\$STDB_IP \$STDB_DIR_BKP\|\$STDB_IP:\$STDB_DIR_BKP" | wc -l)


if [ "\$STDB_STAT" -gt "0" ]
then
   echo "Ja esta copiando."
   exit;

fi

PERM=640
HEADER=\$(find \$FNAME 2>>/dev/null -type f -perm \$PERM -print | wc -l)

if [ "\$HEADER" -eq "0" ]; then
PERM=660
HEADER=\$(find \$FNAME 2>>/dev/null -type f -perm \$PERM -print | wc -l)
fi

if [ "\$HEADER" -eq "0" ]; then
   HOR_EXEC=\`date\`
   echo "Neste momento nao existe novas pecas de backup -- \$HOR_EXEC"
   echo "Neste momento nao existe novas pecas de backup -- \$HOR_EXEC" >> \$STDB_HOME/log/copia_archive_\$ORACLE_SID\_none.log
   exit
fi

echo ". Copiando archives para o servidor StandBy (\$STDB_IP) ..." >> \$STDB_HOME/log/copia_archive_\$ORACLE_SID.log
find \$FNAME 2>>/dev/null -type f -perm \$PERM -print | while read arquivo
do
   /usr/sbin/lsof \$arquivo 1>>/dev/null 2>>/dev/null
   if [ \$? -eq 1 ]; then

      echo "\$arquivo -> \$STDB_IP... "
      scp \$arquivo \$STDB_IP:\$STDB_DIR_BKP
      if [ \$? -eq 0 ]; then
         HOR_EXEC=\`date\`
         chmod 600 \$arquivo
         echo "\$arquivo -> \$STDB_IP, Ok. -- \$HOR_EXEC"
         echo "\$arquivo -> \$STDB_IP, Ok. -- \$HOR_EXEC" >> \$STDB_HOME/log/copia_archive_\$ORACLE_SID.log
      else
         HOR_EXEC=\`date\`
         echo "\$arquivo -> \$STDB_IP, ERRO.  -- \$HOR_EXEC"
         echo "\$arquivo -> \$STDB_IP, ERRO.  -- \$HOR_EXEC" >> \$STDB_HOME/log/copia_archive_\$ORACLE_SID\_erro.log
         exit
      fi
   else
     HOR_EXEC=\`date\`
     echo "\$arquivo -> \$STDB_IP, EM USO. Nao copiado -- \$HOR_EXEC" >> \$STDB_HOME/log/copia_archive_\$ORACLE_SID.log
   fi
done

exit


JHB



chmod +x $STDB_HOME/ExCopArch.sh
f_configure

fi

fi


#
## Fim
#
