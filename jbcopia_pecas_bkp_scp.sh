
#+---------------------------------------------------------------------------------------------------------------+
# BANCO UNIDBPRD
#+---------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- --------------------------------------------------------------------------+


#+---------------------------------------------------------------------------------------------------------------+
## Script de envio do backup para o NFS
#+---------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- --------------------------------------------------------------------------+
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh DATAMED
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh FNDTISS
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh HENRY
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh PMED
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh SAE
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh SIIC
# JB  00     00-05 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh UNIDBPRD
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh DATAMED
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh FNDTISS
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh HENRY
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh PMED
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh SAE
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh SIIC
# JB  00     09-23 *        *      *       /opt/oracle/app/admin/scripts/copybkp/CopiaBackup.sh UNIDBPRD



#  192.168.97.72:/NFS  /mnt/backup                nfs     rsize=8192,wsize=8192,timeo=14,intr 0 0



########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################



if [ -d "$ORACLE_BASE/admin/scripts" ]; then
    export STAT_BASE=$ORACLE_BASE/admin/scripts
    mkdir -p $STAT_BASE/copybkp 2>>/dev/null
    export COPY_BKP_HOME_JB=$STAT_BASE/copybkp
elif [ -d "$ORACLE_BASE/admin/script" ]; then
    export STAT_BASE=$ORACLE_BASE/admin/script
    mkdir -p $STAT_BASE/copybkp 2>>/dev/null
    export COPY_BKP_HOME_JB=$STAT_BASE/copybkp
else
  mkdir -p $ORACLE_BASE/admin/scripts 2>>/dev/null
  export STAT_BASE=$ORACLE_BASE/admin/scripts
  mkdir -p $STAT_BASE/copybkp 2>>/dev/null
  export COPY_BKP_HOME_JB=$STAT_BASE/copybkp
fi

mkdir $COPY_BKP_HOME_JB/log
mkdir $COPY_BKP_HOME_JB/config
mkdir $COPY_BKP_HOME_JB/tmp




cat  $ODS_HOME/config/FNDTISS.conf



########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################

NAME_HOST=$(hostname)
VALID_HOST=$(echo $NAME_HOST | grep "." | wc -l)
rm -f /tmp/crontab_copy_bkp

if [ $VALID_HOST -gt 0 ]; then
    NAME_HOST=$(echo $NAME_HOST | cut -d "." -f 1 )
fi

ls $ODS_HOME/config | cut -d "." -f 1 | grep -v "default" | while read DB_FIND_BKP
do

DIR_BKP_LOCAL=$(grep "diario.rman_disk_destination" $ODS_HOME/config/$DB_FIND_BKP.conf | cut -d "=" -f 2)

cat <<EOF>$COPY_BKP_HOME_JB/config/$DB_FIND_BKP.conf
# Nome do banco de dados
database=$DB_FIND_BKP

# Diretorio externo
dir_externo=/mnt/backup/$NAME_HOST/fisico/$DB_FIND_BKP

# Diretorio do backup
dir_bkp=$DIR_BKP_LOCAL

# IP do servidor/storage externo.
ip_externo=192.168.97.72

# Retencao
retencao_dias=2

EOF


cat <<EOF
#+-------------------------------------------------------------------------------------------------------------------------+
## Script de envio do backup para o NFS
#+-------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay  Month  Weekday Command
# ------ ----- --------- ------ ------- -----------------------------------------------------------------------------------+
  00     00-05 *         *      *       $COPY_BKP_HOME_JB/CopiaBackup.sh $DB_FIND_BKP
  00     09-23 *         *      *       $COPY_BKP_HOME_JB/CopiaBackup.sh $DB_FIND_BKP

EOF


done




########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################


 COPY_BKP_HOME_JB=/opt/oracle/admin/scripts/copybkp


cd $COPY_BKP_HOME_JB

echo $COPY_BKP_HOME_JB

chmod +x $COPY_BKP_HOME_JB/CopiaBackup.sh


rm -f $COPY_BKP_HOME_JB/CopiaBackup.sh
vi $COPY_BKP_HOME_JB/CopiaBackup.sh
i
#!/bin/bash
# Pro4Tuning
#
# Funcao..: Copia o backup para uma particao externa.
# Arquivo.: CopiaBackup.sh
#
# Variaveis ORACE
. ~/.bash_profile


if [ -z $1 ]; then
cat <<EOF

Digite: $0 <nome da instancia>

EOF
exit;
fi;

# Lsof
LSOF='/usr/sbin/lsof'

# HOME do script de copia das peças de backup.
export COPY_HOME=/opt/oracle/admin/scripts/copybkp

# Arquivo de configuração da copia das peças de backup.
export FILE_CONFIG=$COPY_HOME/config/$1.conf

