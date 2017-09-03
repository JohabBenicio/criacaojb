

## CONFIGURE BACKUP OPTIMIZATION ON;
# Executar o comando acima no RMAN.

rm -f /tmp/jbconf_bkp_teor.sh

vi /tmp/jbconf_bkp_teor.sh
i
#!/bin/bash
clear

if [ -z "$ORACLE_BASE" ]; then
cat <<EOF


Favor setar a variavel ORACLE_BASE para continuar a configuracao do script.

Processo abortado!



EOF
exit;
fi


readonly ODU_COLOR_NORM="\033[0m"
readonly ODU_COLOR_BOLD="\033[1m"
readonly ODU_COLOR_GREEN="\033[1;32;40m"
readonly ODU_COLOR_RED="\033[1;31;40m"

export MSG_SUCESSO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"Ok"$ODU_COLOR_NORM"
export MSG_FALHA="$ODU_COLOR_BOLD$ODU_COLOR_RED"Falha"$ODU_COLOR_NORM"
export MSG_FINALIZADO="$ODU_COLOR_BOLD$ODU_COLOR_GREEN"FINALIZADO"$ODU_COLOR_NORM"

LINUX=$(uname | grep "Linux" | wc -l)

#if [ "$LINUX" -eq "0" ]; then
#  echo -e "\n\nScript criado e homologado para S.O. Linux! \n\n"
#  exit;
#fi

read -p "Informe o nome do cliente: " NCLI

NCLIENTE=$(echo $NCLI | sed 's/ //g')

read -p "Informe o seu nome: " NDBA

read -p "Vai enviar email? Sim (1): " ENV_EMAIL_BKP

if [ "$ENV_EMAIL_BKP" != "1" ] || [ -z "$ENV_EMAIL_BKP" ]; then export ENV_EMAIL_BKP=2; fi

if [ "$ENV_EMAIL_BKP" -eq "1" ]; then
  read -p "Informe seu email da teor. Exemplo: johab@teor.inf.br: " EMAIL_DBA

  if [ -z "$EMAIL_DBA" ]; then  echo -e "\n           Informe seu e-mail! \n\n"; exit; fi

  if [ "$EMAIL_DBA" = "1" ]; then EMAIL_DBA=johab@teor.inf.br; fi
fi

if [ -z "$EMAIL_DBA" ]; then export EMAIL_DBA=suporte@teor.inf.br; fi
clear
read -p "Backup de archive com [ DELETE INPUT ] ? Sim [ ENTER ] " DEL_INP

if [ -z "$DEL_INP" ]; then
DINPUT="delete input"
else
DINPUT=""
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
done < <(ps -ef | grep ora_smon | grep -iv "grep" | grep -iv "/" | sed 's/.*smon_\(.*\)$/\1/')

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




POSSIVEL_HOME=$(crontab -l | grep "$ORACLE_SID" | grep "bkp_full" | awk '{ if ($6 == "sh") print $7; else print $6}' | sed 's/\/sh\(.*\)//' )

if [ ! -z "$POSSIVEL_HOME" ]; then
  echo -e "\n\n $POSSIVEL_HOME \n\n"
fi


if [ -d "$ORACLE_BASE/admin/scripts" ]; then BACKUP_HOME=$ORACLE_BASE/admin/scripts/backup/$ORACLE_SID/fisico; mkdir -p $BACKUP_HOME 2>>/dev/null;
elif [ -d "$ORACLE_BASE/admin/script" ]; then BACKUP_HOME=$ORACLE_BASE/admin/script/backup/$ORACLE_SID/fisico; mkdir -p $BACKUP_HOME 2>>/dev/null;
else BACKUP_HOME=$ORACLE_BASE/admin/scripts/backup/$ORACLE_SID/fisico; mkdir -p $BACKUP_HOME; fi


echo -e "\n\n"
find $ORACLE_BASE/ -name "bkp_full.rcv" | grep "$ORACLE_SID" | while read BKP_DIR_POSSIEVEL
do
  DIR_OK=$(cat $BKP_DIR_POSSIEVEL 2>>/dev/null | grep -i "format '" | grep -i "\(.*\)full\(.*\)" | sed 's/\/full\(.*\)//' | cut -f2 -d "'")
  echo -e "$DIR_OK"
  find $DIR_OK | grep -i "full" | tail -1
  echo -e "\n"
done


read -p "Informe o diretório onde as peças de backup irão ser geradas: " BACKUP_DIR

