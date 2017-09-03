  21     20    *         *      *       /u01/app/oracle/admin/scripts/ods/bin/orabkp backup -j backup_full -d sprof
  */15   *     *         *      *       /u01/app/oracle/admin/scripts/ods/bin/orabkp backup -j backup_arch -d sprof
  00     21    *         *      *       /u01/app/oracle/admin/scripts/ods/bin/orabkp purge -j backup_arch -d sprof
  30     21    *         *      *       /u01/app/oracle/admin/scripts/ods/bin/orabkp purge -j backup_full -d sprof








h9z0u8f4@T30r


#################################################################################################################################################
#                                                     TEOR TECNOLOGIA ORIENTADA                                                                 #
#                                                          ROTINA DE BACKUP                                                                     #
#################################################################################################################################################
# Implementado em, 18 January de 2016.
# luiz liberado
# DBA Oracle - TEOR
#
#+----------------------------------------------------------------------------------------------------------------------------------------------+
## BACKUP FISICO - Full Database                                                                                                                |
##        Caminho das pecas do backup full rman - /backup/SPROF/fisico/
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# BANCO sprof
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay  Month  Weekday Command
# ------ ----- --------- ------ ------- --------------------------------------------------------------------------------------------------------+
  00     00    *         *      *       /u01/app/oracle/admin/sprof/script/backup/fisico/sh/bkp_full.sh sprof 1>/dev/null 2>/dev/null
  */15   *     *         *      *       /u01/app/oracle/admin/sprof/script/backup/fisico/sh/bkp_archive.sh sprof 1>/dev/null 2>/dev/null
  30     21    *         *      *       /u01/app/oracle/admin/sprof/script/backup/fisico/sh/bkp_crosscheck.sh sprof 1>/dev/null 2>/dev/null
  00     01    *         *      *       /u01/app/oracle/admin/sprof/script/backup/fisico/sh/limpa_logs.sh 1>/dev/null 2>/dev/null




#################################################################################################################################################
#                                                     TEOR TECNOLOGIA ORIENTADA                                                                 #
#                                                          ROTINA DE BACKUP                                                                     #
#################################################################################################################################################
# Implementado em, 19 February de 2016.
# Johab Benicio
# DBA Oracle - TEOR
#
#+----------------------------------------------------------------------------------------------------------------------------------------------+
## BACKUP FISICO - Full Database                                                                                                                |
##        Caminho das pecas do backup full rman - /backup/SPROF/fisico/
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# BANCO sprof
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay  Month  Weekday Command
# ------ ----- --------- ------ ------- --------------------------------------------------------------------------------------------------------+
  00     00    *         *      *       orabkp backup -j backup_full -d sprof
  */15   *     *         *      *       orabkp backup -j backup_arch -d sprof
  00     21    *         *      *       orabkp purge -j backup_arch -d sprof
  30     21    *         *      *       orabkp purge -j backup_full -d sprof





#################################################################################################################################################
#                                                     TEOR TECNOLOGIA ORIENTADA                                                                 #
#                                                          ROTINA DE BACKUP                                                                     #
#################################################################################################################################################
# Implementado em, 19 February de 2016.
# Johab Benicio
# DBA Oracle - TEOR
#
#+----------------------------------------------------------------------------------------------------------------------------------------------+
## BACKUP FISICO - Full Database                                                                                                                |
##        Caminho das pecas do backup full rman - /backup/SPROF/fisico/
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# BANCO sprof
#+----------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay  Month  Weekday Command
# ------ ----- --------- ------ ------- --------------------------------------------------------------------------------------------------------+
  48     21    *         *      *       /u01/app/oracle/admin/scripts/ods/sh/bkp_full.sh        orabkp backup -j backup_full -d sprof
  */15   *     *         *      *       /u01/app/oracle/admin/scripts/ods/sh/bkp_archive.sh     orabkp backup -j backup_arch -d sprof
  00     21    *         *      *       /u01/app/oracle/admin/scripts/ods/sh/bkp_crosscheck.sh  orabkp purge -j backup_arch -d sprof



  48     21    *         *      *       /u01/app/oracle/admin/scripts/ods/sh/bkp_full.sh       1>/dev/null 2>/dev/null
  */15   *     *         *      *       /u01/app/oracle/admin/scripts/ods/sh/bkp_archive.sh    1>/dev/null 2>/dev/null
  00     21    *         *      *       /u01/app/oracle/admin/scripts/ods/sh/bkp_crosscheck.sh 1>/dev/null 2>/dev/null



