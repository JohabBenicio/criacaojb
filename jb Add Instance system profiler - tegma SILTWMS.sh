

[oracle@hq-tgl-or-03 [] ~]$ srvctl status database -d SILTWMS
A instância SILTWMS1 está em execução no nó hq-tgl-or-03
A instância SILTWMS2 está em execução no nó hq-tgl-or-04



su - optimode
kmod77ou90


mandar os arquivos para o system profiler
sprof -c -p init.par


set lines 200
select distinct  username,osuser,machine from gv$session




ls -l /opt/optimode/sprof/admin/catuser.sql


su - optimode

/opt/optimode/sprof/admin/catuser.sql
sprof
kmod77ou90


vi /opt/optimode/sprof/admin/tnsnames.ora


SILTWMS1 =
  (DESCRIPTION =
    (ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = SILTWMS1)
    )
  )


Parar System propfiler

 sprof -u -p /opt/optimode/sprof/admin/init.par

vi /opt/optimode/sprof/admin/init.par


instance_user_10 = sprof
instance_alias_10 = SILTWMS1
instance_password_10 = kmod77ou90
sql_set_10 = SILTWMS





sprof -s -p /opt/optimode/sprof/admin/init.par

cd /opt/optimode/sprof/admin

NAMEPACE=$(cat /opt/optimode/sprof/admin/init.par | grep "namespace" | cut -d "=" -f 2)
echo $NAMEPACE

gen_local_xml $NAMEPACE



cd
tail -200f sprof/log/messages_*.log







cd $HOME
rm -rf teste
mkdir teste
run_target_healthcheck teste $HOME/teste current 1 full



$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$





oracle -> Or@Or4Le20#14
root -> T3G$L04$20#14@

ssh root@10.1.2.149



vi /opt/optimode/sprof/admin/tnsnames.ora


SILTWMS2 =
  (DESCRIPTION =
    (ADDRESS=(PROTOCOL=ipc)(KEY=LISTENER))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = SILTWMS2)
    )
  )


Parar System propfiler

 sprof -u -p /opt/optimode/sprof/admin/init.par

vi /opt/optimode/sprof/admin/init.par


instance_user_10 = sprof
instance_alias_10 = SILTWMS2
instance_password_10 = kmod77ou90
sql_set_10 = SILTWMS





sprof -s -p /opt/optimode/sprof/admin/init.par

cd /opt/optimode/sprof/admin

NAMEPACE=$(cat /opt/optimode/sprof/admin/init.par | grep "namespace" | cut -d "=" -f 2)
echo $NAMEPACE

gen_local_xml $NAMEPACE






cd $HOME
rm -rf teste
mkdir teste
run_target_healthcheck teste $HOME/teste current 1 full









##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################
##############################################################################################################################







vi /opt/optimode/sprof/admin/tnsnames.ora


KCOR2 =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 10.12.32.239)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SID = kcor2)
  )
)

BRASIL1 =
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 10.12.32.239)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SID = brasil2)
  )
)



Parar System propfiler

 sprof -u -p /opt/optimode/sprof/admin/init.par

vi /opt/optimode/sprof/admin/init.par


instance_user_4 =sprof
instance_alias_4 =KCOR2
instance_password_4 =kmod77ou90
sql_set_4 =autovias_kcor

instance_user_5 =sprof
instance_alias_5 =BRASIL2
instance_password_5 =kmod77ou90
sql_set_5 =autovias_brasil_rac




sprof -s -p /opt/optimode/sprof/admin/init.par

cd /opt/optimode/sprof/admin
gen_local_xml rac02










tar -cvzf system_ptofiler.tar.gz Optimode_System_Profiler-2-0.4.0.x86_64.rpm sysprof_config_template_linux.tar openssl098e-0.9.8e-17.el6_2.2.x86_64.rpm ftp-0.17-54.el6.x86_64.rpm



tar -vzxf system_ptofiler.tar.gz


##########################################################

rpm -ivh Optimode_System_Profiler-2-0.4.0.x86_64.rpm


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




vi /etc/sysconfig/sprof

PARAMETER_FILE=/opt/optimode/sprof/admin/init.par

chkconfig --level 345 sprof on

cd /u01
mkdir optimode
chown optimode:optimode optimode


su - oracle

/opt/optimode/sprof/admin/catuser.sql

SPROF
kmod77ou90



su - optimode
kmod77ou90











vi /opt/optimode/sprof/admin/init.par

instance_user_1 =sprof
instance_alias_1 =SGOIJMS
instance_password_1 =kmod77ou90
sql_set_1 =araras_prodadm2