# Diretorio para os arquivos temporarios
export DIR_TMP=$COPY_HOME/tmp


# Valida a existencia do arquivo de configuracao.
if [ ! -e $FILE_CONFIG ]; then
   echo "Arquivo de configuracao \"$FILE_CONFIG\" nao encontrado."
   exit;
fi;

#
# Variaveis Locais
#

while read line
    do
    parameter=${line%=*}
    value=${line#*=}
    case $parameter in
      database)
        DBNAME=$value
          ;;
      dir_bkp)
        DIRBKP=$value
          ;;
      dir_externo)
        DIREXT=$value
          ;;
      ip_externo)
        IPEXT=$value
          ;;
      retencao_dias)
        RETENCAO=$value
    esac
done < $FILE_CONFIG

# Log das copias de backup
export LOGCP=$COPY_HOME/log/cp_bkp_$DBNAME.log

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
VALID=$(ps -ef | grep "$0 $1" | grep -v grep | awk '{print $2" "$3}' | grep -v $$ | wc -l)
if [ "$VALID" -gt "0" ]; then
echo -e "\nProcesso de copia ja esta em execucao. Este processo esta sendo Abortado.  $(date +"%d/%m/%Y %H:%M:%S") \n" >>$LOGCP
exit
fi


# Arquivo com historico de pecas copiadas.
export HIST_BKP_CP=$DIR_TMP/hist_cp_$DBNAME

# Log do processo de copia
export LOGCP=$COPY_HOME/log/cp_bkp_$DBNAME.log

# Valida a existencia do arquivo que contem o historico das pecas de backups copiados.
if [ ! -e $HIST_BKP_CP ]; then
   touch $HIST_BKP_CP
fi;


# Inicio do procedimento de copia
echo -e "\n. Inicio do procedimento de copia das pecas de backup para particao externa. $(date) \n" >>$LOGCP

find $DIRBKP -type f | while read files_bkp
do

  $LSOF $files_bkp

  if [ $? -gt 0 ]; then
    VALID=$(grep "$files_bkp" $HIST_BKP_CP | wc -l)

    if [ $VALID -eq 0 ]; then

      # Geracao do codigo md5 da peca local
      MD5_LOCAL=$(md5sum $files_bkp | awk '{print $1}')

      echo -n "Copiando o arquivo $files_bkp para $DIREXT... $(date +"%d/%m/%Y %H:%M:%S") - " >>$LOGCP

      # Executa a copia das pecas
      cp $files_bkp $DIREXT/

      # Validacao de integridade da copia
      if [ "$?" -eq "0" ]; then
        ARQ=$(basename $files_bkp )

        # Geracao do codigo md5 da peca copiada
        MD5_EXTERNO=$(find $DIREXT/$ARQ -exec md5sum {} \; | awk '{print $1}')

        if [ "$MD5_LOCAL" = "$MD5_EXTERNO" ]; then

            # Carrega as informacoes no log.
            echo "$(date +"%d/%m/%Y %H:%M:%S") | Ok." >>$LOGCP
            echo -e "|-- MD5 $MD5_LOCAL -> $files_bkp" >>$LOGCP
            echo -e "\`-- MD5 $MD5_EXTERNO -> $DIREXT/$ARQ \n" >>$LOGCP

            # Carrega as informacoes no log de arquivos copiados com sucesso.
            echo "$files_bkp $(date +"%Y%m%d")" >> $HIST_BKP_CP

        else
           echo " # ERRO NO MD5 #" >>$LOGCP
        fi
      else
        echo " # ERRO NA COPIA -> REDE # " >>$LOGCP
        exit 1
      fi
    fi
  fi

done


#
## Purge das peças de backup no diretorio externo.
#

while read file_remove
do
  DATA_ATUAL=$(echo "$(date +"%Y%m%d") - $RETENCAO" | bc)
  DATA_FILE=$(echo $file_remove | cut -d " " -f 2)

  if [ $DATA_FILE -lt $DATA_ATUAL ] || [ $DATA_FILE -eq $DATA_ATUAL ]; then
    vfile=$(echo $file_remove | cut -d " " -f 1)
    NAME_REMOVE=$(echo $vfile | sed 's/.*\///g')

    if [ -e "$DIREXT/$NAME_REMOVE" ]; then
      rm -fv $DIREXT/$NAME_REMOVE >> $DIR_TMP/removed_backup.log
    fi;

  fi
done < $HIST_BKP_CP

# Prepara os arquivos a serem removidos.
find $DIREXT -mtime +$RETENCAO -type f | while read can_rem
do
  rm -fv $can_rem >> $DIR_TMP/removed_backup.log
done;


#
# Fim
#