/home/oracle/.bash_profile




limpa_logs.sh




  /u01/app/oracle/admin/scripts/ods/bin/orabkp backup -j backup_full -d sprof  1>/dev/null 2>/dev/null


cat <<EOF>/u01/app/oracle/admin/scripts/ods/sh/bkp_full.sh
#!/bin/bash
. /home/oracle/.bash_profile

orabkp backup -j backup_full -d sprof

EOF



cat <<EOF>/u01/app/oracle/admin/scripts/ods/sh/bkp_archive.sh
#!/bin/bash
. /home/oracle/.bash_profile

orabkp backup -j backup_arch -d sprof

EOF

cat <<EOF>/u01/app/oracle/admin/scripts/ods/sh/bkp_crosscheck.sh
#!/bin/bash
. /home/oracle/.bash_profile

orabkp purge  -j backup_arch -d sprof
orabkp purge  -j backup_full -d sprof

EOF






  /u01/app/oracle/admin/scripts/ods/bin/orabkp purge  -j backup_arch -d sprof
  /u01/app/oracle/admin/scripts/ods/bin/orabkp purge  -j backup_full -d sprof



backup_arch.job_type=rman_archive
backup_arch.job_duration=2m
backup_arch.job_frequency=15m
backup_arch.rman_compressed=yes
backup_arch.rman_delete_archive=input

oracle_home=/u01/app/oracle/product/11.2.0/db
rman_device_type=disk
rman_channels=1






Nome da instancia:............ sprof
Nome do banco de dados:....... SPROF
Status do banco:.............. OPEN
Startup Time:................. 01/02/2016 18:12
Open Mode:.................... READ WRITE
Modo Archive:................. ARCHIVELOG
Versao do RDBMS:.............. Oracle Database 11g Release 11.2.0.4.0 - 64bit Production




export ODS_HOME=/u01/app/oracle/admin/scripts/ods

rman_disk_destination=/backup/SPROF/fisico
instance_list=sps01,sprof
rman_retention_policy=3d

backup_full.job_type=rman_full
backup_full.job_duration=5h
backup_full.job_frequency=1d
backup_full.rman_compressed=yes
backup_full.rman_db_plus_archivelog=yes

archives.job_type=rman_archive
archives.job_duration=2m
archives.job_frequency=30m
archives.rman_compressed=yes
archives.rman_delete_archive=input



backup_full.job_type=rman_full
backup_full.job_duration=5h
backup_full.job_frequency=1d
backup_full.rman_compressed=yes
backup_full.rman_db_plus_archivelog=yes


incremental.job_type=rman_l0
incremental.job_duration=50
incremental.job_frequency=7
incremental.rman_compressed=yes
incremental.rman_db_plus_archivelog=yes





vi find_backup.sh
i
#!/bin/bash

#================================================================================
#
#  Programa :  check_backup_fisico.sh
#
#  Objetivo :  Checar se existem backup com falha ou em execução fora do horario.
#              Mapeamento de Valores para o Zabbix
#                0 - Backup OK.
#                1 - Backup Atrasado.
#                2 - Backup com Falha.
#
#  Linguagem:  Bash
#
#  Data     :  Mon Feb 22 12:42:54 BRT 2016
#
#  Versão   :  $Revision: 128 $
#
#
#  Copyright (c) 2014 Teor Tecnologia da Informação.
#  Todos os Direitos Reservados
#
#  Redistribuição e uso em formatos fonte ou binário, com ou sem modificação
#  são permitidos desde que observadas as condições expressas abaixo:
#
#        * Redistribuições do código fonte precisam manter os textos de Copyright
#          acima descritos, esta lista de condições e outras declarações
#
#        * Redistribuições em formato binário precisam reproduzir os textos de
#          Copyright acima, esta lista de condições e outras declarações de propri-
#          edade na documentação final do produto e/ou quaisquer outras materiais
#          providos com a distribuição
#
#        * O nome da "Optimode Sistemas", assim como os nomes de quaisquer outras
#          empresas/entidades que contribuiram para este projeto não podem ser uti-
#          lizados para endoçar ou promover produtos derivados deste código fonte
#          sem autorização prévia.
#
#        * Versões modificadas deste código fonte precisam ser claramente identifi-
#          cadas como "Versões Modificadas" e não podem ser apresentadas como
#          "Versão Original do Fonte"
#
#ESTE SOFTWARE É FORNECIDO PELO PROPRIETÁRIO ACIMA CITADO E OUTRAS EMPRESAS
#CONTRIBUINTES 'COMO VISTO AGORA' E QUAISQUER GARANTIAS EXPLÍCITAS OU IMPLÍCITAS,
#INCLUDINDO MAS NÃO LIMITADO ÀS GARANTIAS DE MERCADO E APLICABILIDADE PARA UM
#PROPÓSITO PARTICULAR SÃO DECLARADAS. EM CIRCURSTÂNCIA ALGUMA ESTARÃO OS CRIA-
#DORES DESTE PROGRAMA SUJEITOS À PENALIDADES POR QUAISQUER DANOS CAUSADOS PELO
#USO DESTE PROGRAMA, INCLUINDGO, MAS NÃO LIMITADO A, PERDA DE SERVIÇO, PERDA DE
#DADOS, PERDA DE LUCRATIVIDADE OU INTERRUPÇÃO DE NEGÓCIO.
#================================================================================