if [ ! -d "$BACKUP_DIR" ]; then echo -e "\n\nEste diretorio nao existe! \n\n"; exit; fi


echo -e "\n\n"

#-- ---------------------------------------------------------
#-- CRIAR SEGUINTE DIRETÓRIOS NO $BACKUP_HOME

DIR_COMP_BKP=''

if [ -d "$BACKUP_HOME/config" ]; then
  DIR_COMP_BKP="$BACKUP_HOME/config"
fi
if [ -d "$BACKUP_HOME/data" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/data"
fi
if [ -d "$BACKUP_HOME/debug" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/debug"
fi
if [ -d "$BACKUP_HOME/log" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/log"
fi
if [ -d "$BACKUP_HOME/rman" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/rman"
fi
if [ -d "$BACKUP_HOME/sh" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/sh"
fi
if [ -d "$BACKUP_HOME/tmp" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/tmp"
fi
if [ -d "$BACKUP_HOME/crontab" ]; then
  DIR_COMP_BKP="$DIR_COMP_BKP $BACKUP_HOME/crontab"
fi

if [ ! -z "$DIR_COMP_BKP" ]; then

printf "%-102s" "Compactação dos scripts antigos."

tar -cvzf $BACKUP_HOME/backup_home_antigo_$(date +"%d%m%Y").tar.gz $DIR_COMP_BKP 1>/dev/null 2>/dev/null

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; rm -rf $DIR_COMP_BKP 1>/dev/null 2>/dev/null; else echo -e "[   $MSG_FALHA  ]"; fi

fi



printf "%-104s" "Criando diretórios necessários para criação dos scripts de backup."

mkdir $BACKUP_HOME/config 2>/dev/null
mkdir $BACKUP_HOME/data 2>/dev/null
mkdir $BACKUP_HOME/debug 2>/dev/null
mkdir $BACKUP_HOME/log 2>/dev/null
mkdir $BACKUP_HOME/rman 2>/dev/null
mkdir $BACKUP_HOME/sh 2>/dev/null
mkdir $BACKUP_HOME/tmp 2>/dev/null
mkdir $BACKUP_HOME/crontab 2>/dev/null

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

#-- ---------------------------------------------------------
#-- Fazer backup do crontab

printf "%-100s" "Backup do crontab atual."

crontab -l >> $BACKUP_HOME/crontab/crontab_`date +"%d%m%Y"`.bkp 2>>/dev/null

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

#-- ---------------------------------------------------------
#-- DENTRO DO DIRETÓRIO "CONFIG"

printf "%-102s" "Criando o arquivo de configuração \"backup.cfg\"."

cat <<EOF> $BACKUP_HOME/config/backup.cfg

$ORACLE_SID:$BACKUP_HOME:$NCLIENTE

EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi


#-- ---------------------------------------------------------
#-- DENTRO DO DIRETÓRIO "DATA"

printf "%-100s" "Criando o script de backup de archive \".rcv\"."


cat <<EOF> $BACKUP_HOME/data/bkp_archive.rcv

#!/bin/bash
#
# Backup dos archives
#

Run {
  Allocate Channel C1 Device Type Disk Maxpiecesize=2048M;
  backup as compressed backupset
  format '$BACKUP_DIR/arch_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_ARCHIVELOG' archivelog all $DINPUT;
  Release Channel C1 ;
}

exit

#
# Fim
#

EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi



#-- ------------------------------------------
#--  ESCREVER NO bkp_crosscheck.rcv

printf "%-100s" "Criando o script de crosscheck \".rcv\"."

cat <<EOF> $BACKUP_HOME/data/bkp_crosscheck.rcv

#!/bin/bash

#
# Realiza o CROSSCHECK para os backups anteriores
#
   Crosscheck Backup ;
   Crosscheck Archivelog all;
   Crosscheck Copy ;
   delete noprompt obsolete;
   delete noprompt expired backup;
   delete noprompt expired archivelog all;

Exit

#
# Fim
#

EOF


if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi



#-- ------------------------------------------
#-- ESCREVER NO bkp_full.rcv

printf "%-100s" "Criando o script de backup de full \".rcv\"."


cat <<EOF> $BACKUP_HOME/data/bkp_full.rcv

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
#
# Funcao..: Realiza backup do banco de dados via RMAN
# Arquivo.: backup.rcv
#
#
# Executa o Backup do Banco de Dados
#

run
{
  allocate channel c1 device type disk maxpiecesize=8G;

  backup as compressed backupset
  format '$BACKUP_DIR/full_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_FULL' database;
  backup as compressed backupset
  format '$BACKUP_DIR/arch_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_ARCHIVELOG' archivelog all;
  backup as compressed backupset
  format '$BACKUP_DIR/spfile_%s_%p_%t' tag='BKP_SPFILE' spfile ;
  backup as compressed backupset
  format '$BACKUP_DIR/control_%d_%s_%p_%D_%M_%Y_%t' tag='BKP_CONTROLFILE' current controlfile;

  release channel c1;
}

#
# Gera o backup do controlfile em formato texto
#

SQL "Alter Database Backup ControlFile To Trace As ''$BACKUP_DIR/controlfile_trace_$ORACLE_SID.sql'' Reuse" ;

#
# Gera um backup do Spfile se Utilizado
#

SQL "Create Pfile=''$BACKUP_DIR/pfile_$ORACLE_SID.ora'' From Spfile";

Exit

#
# Fim
#


EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi


#-- -----------------------------------------
#-- DENTRO DO DIRETÓRIO "DEBUG"
#Neste diretório não é preciso fazer nada.

#-- DENTRO DO DIRETÓRIO "LOG"
#Neste diretório não é preciso fazer nada.

#-- DENTRO DO DIRETÓRIO "RMAN"
#Normalmente este é o diretório onde vai ser gravado as peças de backup.


#-- -----------------------------------------
#-- DENTRO DO DIRETÓRIO "SH"

printf "%-102s" "Criando o script de execução do backup de archive"


cat <<EOF> $BACKUP_HOME/sh/bkp_archive.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8299
# São Paulo - SP
#
# Atualizado em 22/07/2014
#
# Efetua backup dos archives do banco de dados utilizando utilitario RMAN
#
# Versao para Linux
# \$1 ORACLE_SID

#
# Inicio
#

export ORACLE_HOME=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export PATH=$PATH
export NLS_DATE_FORMAT="dd/mm/yyyy hh24:mi"

export BACKUP_HOME=$BACKUP_HOME

BANCO=\`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |$)" | wc -l\`


if [ -z "\$1" ]; then
   echo "Digite: sh bkp_archive.sh <SID> ou bkp_archive.sh <SID>" ;
   exit 1;

elif [ "\$BANCO" -eq "1" ]; then
   export ORACLE_SID=\$1
else
   echo "Banco nao existe ou nao registrado" ;
   exit 1;
fi

# Variaveis Globais

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export DATA=\`date +%d%m%Y_%T\`
export ARQPAR=\$BACKUP_HOME/data/bkp_archive.rcv
export ARQLOG=\$BACKUP_HOME/log/bkp_archive_\$DATA.log

export VALID=\$(ps -ef | grep \$ARQPAR | grep -v "grep" | wc -l)

if [ "\$VALID" -gt "0" ]; then
  echo "Backup de archive ja esta em execucao."
  exit
fi

# Executa o backup, carregando os parametros do backup do arquivo

rman target / nocatalog cmdfile \$ARQPAR msglog \$ARQLOG


EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi





# --------------------------------------------

printf "%-102s" "Criando o script de execução do crosscheck"


cat <<EOF> $BACKUP_HOME/sh/bkp_crosscheck.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8299
# São Paulo - SP
#
# Atualizado em 22/07/2014
#
# Efetua o crosscheck utilizando utilitario RMAN
#
# Versao para Linux
# \$1 ORACLE_SID

#
# Inicio
#

export ORACLE_HOME=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export PATH=$PATH
export NLS_DATE_FORMAT="dd/mm/yyyy hh24:mi"

export BACKUP_HOME=$BACKUP_HOME

BANCO=\`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |$)" | wc -l\`


if [ -z "\$1" ]; then
   echo "Digite: sh bkp_crosscheck.sh <SID> ou bkp_crosscheck.sh <SID>" ;
   exit ;

elif [ "\$BANCO" -eq "1" ]; then
   export ORACLE_SID=\$1
else
   echo "Banco nao existe ou nao registrado" ;
   exit 1;
fi


# Variaveis Globais

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export DATA=\`date +%d%m%Y\`
export ARQPAR=\$BACKUP_HOME/data/bkp_crosscheck.rcv
export ARQLOG=\$BACKUP_HOME/log/bkp_crosscheck_\$DATA.log

# Executa o backup, carregando os parametros do backup do arquivo

rman target / nocatalog cmdfile \$ARQPAR msglog \$ARQLOG


EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi



#--------------------------------------------

printf "%-102s" "Criando o script de execução do backup full"

cat <<EOF> $BACKUP_HOME/sh/bkp_full.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8299
# São Paulo - SP
#
# Atualizado em 22/07/2014
#
# Efetua backup full do banco de dados utilizando utilitario RMAN
#
# Versao para Linux
# \$1 ORACLE_SID

#
# Inicio
#

export ORACLE_HOME=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export PATH=$PATH
export NLS_DATE_FORMAT="dd/mm/yyyy hh24:mi"

export BACKUP_HOME=$BACKUP_HOME

BANCO=\`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |$)" | wc -l\`


if [ -z "\$1" ]; then
   echo -e "\nDigite: sh bkp_full.sh <SID> ou bkp_full.sh <SID>" ;
   exit 1;

elif [ "\$BANCO" -eq "1" ]; then
   export ORACLE_SID=\$1
else
   echo "Banco nao existe ou nao registrado" ;
   exit 1;
fi

# Variaveis Globais

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export DATA=\`date +%d%m%Y\`
export ARQPAR=\$BACKUP_HOME/data/bkp_full.rcv
export ARQLOG=\$BACKUP_HOME/log/bkp_full_\$DATA.log

EMAIL_BKP=$ENV_EMAIL_BKP

export VALID=\$(ps -ef | grep \$ARQPAR | grep -v "grep" | wc -l)

if [ "\$VALID" -gt "0" ]; then
  echo "Backup full ja esta em execucao."
  exit
fi

# Executa o backup, carregando os parametros do backup do arquivo

rman target / nocatalog cmdfile \$ARQPAR msglog \$ARQLOG


if [ "\$EMAIL_BKP" -eq "1" ]; then
sh $BACKUP_HOME/sh/EmailBackup.sh
fi


EOF

if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi


#--------------------------------------------

printf "%-100s" "Criando o script responsavel pela limpeza dos logs."

cat <<EOF> $BACKUP_HOME/sh/limpa_logs.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
#
# Realiza a limpeza dos logs.
#
# Versao para Linux
# \$1 ORACLE_SID

#
# Inicio
#

. ~/.bash_profile

export BACKUP_HOME=$BACKUP_HOME

find \$BACKUP_HOME/log/ -name "*.log" -mtime +20 -print | while read arquivo
do
   rm -f \$arquivo
done


EOF




if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi


printf "%-100s" "Criando script de envio de e-mail."

cat <<EOF>$BACKUP_HOME/sh/EmailBackup.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
#
# Envio de email
#
# Versao para Linux
#

#
# Inicio
#

# Configuracao - EMAIL

export EMPRESA=\`cat \$BACKUP_HOME/config/backup.cfg | grep \$ORACLE_SID | cut -f3 -d":"\`
export DIR_TEMP=\`cat \$BACKUP_HOME/config/backup.cfg | grep \$ORACLE_SID | cut -f2 -d":"\`
export BACKUP_DIR=\$(cat $BACKUP_HOME/data/bkp_full.rcv | grep -i "format '" | grep -i "\(.*\)full\(.*\)" | sed 's/\/full\(.*\)//' | cut -f2 -d "'")


cat \$ARQLOG | grep "RMAN-\|ORA-" | grep -v WARNING > \$DIR_TEMP/tmp/erros1.tmp

# Variaveis Locais

ERROS1=\`cat \$DIR_TEMP/tmp/erros1.tmp | wc -l\`


if [ "\$ERROS1" -gt "0" ]; then
   echo "                                                                          " >\$DIR_TEMP/tmp/aviso.\$\$
   echo "*********************************************************************************************************" >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                  BKPMON                                  " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "--------------------------------------------------------------------------" >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                ERRO ENCONTRADO NO BACKUP FISICO FULL - \$ORACLE_SID      " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "--------------------------------------------------------------------------" >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " Sr. Administrador, favor verificar log do backup fisico full             " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " e entre em contato com algum DBA da Teor pelos fones abaixo:             " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " (11) 3797-8299/8250                                                      " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " Nome da empresa........: \$EMPRESA                                       " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " Localizacao do arquivo.: \$ARQLOG                                        " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " Hora da Notificacao....: \`date +"%d/%m/%Y %H:%M"\`                      " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "*********************************************************************************************************" >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo " Erro(s) encontrado(s):                                                   " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   tail -15 \$ARQLOG >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   cat \$DIR_TEMP/tmp/aviso.\$\$ >>\$DIR_TEMP/debug/log_erros.log

  sendEmail -f dbmonitor@teor.inf.br -t $EMAIL_DBA -s smtp.teor.inf.br:587 -u "BKPMON::\$EMPRESA::\$ORACLE_SID::Erros no backup fisico full." -o message-file=\$DIR_TEMP/tmp/aviso.\$\$ -xu "dbmonitor@teor.inf.br" -xp "ju5u6hxi"

  rm -f \$DIR_TEMP/tmp/aviso.\$\$ 2>>/dev/null

fi
rm \$DIR_TEMP/tmp/erros1.tmp 2>>/dev/null

if [ "\$ERROS1" -eq "0" ]; then

   BEGIN=\`cat \$ARQLOG | grep -i "Recovery Manager:"\` >>\$DIR_TEMP/tmp/aviso.\$\$

   find \$BACKUP_DIR/arch* \$BACKUP_DIR/full* \$BACKUP_DIR/spfile* \$BACKUP_DIR/contr* -mmin -420 | while read bkp
   do
   echo -n "        \$(date -r \$bkp)  ->  " >>\$DIR_TEMP/tmp/listbackup.log
   echo \$(ls \$bkp) >>\$DIR_TEMP/tmp/listbackup.log
   done

   echo "*********************************************************************************************************" >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "        Banco de dados - \$ORACLE_SID                                     " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "        BACKUP FISICO FULL REALIZADO COM SUCESSO (PARA O DISCO)           " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "        Localizacao do arquivo.: $BACKUP_DIR                              " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "        Hora da Notificacao....: \`date +"%d/%m/%Y %H:%M"\`               " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "        Inicio do Backup.......: \$BEGIN                                  " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "        Fim do Backup..........:                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   cat \$DIR_TEMP/tmp/listbackup.log >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "                                                                          " >>\$DIR_TEMP/tmp/aviso.\$\$
   echo "*********************************************************************************************************" >>\$DIR_TEMP/tmp/aviso.\$\$

  sendEmail -f dbmonitor@teor.inf.br -t $EMAIL_DBA -s smtp.teor.inf.br:587 -u "BKPMON::\$EMPRESA::\$ORACLE_SID::Backup Fisico Full Banco de dados \$ORACLE_SID." -o message-file=\$DIR_TEMP/tmp/aviso.\$\$ -xu "dbmonitor@teor.inf.br" -xp "ju5u6hxi"

 rm -f \$DIR_TEMP/tmp/aviso.\$\$ 2>>/dev/null

fi

rm -f \$DIR_TEMP/tmp/listbackup.log 2>>/dev/null

EOF






if [ "$?" -eq "0" ]; then echo -e "[    $MSG_SUCESSO    ]"; else echo -e "[   $MSG_FALHA  ]"; fi

#-- DENTRO DO DIRETÓRIO "TMP" */
#Neste diretório não é preciso fazer nada.

chmod -R 755 $BACKUP_HOME 1>/dev/null 2>/dev/null

chown -R oracle:oinstall $BACKUP_HOME 1>/dev/null 2>/dev/null


#--   EDITAR CRONTAB
echo -e "\n\nConfiguração do backup executado com sucesso!"

cat <<EOF


Execute as seguintes comandos no RMAN

CONFIGURE BACKUP OPTIMIZATION ON;
CONFIGURE CONTROLFILE AUTOBACKUP ON;
CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '$BACKUP_DIR/control_%F';
CONFIGURE RETENTION POLICY TO RECOVERY WINDOW OF 0 DAYS;



#################################################################################################################################################
#                                                     TEOR TECNOLOGIA ORIENTADA                                                                 #
#                                                          ROTINA DE BACKUP                                                                     #
#################################################################################################################################################
# Implementado em, `date +"%d %B de %Y"`.
# $NDBA
# DBA Oracle - TEOR
#
#+----------------------------------------------------------------------------------------------------------------------------------------------+
## BACKUP FISICO - Full Database                                                                                                                |
##        Caminho das pecas do backup full rman - $BACKUP_DIR
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# BANCO $(echo $ORACLE_SID | tr [a-z] [A-Z])
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay  Month  Weekday Command
# ------ ----- --------- ------ ------- --------------------------------------------------------------------------------------------------------+
  00     20    *         *      *       $BACKUP_HOME/sh/bkp_full.sh $ORACLE_SID
  00     *     *         *      *       $BACKUP_HOME/sh/bkp_archive.sh $ORACLE_SID
  30     22    *         *      *       $BACKUP_HOME/sh/bkp_crosscheck.sh $ORACLE_SID
  00     01    *         *      *       $BACKUP_HOME/sh/limpa_logs.sh

EOF




