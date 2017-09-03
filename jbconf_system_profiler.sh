
##########################################################


cat <<EOF

LOCAL

cd /Users/johabbeniciodeoliveira/OneDrive/TEOR/VPN\ TEOR/Softwares/SystemProfiler


TEOR

qFvBcKZOEg_9L8Gf8MBA


sysprof_config_template_linux.tar

openssl098e-0.9.8e-17.el6_2.2.x86_64.rpm

Optimode_System_Profiler-2-0.4.0.i386.rpm
Optimode_System_Profiler-2-0.5.0.aix7.1.ppc.rpm
Optimode_System_Profiler-2-0.5.0.x86_64.rpm

EOF



DIR=/home/teor/johab/systemprofiler/Linux/x64
scp teor@186.202.16.246:$DIR/* .

################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################

                                                   INICIO DA INSTALACAO

################################################################################################################################################
################################################################################################################################################
################################################################################################################################################
################################################################################################################################################


# Se for Linux da versao 6, entao instale o pacote "openssl098e-0.9.8e-17.el6_2.2.x86_64.rpm"


cd /tmp
VER_RHEL=$(cat /etc/redhat-release | grep "release 6" | wc -l )
if [ $VER_RHEL -ge 1 ]; then

cat <<EOF
Versao Linux: 6
$(cat /etc/redhat-release )

Instale o pacote abaixo.

rpm -ivh openssl098e-0.9.8e-17.el6_2.2.x86_64.rpm

EOF

fi



ls -lthr /tmp/Optimode_System_Profiler-*

rpm -ivh Optimode_System_Profiler-2-0.5.0.x86_64.rpm




########################################################################

cp sysprof_config_template_linux.tar /opt/optimode

cd /opt/optimode

tar -xvf sysprof_config_template_linux.tar

cat bash_template >> .bash_profile

mv init_template sprof/admin/init.par

chown optimode:optimode sprof/admin/init.par

chown optimode:optimode .bash_profile

rm -f bash_template sysprof_config_template_linux.tar

usermod -G optimode,oinstall optimode

echo -e "kmod77ou90\nkmod77ou90" | passwd optimode


########################################################################


if [ -e "/opt/optimode/sprof/admin/init.par" ]; then
    sed -i '/PARAMETER_FILE=/d' /etc/sysconfig/sprof
    echo "PARAMETER_FILE=/opt/optimode/sprof/admin/init.par">>/etc/sysconfig/sprof
fi

cat /etc/sysconfig/sprof



chkconfig --level 345 sprof on

cd /u01
mkdir optimode
chown optimode:optimode optimode


########################################################################


su - oracle


ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | while read VINST
do
cat <<EOF
export ORAENV_ASK=NO ; ORACLE_SID=$VINST ; . oraenv; export ORAENV_ASK=YES
EOF
done


select username,account_status from dba_users where username='SPROF';


@/opt/optimode/sprof/admin/catuser.sql

SPROF
kmod77ou90


@/var/opt/optimode/sprof/admin/catuser.sql


export HOR=168
export VTMP=$(echo $HOR*60 | bc)
adrci exec="show home" | grep -v "Homes:" | while read homes
do
adrci exec="set home $homes; purge -age $VTMP -type alert"
adrci exec="set home $homes; purge -age $VTMP -type trace"
done




########################################################################



su - optimode
kmod77ou90


###############################################################################################################
###############################################################################################################


NAMEPACE=$(cat /opt/optimode/sprof/admin/init.par | grep "namespace" | cut -d "=" -f 2)
echo $NAMEPACE

gen_local_xml $NAMEPACE

###############################################################################################################
###############################################################################################################


SaoMartinho

Usina Sao Martinho






rm -f /tmp/ConfigSystemProf.sh
vi /tmp/ConfigSystemProf.sh
i

#!/sbin/bash
clear
cat /etc/hosts
read -p "Informe o IP do servidor $(hostname): " VIP
clear

cat <<EOF
INSTANCIAS
$(ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' )

EOF
read -p "É um ambiente RAC? Sim [ 1 ] " VRAC


echo "cat <<EOF>/opt/optimode/sprof/admin/tnsnames.ora">/tmp/tnsnames_systemprofiler

ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | while read VINST
do

if [ -z "$VRAC" ]; then
VRAC=0
fi

#if [ "$VRAC" -eq "1" ]; then
#INST1=$(echo $VINST | rev )
#if [ "${INST1:0:1}" -eq "1" ] || [ "${INST1:0:1}" -eq "2" ] || [ "${INST1:0:1}" -eq "3" ]; then
#VDB=$(echo ${INST1:1:20} | rev)
#fi
#else
#VDB=$VINST
#fi

VDB=$VINST

echo -e "\n"
cat <<JHB>>/tmp/tnsnames_systemprofiler

$(echo $VINST | tr [a-z] [A-Z]) =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $VIP)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = $VDB)
    )
  )

$(echo $VINST | tr [a-z] [A-Z]) =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = IPC)(KEY = LISTENER))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = $VDB)
    )
  )



JHB
done

echo "EOF">>/tmp/tnsnames_systemprofiler

clear
COUNT=1

cat <<JHB>/tmp/InitSystempropfiler

vi /opt/optimode/sprof/admin/init.par

JHB

read -p "Informe o inicio do apelido das instancias: " INICIO_ALIAS

ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | while read VINST
do

if [ "$VRAC" -eq "1" ]; then
INST1=$(echo $VINST | rev )
if [ "${INST1:0:1}" -eq "1" ] || [ "${INST1:0:1}" -eq "2" ] || [ "${INST1:0:1}" -eq "3" ]; then
VDB=$(echo ${INST1:1:20} | rev)
fi
else
VDB=$VINST
fi

cat <<JHB>>/tmp/InitSystempropfiler
instance_user_$COUNT =sprof
instance_alias_$COUNT =$(echo $VINST | tr [a-z] [A-Z])
instance_password_$COUNT =kmod77ou90
sql_set_$COUNT =$INICIO_ALIAS$VDB

JHB
COUNT=$(($COUNT+1))

done



clear
read -p "Informe o nome do parametro \"client_alias\": " client_alias
read -p "Informe o nome do parametro \"client_full_name\": " client_full_name

cat <<EOF>>/tmp/InitSystempropfiler

log_dest=/opt/optimode/sprof/log
thread_control_file=/opt/optimode/sprof/admin/control.ctl
client_alias=$client_alias
client_full_name=$client_full_name
namespace=$(hostname | cut -d "." -f 1)
snapshot_dest=/u01/optimode


################################################################################

Crie o arquivo de controle do System Profiler
sprof -i -p /opt/optimode/sprof/admin/init.par

Iniciar o System profiler
sprof -s -p /opt/optimode/sprof/admin/init.par

Realizar Teste de Email
sprof -m -p /opt/optimode/sprof/admin/init.par


gen_local_xml $(hostname | cut -d "." -f 1)



################################################################################
#    TESTE
################################################################################


cd \$HOME
rm -rf teste
mkdir teste
run_target_healthcheck teste \$HOME/teste current 1 full


tail –200f \$OPTI_HOME/sprof/log/messages*

sprof -c -p \$OPTI_HOME/sprof/admin/init.par

tail -200f \$OPTI_HOME/sprof/log/messages*


################################################################################


Parar System profiler
sprof -u -p /opt/optimode/sprof/admin/init.par




EOF


clear
cat <<EOF

confira o TNS: /tmp/tnsnames_systemprofiler
Caso esteja OK, entao execute abaixo

bash /tmp/tnsnames_systemprofiler

Confira os dados do arquivo do INIT.

cat /tmp/InitSystempropfiler


################################################################################
# Interacao

AÇÕES EXECUTADAS (resumo)
========================
1) - Instalação do system profiler executado com sucesso.

Obs.: Iremos aguardar as coletas dos dados para darmos continuidade no atendimento do chamado.


Att,
Johab Benicio.
DBA Oracle.

EOF



