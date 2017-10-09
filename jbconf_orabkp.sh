

rm -f /tmp/confbkp.sh
vi /tmp/confbkp.sh
i
#!/bin/bash

case $1 in
    "cron")
cat <<EOF

ODS_HOME=$ODS_HOME
##################################################################################################################
#                                    TEOR TECNOLOGIA ORIENTADA                                                   #
#                                         ROTINA DE BACKUP                                                       #
##################################################################################################################
# Implementado em, `date +"%d %B de %Y"`.
#
#+---------------------------------------------------------------------------------------------------------------+
## BACKUP FISICO                                                                                                 |
EOF
while read backups
do
DB=${backups%.*}
cat <<EOF

#+---------------------------------------------------------------------------------------------------------------+
# BANCO $DB
#+---------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- --------------------------------------------------------------------------+
EOF
while read v_jobs
do
JOB=${v_jobs%.*}
cat <<JB
  00     00    *        *      *       \$ODS_HOME/bin/orabkp backup -d $DB -j $JOB
JB
done < <(cat $ODS_HOME/config/$backups | grep -i "job_type")
while read v_jobs
do
JOB=${v_jobs%.*}
cat <<JB
  00     00    *        *      *       \$ODS_HOME/bin/orabkp purge -d $DB -j $JOB
JB
done < <(cat $ODS_HOME/config/$backups | grep -i "job_type")
done < <(ls $ODS_HOME/config | grep -vi "default.conf" | grep ".conf")
echo -e "\n\n"
exit

;;
esac


if [ -z "$ODS_HOME" ]; then
clear
cat <<EOF
################################################################################

                      Carregue a variavel ODS_HOME

################################################################################
EOF
exit
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
else
DATABASE=$BANCO
fi

}

f_instance


function f_jnome (){
clear
unset v_job
cat <<EOF
################################################################################
1: diario
2: semanal
3: mensal
4: anual
5: archive

EOF
read -p "Informe o nome do job: " v_job
if [ -z "$v_job" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jnome
fi
case $v_job in
    1) v_job=diario;v_val=1 ;;
    2) v_job=semanal;v_val=1 ;;
    3) v_job=mensal;v_val=1 ;;
    4) v_job=anual;v_val=1 ;;
    5) v_job=archive;v_val=0 ;;
    *) echo "Opcao nao valida, tente novamente." sleep 2; f_jnome
esac
}

f_jnome


function f_plusarch () {
if [ "$v_val" -eq "1" ]; then
clear
cat <<EOF
################################################################################
1: Sim
2: Nao

EOF
read -p "Plus archive? " rman_db_plus_archivelog
case $rman_db_plus_archivelog in
    1) plus_arch="$v_job.rman_db_plus_archivelog=Y" ;;
    2) plus_arch="$v_job.rman_db_plus_archivelog=N" ;;
    *) echo "Opcao nao valida, tente novamente."; sleep 2; f_plusarch
esac

fi
}

f_plusarch


function f_device_type (){
clear
cat <<EOF
################################################################################
Descrição: Especifica o tipo de canal RMAN que deve ser alocado para o backup.
1: Disco
2: Fita

EOF
read -p "Informe o tipo de device: " rman_device_type
if [ -z "$rman_device_type" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_device_type
fi

case $rman_device_type in
    1) rman_device_type=disk;;
    2) rman_device_type=sbt_tape;;
    *) echo "Opcao nao valida, tente novamente."; sleep 2; f_device_type;
esac
}

f_device_type