export ODS_HOME=/u01/app/oracle/admin/scripts/ods

echo "{\"data\":["
ls $ODS_HOME/config/ | cut -d "." -f 1 | while read fileconf
do
JOBNAMELAST=$(cat $ODS_HOME/config/$fileconf.conf | grep -i job_type | cut -d "." -f 1 | tail -1)
cat $ODS_HOME/config/$fileconf.conf | while read parameters
do
NUM=$(echo $parameters | grep -i job_type | wc -l)
JOBNAME=$(echo $parameters | grep -i job_type | cut -d "." -f 1)
if [ ! -z "$JOBNAME" ] && [ "$JOBNAME" != "$JOBNAMELAST" ]; then
cat <<EOF
 {"{#JOBNAME}":"$JOBNAME","{#DBNAME}":"$fileconf"},
EOF
fi
if [ ! -z "$JOBNAME" ] && [ "$JOBNAME" = "$JOBNAMELAST" ]; then
cat <<EOF
 {"{#JOBNAME}":"$JOBNAME","{#DBNAME}":"$fileconf"}
EOF
fi
done
done
echo "]}"














{"{#JOBNAME}":"$JOBNAME","{#DBNAME}":"$fileconf"},

#!/bin/bash


OUTPUT="{\"{#JOBNAME}\":\"$JOBNAME\",\"{#DBNAME}\":\"$DBNAME\"}"










rm -f find_backup.sh
vi find_backup.sh
i
#!/bin/bash

#================================================================================
#
#  Programa :  check_backup_fisico.sh
#
#  Objetivo :  Checar se existem backup com falha ou em execução fora do horario.
#              Mapeamento de Valores para o Zabbix
#                0 - Backup OK.
#                1 - Backup Atrasado.
#                2 - Backup com Falha.
#
#  Linguagem:  Bash
#
#  Data     :  Mon Feb 22 12:42:54 BRT 2016
#
#  Versão   :  $Revision: 128 $
#
#
#  Copyright (c) 2014 Teor Tecnologia da Informação.
#  Todos os Direitos Reservados
#
#  Redistribuição e uso em formatos fonte ou binário, com ou sem modificação
#  são permitidos desde que observadas as condições expressas abaixo:
#
#        * Redistribuições do código fonte precisam manter os textos de Copyright
#          acima descritos, esta lista de condições e outras declarações
#
#        * Redistribuições em formato binário precisam reproduzir os textos de
#          Copyright acima, esta lista de condições e outras declarações de propri-
#          edade na documentação final do produto e/ou quaisquer outras materiais
#          providos com a distribuição
#
#        * O nome da "Optimode Sistemas", assim como os nomes de quaisquer outras
#          empresas/entidades que contribuiram para este projeto não podem ser uti-
#          lizados para endoçar ou promover produtos derivados deste código fonte
#          sem autorização prévia.
#
#        * Versões modificadas deste código fonte precisam ser claramente identifi-
#          cadas como "Versões Modificadas" e não podem ser apresentadas como
#          "Versão Original do Fonte"
#
#ESTE SOFTWARE É FORNECIDO PELO PROPRIETÁRIO ACIMA CITADO E OUTRAS EMPRESAS
#CONTRIBUINTES 'COMO VISTO AGORA' E QUAISQUER GARANTIAS EXPLÍCITAS OU IMPLÍCITAS,
#INCLUDINDO MAS NÃO LIMITADO ÀS GARANTIAS DE MERCADO E APLICABILIDADE PARA UM
#PROPÓSITO PARTICULAR SÃO DECLARADAS. EM CIRCURSTÂNCIA ALGUMA ESTARÃO OS CRIA-
#DORES DESTE PROGRAMA SUJEITOS À PENALIDADES POR QUAISQUER DANOS CAUSADOS PELO
#USO DESTE PROGRAMA, INCLUINDGO, MAS NÃO LIMITADO A, PERDA DE SERVIÇO, PERDA DE
#DADOS, PERDA DE LUCRATIVIDADE OU INTERRUPÇÃO DE NEGÓCIO.
#================================================================================