client_alias=Unimed_Araras
client_full_name=Unimed de Araras Coop.de Trabalho Médico
namespace=$(hostname | cut -d "." -f 1)
snapshot_dest=/u01/optimode





Crie o arquivo de controle do System Profiler

sprof -i -p /opt/optimode/sprof/admin/init.par



Iniciar o System profiler
sprof -s -p /opt/optimode/sprof/admin/init.par


Realizar Teste de Email
sprof -m -p /opt/optimode/sprof/admin/init.par



NAMEPACE=$(cat /opt/optimode/sprof/admin/init.par | grep "namespace" | cut -d "=" -f 2)
echo $NAMEPACE

gen_local_xml $NAMEPACE




cat $OPTI_HOME/sprof/admin/init.par


cd $HOME
rm -rf teste
mkdir teste
run_target_healthcheck teste $HOME/teste current 1 full


tail –200f $OPTI_HOME/sprof/log/messages*

sprof -c -p $OPTI_HOME/sprof/admin/init.par




tail -200f $OPTI_HOME/sprof/log/messages*





Parar System profiler
sprof -u -p /opt/optimode/sprof/admin/init.par




ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | while read VINST
do
INST1=$(echo $VINST | rev )
VDB=$(echo ${INST1:1:20} | rev)
echo -e "\n"
cat <<JHB
sqlplus sprof/kmod77ou90@'(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = $VIP)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = $VDB) ) )'
JHB
echo -e "\n"

done



 sqlplus sprof/kmod77ou90@'(DESCRIPTION = (ADDRESS = (PROTOCOL = TCP)(HOST = 192.168.50.31)(PORT = 1521)) (CONNECT_DATA = (SERVER = DEDICATED) (SERVICE_NAME = prodadm) ) )'








rm -f /tmp/AddInstSystemProf.sh
vi /tmp/AddInstSystemProf.sh
i

#!/sbin/bash
clear
cat /etc/hosts
read -p "Informe o IP do servidor $(hostname): " VIP
read -p "É um ambiente RAC? Sim [ 1 ] " VRAC



function f_instance (){
clear
echo -e "Instancias presentes no Servidor\n"
COUNT=0;
unset BANCO;
unset DATABASE;
unset INST1; unset INST2; unset INST3; unset INST4; unset INST5; unset INST6;
unset INST7; unset INST8; unset INST9; unset INST10; unset INST11; unset INST12;

while read instance
do
COUNT=$(echo $COUNT+1 | bc);
export INST$COUNT=$instance
echo "$COUNT: $instance"
done < <(ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | sort )

echo " "
read -p "Informe o nome da instancia do banco de dados: " NUM_DB

case $NUM_DB in
    1) BANCO=$INST1;;
    2) BANCO=$INST2 ;;
    3) BANCO=$INST3 ;;
    4) BANCO=$INST4 ;;
    5) BANCO=$INST5 ;;
    6) BANCO=$INST6 ;;
    7) BANCO=$INST7 ;;
    8) BANCO=$INST8 ;;
    9) BANCO=$INST9 ;;
    10) BANCO=$INST10;;
    11) BANCO=$INST11;;
    12) BANCO=$INST12;
esac

if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
echo " "
read -p "Escreva o nome da instancia do banco de dados: " BANCO
fi

if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep pmon | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
f_instance
else
DATABASE=$BANCO
fi
}

f_instance



echo "cat <<EOF>/opt/optimode/sprof/admin/tnsnames.ora">/tmp/tnsnames_systemprofiler

cat <<JHB>>/tmp/tnsnames_systemprofiler

$(echo $DATABASE | tr [a-z] [A-Z]) =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $VIP)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = $VDB)
    )
  )

JHB
echo "EOF">>/tmp/tnsnames_systemprofiler


COUNT=1
read -p "Informe o inicio do apelido das instancias: " INICIO_ALIAS

ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/' | while read VINST
do

if [ -z "$VRAC" ]; then
VRAC=0
fi

if [ "$VRAC" -eq "1" ]; then
INST1=$(echo $VINST | rev )
if [ "${INST1:0:1}" -eq "1" ] || [ "${INST1:0:1}" -eq "2" ] || [ "${INST1:0:1}" -eq "3" ]; then
VDB=$(echo ${INST1:1:20} | rev)
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
client_full_name="$client_full_name"
namespace=$(hostname | cut -d "." -f 1)
snapshot_dest=/u01/optimode

EOF



cat <<EOF

confira o TNS: /tmp/tnsnames_systemprofiler
Caso esteja OK, entao execute abaixo

bash /tmp/tnsnames_systemprofiler

Confira os dados do arquivo do INIT.

cat /tmp/InitSystempropfiler

EOF






