function f_jrman_disk_destination (){
clear
cat <<EOF
#######################################################################################
Especifica o diretório para gravação do backup RMAN quando o mesmo for feito em disco.

Valores Aceitos: Um path de sistema operacional válido.
Exemplo: /home/oracle/backups/diario

EOF
read -p "Informe o DIRETORIO onde ficara armazenado o backup [ Base $DATABASE ]: " rman_disk_destination
if [ -z "$rman_disk_destination" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jrman_disk_destination
fi
export DESTINO="$v_job.rman_disk_destination=$rman_disk_destination"
}

function f_jrman_device_parameters (){
clear
cat <<EOF
###############################################################################################
Especifica os parametros adicionais a serem usados durante a alocacao de canais de backup RMAN.
Este parâmetro é usado principalmente quando os canais de backup RMAN forem do tipo SBT_TAPE

Valores Aceitos: Texto. O formato varia de acordo com o software de backup em fita integrado ao RMAN.
Consulte documentação do produto de backup

EOF
read -p "Informe os parametros da fita (parms): " rman_device_parameters
if [ -z "$rman_device_parameters" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jrman_device_parameters
fi
export  DESTINO="rman_device_parameters=$rman_device_parameters"
}

VALID=$(echo $rman_device_type | grep "disk" | wc -l)

if [ $VALID -eq 1 ]; then
f_jrman_disk_destination
else
f_jrman_device_parameters
fi



function f_jtype (){
if [ "$v_val" -eq "1" ]; then
clear
cat <<EOF
################################################################################
# Informe o tipo de backup para o job de backup: $v_job

1: backup full
2: backup incremental nível 0
3: backup incremental nível 1
4: backup incremental nível 1 cumulativo

EOF
read -p "Informe o tipo do backup: " job_type
if [ -z "$job_type" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jtype
fi

case $job_type in
    1) job_type=rman_full ;;
    2) job_type=rman_l0 ;;
    3) job_type=rman_l1i ;;
    4) job_type=rman_l1c ;;
    *) echo "Opcao nao valida, tente novamente."; sleep 2; f_jtype;
esac
else
    job_type=rman_archive
fi
}

f_jtype