export ODS_HOME=/u01/app/oracle/admin/scripts/ods

COMA=""
OUTPUT=""
echo "{\"data\":["
while read fileconf;
    do
    DBNAME=$(echo $fileconf | cut -d "." -f 1)
    while read -r jobline;
      do
        if [[ $jobline =~ job_type* ]];
           then
             JOBNAME=$(echo $jobline | awk -F. '{print $1}')
             export OUTPUT=$OUTPUT$COMA\{\"{#JOBNAME}\":\"$JOBNAME\",\"{#DBNAME}\":\"$DBNAME\"\}
             COMA=","
        fi
    done < $ODS_HOME/config/$fileconf
done < <(ls $ODS_HOME/config/)
echo $OUTPUT
echo "]}"























*.conf
















COMA=""
OUTPUT=""
while read fileconf;
    do
    while read -r jobline;
      do
             if [[ $jobline =~ job_type* ]];
               then
                 JOBNAME=$(echo $jobline | awk -F. '{print $1}')
                 export OUTPUT=$OUTPUT$COMA$JOBNAME
                 COMA=","
               fi
      done < $fileconf
    done < <(ls $ODS_HOME/config/*.conf)
echo $OUTPUT












COMA= ""
OUTPUT=""
ls -1 $ODS_HOME/config/*.conf | while read fileconf
    do
        PAR=$(grep -i job_type $fileconf)
        if [ $? -eq 0 ];
            then
                JOBNAME=$(echo $PAR | awk -F. '{print $2}')
                OUTPUT=$OUTPUT$COMA$JOBNAME
                COMA=","
            fi
    done

echo $OUTPUT





#!/bin/bash

COMA=""
OUTPUT=""
while read fileconf;
    do
    while read -r jobline;
      do
             if [[ $jobline =~ job_type* ]];
               then
                 JOBNAME=$(echo $jobline | awk -F. '{print $1}')
                 export OUTPUT=$OUTPUT$COMA$JOBNAME
                 COMA=","
               fi
      done < $fileconf
    done < <(ls $ODS_HOME/config/*.conf)
echo $OUTPUT





SCRPTBKP=$($HOME_TEOR/bin/teorpar getpar -i $INSTANCENAME -physcr)  #busca no parameters.txt o caminho do script do backup fisico.











x={x:5:4}

export ODS_HOME=/u01/app/oracle/admin/scripts/backup/ods


ls $ODS_HOME/config/ | while read fileconf
do

echo -e "{\"data\":[ {\"{#JOBNAME}\":\"$(cat $ODS_HOME/config/$fileconf | grep -i job_type | cut -d "." -f 1)\",\"{#DBNAME}\":\"$(echo fileconf | cut -d "." -f 1)\"  ]}"
done




echo "{\"data\":["
ls $ODS_HOME/config/ | cut -d "." -f 1 | while read fileconf
do
cat $ODS_HOME/config/$fileconf.conf | while read parameters
do
NUM=$(echo $parameters | grep -i job_type | wc -l)
JOBNAME=$(echo $parameters | grep -i job_type | cut -d "." -f 1)
JOBNAMELAST=$(echo $parameters | grep -i job_type | cut -d "." -f 1 | tail -1)

if [ ! -z "$JOBNAME" ] && [ "$JOBNAME" != "$JOBNAMELAST" ]; then
cat <<EOF
 {"{#JOBNAME}":"$JOBNAME","{#DBNAME}":"$fileconf"},
EOF
elif [ "$JOBNAME" = "$JOBNAMELAST" ]; then
cat <<EOF
 {"{#JOBNAME}":"$JOBNAME","{#DBNAME}":"$fileconf"}
EOF
fi
done
done
echo "]}"









cat $ODS_HOME/config/jhbsml.conf | grep -i job_type | cut -d "." -f 1 | tail -1






















 {"{#JOBNAME}":"backup_full","{#DBNAME}":"jhbsml"}
 {"{#JOBNAME}":"incremental","{#DBNAME}":"jhbsml"}
 {"{#JOBNAME}":"archives","{#DBNAME}":"jhbsml"}
 {"{#JOBNAME}":"incremental1","{#DBNAME}":"jhbsml"}


COUNT=$(cat $ODS_HOME/config/$fileconf | grep -i job_type | cut -d "." -f 1 | wc -l)







{"data":[
        {"{#JOBNAME}":"ARCHIVE","{#DBNAME}":"SGAP"},
        {"{#JOBNAME}":"FISICO","{#DBNAME}":"SGAP"}
]}



echo "{\"data\":["




cat <<EOF>$ODS_HOME/config/default.conf
oracle_home=/u01/app/oracle/product/10.2.0/db_1
rman_device_type=disk
rman_channels=1
EOF


cat <<EOF>$ODS_HOME/config/jhbsml.conf
rman_disk_destination=/u01/backup/jhbsml/fisico
instance_list=jhbsml10g,jhbsml
rman_retention_policy=1d

backup_full.job_type=rman_full
backup_full.job_duration=90m
backup_full.job_frequency=1d
backup_full.rman_compressed=yes
backup_full.rman_db_plus_archivelog=yes

incremental.job_type=rman_l0
incremental.job_duration=90m
incremental.job_frequency=30m
incremental.rman_compressed=yes
incremental.rman_db_plus_archivelog=yes

archives.job_type=rman_archive
archives.job_duration=3m
archives.job_frequency=30m
archives.rman_compressed=yes
archives.rman_delete_archive=input

incremental1.job_type=rman_l1c
incremental1.job_duration=90m
incremental1.job_frequency=30m
incremental1.rman_compressed=yes
incremental1.rman_db_plus_archivelog=yes
EOF


orabkp backup -j archives -d jhbsml





backup_full.job_type=rman_full
backup_full.job_duration=5h
backup_full.job_frequency=1d
backup_full.rman_compressed=yes
backup_full.rman_db_plus_archivelog=yes

archives.job_type=rman_archive
archives.job_duration=2m
archives.job_frequency=15m
archives.rman_compressed=yes
archives.rman_delete_archive=input

















{"data":[
        {"{#JOBNAME}":"ARCHIVE","{#DBNAME}":"SGAP"},
        {"{#JOBNAME}":"FISICO","{#DBNAME}":"SGAP"}
]}





rm -f check_backup_rman.sh
vi check_backup_rman.sh
i
#!/bin/bash

ODS_HOME=/u01/app/oracle/admin/scripts/backup/ods
BKP_DB=$1
BKP_JOB=$2

function ajust_data (){
    cat $1 | grep $2 | sed 's/:/\//g' | sed 's/ /\//g' | sed 's/\/\//\//g' | cut -d "/" -f 2-6 | while read vdata; do echo $(echo v$vdata | cut -d "/" -f 3)$(echo v$vdata | cut -d "/" -f 2)$(echo $vdata | cut -d "/" -f 1)$(echo $vdata | cut -d "/" -f 4)$(echo $vdata | cut -d "/" -f 5); done
}

if [ ! -e "$ODS_HOME/bulletin/$BKP_DB.$BKP_JOB" ]; then
    echo "6";
    exit;
fi

ls $ODS_HOME/bulletin/$BKP_DB.$BKP_JOB | while read BKP_LOG
do

DATA_ATUAL=$(date +"%Y%m%d%H%M")
BKP_STATUS=$(cat $BKP_LOG | grep -E "(^| )STATUS:" | cut -d ":" -f 2 | sed 's/ //g')
BKP_EST_END=$(ajust_data $BKP_LOG EST_END_TIME)
BKP_NEXT=$(ajust_data $BKP_LOG NEXT_START_TIME)
RMAN_STATUS=$(cat $BKP_LOG | grep "RMAN_STATUS:" | cut -d ":" -f 2 | sed 's/ //g')

case $BKP_STATUS in
    RUNNING)
    if [ "$DATA_ATUAL" -gt "$BKP_EST_END" ]; then
        echo "1";
        exit;
    else
        echo "0";
        exit;
    fi
    ;;
    COMPLETED)
    if [ "$DATA_ATUAL" -gt "$BKP_NEXT" ]; then
        echo "2";
        exit;
    else
        echo "0";
        exit;
    fi
    ;;
    DEGRADED)
        echo "3";
        exit;
    ;;
    FAILURE)
    if [ "$RMAN_STATUS" = "FAILURE" ]; then
        echo "4";
        exit;
    else
        echo "5";
        exit;
    fi
    ;;
esac
done







