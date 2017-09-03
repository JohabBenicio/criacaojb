#!/bin/bash
# TEOR Tecnologia Orientada
#
# Funcao..: Copia o backup para uma particao externa.
# Arquivo.: CopiaBackup.sh
#
# Variaveis ORACE
. ~/.bash_profile

# IP da particao externa
export IPEXT=192.168.0.29

# Tempo em minutos das pecas para copia
export TEMPCP=10

# Log do processo de copia
export LOGCP=/u01/backup/log/CopiaBackup.log

# Diretorio onde se encontra o backup
export DIRBKP=/u01/backup/rman

# Diretorio externo
export DIREXT=/bkp_bd/bkp

# Validar que o backup full nao esta rodando
export EXEC_FULL=$(ps -ef | grep -i "bkp_full.rcv" | grep -vi grep | wc -l)

# Validar a hora
export HORA=$(date +"%H")

# Escolher se vau copiar archive ou backup full
if [ "$HORA" -eq "4" ] && [ "$HORA" -eq "5" ] && [ "$EXEC_FULL" -eq "0" ]; then
export FIND_BKP="$DIRBKP/full* $DIRBKP/FULL*"
else
export FIND_BKP="$DIRBKP/arch* $DIRBKP/ARCH* $DIRBKP/cont* $DIRBKP/CONT*"
fi

# Teste de acesso
ping $IPEXT -c 2 1>>/dev/null 2>>/dev/null
if [ "$?" -gt "0" ]; then
echo -e "\nSem comunicacao com IP $IPEXT. Este processo esta sendo Abortado.\n" >>$LOGCP
exit
fi

# Validacao de criacao de arquivo no diretorio
touch $DIREXT/teste
if [ "$?" -gt "0" ]; then
echo -e "\nFalha na tentativa de criacao de arquivo no diretorio $DIREXT. Este processo esta sendo Abortado.\n " >>$LOGCP
exit
else
rm -f $DIREXT/teste
fi

# Valida se ja existe um processo copiando backup para a particao externa
VALID0=$(ps -ef | grep "cp -p" | grep "$DIREXT" | grep -v grep | wc -l)
if [ "$VALID0" -gt "0" ]; then
echo -e "\nProcesso de copia ja esta em execucao. Este processo esta sendo Abortado.\n" >>$LOGCP
exit
fi

# Validar existencia de novos arquivos
COUNT=`find $FIND_BKP -mmin +$TEMPCP 2>>/dev/null | wc -l`
if [ "$COUNT" -gt "0" ]; then


# Inicio do procedimento de copia
echo -e "\n. Inicio do procedimento de copia das pecas de backup para particao externa. $(date) \n" >>$LOGCP
find $FIND_BKP -mmin +$TEMPCP 2>>/dev/null | while read arquivo
do

   echo -n "Copiando o arquivo $arquivo para $DIREXT..." >>$LOGCP

   # Geracao do codigo md5 da peca local
   MD51=$(md5sum $arquivo | awk '{print $1}')

   # Executa a copia das pecas
   cp -p $arquivo $DIREXT/

   # Validacao de integridade da copia
   if [ "$?" -eq "0" ]; then
      ARQ=$(basename $arquivo )

      # Geracao do codigo md5 da peca copiada
      MD52=$(find $DIREXT/$ARQ -exec md5sum {} \; | awk '{print $1}')

      if [ "$MD51" = "$MD52" ]; then
         echo " Ok." >>$LOGCP
         echo "|-- MD5 $MD51 -> $arquivo" >>$LOGCP
         echo -e "\`-- MD5 $MD52 -> $DIREXT/$ARQ \n" >>$LOGCP
         #rm -f $arquivo
      else
         echo " # ERRO NO MD5 #" >>$LOGCP
         exit 1
      fi
   else
      echo " # ERRO NA COPIA -> REDE # " >>$LOGCP
      exit 1
   fi
done

fi

#
# Fim
#