function f_jcannel (){
clear
cat <<EOF
################################################################################
Exemplos:
1
2
3
...

EOF
read -p "Informe a quantidade de canais: " rman_channels
if [ -z "$rman_channels" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jcannel
fi

}

f_jcannel


function f_jmaxpiecesize (){
clear
cat <<EOF
############################################################################
Descrição: Especifica o tamanho máximo de cada backuppiece gerado pelo RMAN: JOB DE BACKUP $v_job

Valores Aceitos: Numérico com um especificador em megabytes ou gigabytes.
Exemplos:
• 8G (oito gigabytes)
• 512M (quinhentos e doze megabytes)

EOF
read -p "Informe TAMANHO MAXIMO de cada peca de backup: " rman_maxpiecesize
if [ -z "$rman_maxpiecesize" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jmaxpiecesize
fi

}

f_jmaxpiecesize


function f_jfrequencia (){
clear
cat <<EOF
################################################################################
JOB DE BACKUP: $v_job
Exemplos:
Há duas formas de especificar este parâmetro, conforme abaixo:

Formato 1: especificação por intervalo de minutos, horas ou dias. Exemplos:
• 2h   (o backup roda a cada 2 horas)
• 30m  (o backup roda a cada 30 minutos)
• 4d   (o backup roda a cada 4 dias)

Formato 2: especificação baseada em calendário. Neste modelo é possível especificar com exatidão os dias e horários esperados de execução do backup. Exemplos:
• 23:30                     (o backup roda as 23:30)
• 14:00,18:00               (o backup roda as 14:00 e as 18:00)
• 22:00 seg,ter,qua,qui,sex (o backup roda de segunda a sexta as 22:00)
• 10:00,18:001,15           (o backup roda as 10:00 e as 18:00 nos dias 1 e 15 de cada mes)

EOF
read -p "Informe a FREQUENCIA: " job_frequency
if [ -z "$job_frequency" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jfrequencia
fi

}

f_jfrequencia


function f_jduration (){
clear
cat <<EOF
################################################################################
JOB DE BACKUP: $v_job

Descrição: Especifica a duração estimada do job. Este parâmetro é utilizado para gerar
dados adicionais para auxiliar no monitoramento de “atraso” dos backups.

• 30m (30 minutos)
• 2h  (2 horas)

EOF
read -p "Informe a DURACAO: " job_duration
if [ -z "$job_duration" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jduration
fi

}

f_jduration



function f_jrman_filesperset (){
clear
read -p "Deseja configurar o FILEPERSET? Sim (1) " VALID

if [ "$VALID" -eq "1" ] 2>>/dev/null; then
clear
cat <<EOF
################################################################################
Especifica o número de datafiles incluídos em cada backup set do RMAN..
Exemplo:
1
5
10
20
...

EOF
read -p "Informe a QUANTIDADE de arquivos por backup: " rman_filesperset
if [ -z "$rman_filesperset" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jrman_filesperset
fi

vFILEPERSET=$v_job.rman_filesperset=$rman_filesperset

fi

}

f_jrman_filesperset
clear



function f_home_oracle (){
clear
L=$(($(echo $DATABASE|wc -m)-2 ));
DB=$(echo $DATABASE | cut -c 1-$L);
if [ ! -e "$ODS_HOME/config/$DATABASE.conf" ] && [ ! -e "$ODS_HOME/config/$DB.conf" ]  ; then

cat <<EOF
################################################################################
# Homes existentes: /etc/oratab
EOF

    VALID=$(cat /etc/oratab | grep "$DATABASE\|$DB"|wc -l)

    if [ "$VALID" -gt "0" ]; then
        cat /etc/oratab | grep "$DATABASE\|$DB"
    else
        cat /etc/oratab | grep ":/"
    fi

    echo -e "\n"
    read -p "Informe no Oracle Home: " ORACLE_HOME
export ORACLE_SID=$DATABASE
$ORACLE_HOME/bin/rman target / <<EOF>/tmp/rman_parameters.txt
show all;
quit;
EOF

else

if [ -e "$ODS_HOME/config/$DATABASE.conf" ] 2>>/dev/null ; then
    OHOME=$(grep -i oracle_home $ODS_HOME/config/$DATABASE.conf)
else
    OHOME=$(grep -i oracle_home $ODS_HOME/config/$DB.conf)
fi

ORACLE_HOME=${OHOME#*=}
export ORACLE_SID=$DATABASE
$ORACLE_HOME/bin/rman target / <<EOF>/tmp/rman_parameters.txt
show all;
quit;
EOF

fi

}

f_home_oracle


function f_jretencao (){

cat <<EOF


###############################################################################
Descrição: Especifica a política para apagar os backups considerados obsoletos: : JOB DE BACKUP $v_job

Valores Aceitos: Especificação de expurgo após um número de horas ou dias.
Exemplos:
• 8h (o backup deve ser apagado quando tiver 8 ou mais horas de idade)
• 15d (o backup deve ser apagado quando tiver 15 ou mais dias de idade)

$(grep -i DBID /tmp/rman_parameters.txt)
(...)
$(grep -i RETENTION /tmp/rman_parameters.txt)

EOF
read -p "Informe a RETENCAO: " rman_retention_policy
if [ -z "$rman_retention_policy" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jretencao
fi

}

f_jretencao



function f_jretencao_archive (){

cat <<EOF


###############################################################################
Descrição: Excluir do disco os archived redo logs incluídos no job de backup ou que atendam à política de retenção em disco: JOB DE BACKUP $v_job

Valores Aceitos: Especificação de expurgo após um número de horas ou dias.
Exemplos:
• 8h (o backup deve ser apagado quando tiver 8 ou mais horas de idade)
• 15d (o backup deve ser apagado quando tiver 15 ou mais dias de idade)

EOF
read -p "Informe se deseja: " rman_retention_policy
if [ -z "$rman_retention_policy" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_jretencao_archive
fi

}

# f_jretencao_archive


function f_instance_list (){
instance_list=''
v_rac=''
L=$(($(echo $DATABASE|wc -m)-2 ));
DB=$(echo $DATABASE | cut -c 1-$L);

clear

cat <<EOF
############################################################
# Coletando os dados do da instancia e servidor...
EOF

srvctl status database -d $DATABASE >/tmp/confbkp.out

if [ "$?" -eq "0" ]; then

VALID=$(grep -i "Database is running." /tmp/confbkp.out | wc -l)

if [ $VALID -gt 0 ]; then
    instance_list=''
    DEL=''
    while read v_instance_list
    do
        ADB0=${v_instance_list#Instance }
        ADB1=${ADB0% is*}
        VHOST=${v_instance_list#*node }
        instance_list=$instance_list$DEL$VHOST,$ADB1$DEL
        DEL=':'
    done < <(srvctl status database -d $DATABASE)
    DB=$DATABASE
else
    DB=$DATABASE
    instance_list="$(hostname),$DB"
fi
else

    srvctl status database -d $DB >/tmp/confbkp.out

    if [ "$?" -eq "0" ]; then

        VALID=$(grep -i "Database is running." /tmp/confbkp.out | wc -l)

        if [ $VALID -gt 0 ]; then
            instance_list=''
            DEL=''
            while read v_instance_list
            do
                ADB0=${v_instance_list#Instance }
                ADB1=${ADB0% is*}
                VHOST=${v_instance_list#*node }
                instance_list=$VHOST,$ADB1$DEL$instance_list
                DEL=':'
            done < <(srvctl status database -d $DB)
        else
            DB=$DATABASE
            instance_list="$(hostname),$DB"
        fi
    else
        DB=$DATABASE
        instance_list="$(hostname),$DB"
    fi
fi

}



f_instance_list


clear
cat <<EOF
############################################################
# Comandos para configurar o backup

EOF

if [ ! -d "$ODS_HOME/config/" ]; then

cat <<EOF

mkdir $ODS_HOME/config


EOF
fi

if [ ! -e "$ODS_HOME/config/default.conf" ]; then

cat <<EOF

cat <<JB>>$ODS_HOME/config/default.conf
HANDLE_JOB_PRIORITY=yes
JB


EOF
fi

VALID=$(echo $DESTINO | grep "rman_device_parameters" | wc -l)

if [ $VALID -gt 0 ]; then
PARMS=$DESTINO
fi

if [ ! -e "$ODS_HOME/config/$DATABASE.conf" ] && [ ! -e "$ODS_HOME/config/$DB.conf" ]  ; then
cat <<EOF

cat <<JB>>$ODS_HOME/config/$DB.conf
ORACLE_HOME=$ORACLE_HOME
rman_device_type=$rman_device_type
instance_list=$instance_list
$PARMS

JB

EOF
fi


cat <<JB>/tmp/$DB.conf
#############################################
# JOB $v_job
#############################################

JB


VALID=$(echo $DESTINO | grep "rman_device_parameters" | wc -l)

if [ $VALID -eq 0 ]; then
if [ ! -z "$DESTINO" ]; then
echo "$DESTINO">>/tmp/$DB.conf
fi
fi

if [ ! -z "$job_type" ]; then
echo "$v_job.job_type=$job_type" >> /tmp/$DB.conf
fi
if [ ! -z "$rman_channels" ]; then
echo "$v_job.rman_channels=$rman_channels" >> /tmp/$DB.conf
fi
if [ ! -z "$rman_maxpiecesize" ]; then
echo "$v_job.rman_maxpiecesize=$rman_maxpiecesize" >> /tmp/$DB.conf
fi
if [ ! -z "$rman_retention_policy" ]; then
echo "$v_job.rman_retention_policy=$rman_retention_policy" >> /tmp/$DB.conf
fi
if [ ! -z "$job_frequency" ]; then
echo "$v_job.job_frequency=$job_frequency" >> /tmp/$DB.conf
fi
if [ ! -z "$job_duration" ]; then
echo "$v_job.job_duration=$job_duration" >> /tmp/$DB.conf
fi
if [ ! -z "$vFILEPERSET" ]; then
echo "$vFILEPERSET" >> /tmp/$DB.conf
fi
if [ ! -z "$plus_arch" ]; then
echo "$plus_arch" >> /tmp/$DB.conf
fi
echo "$v_job.rman_compressed=Y">>/tmp/$DB.conf


echo "cat <<JB>>$ODS_HOME/config/$DB.conf"
cat /tmp/$DB.conf
rm -f /tmp/$DB.conf


echo "JB"
echo -e "\n"



#
## Fim
#



