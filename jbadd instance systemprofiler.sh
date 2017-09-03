




rm -f /tmp/AddInstSystemProf.sh
vi /tmp/AddInstSystemProf.sh
i

#!/sbin/bash
clear
cat /etc/hosts
read -p "Informe o IP do servidor $(hostname): " VIP
clear

DIR_SPROF=/opt/optimode/sprof/admin

if [ ! -d $DIR_SPROF ]; then
DIR_SPROF=/var/opt/optimode/sprof/admin
fi

function f_instance (){
clear
echo -e "Instancias presentes no Servidor\n"
COUNT=0;
unset VINST;

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
    $i) VINST=$(eval echo \$INST$NUM_DB)
esac
done

if [ -z "$VINST" ]; then
VALID=0
else
VALID=$(ps -ef | grep ora_smon | sed 's/.*smon_\(.*\)$/\1/' | grep -E "(^| )$VINST( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
echo " "
read -p "Escreva o nome da instancia do banco de dados: " VINST
fi

if [ -z "$VINST" ]; then
VALID=0
else
VALID=$(ps -ef | grep ora_smon | sed 's/.*smon_\(.*\)$/\1/' | grep -E "(^| )$VINST( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
f_instance
fi

}

f_instance


cat <<JHB>/tmp/tnsnames_systemprofiler

cat <<EOF>>$DIR_SPROF/tnsnames.ora

$(echo $VINST | tr [a-z] [A-Z]) =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $VIP)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = $VINST)
    )
  )

EOF

JHB

################################################################################
clear
read -p "A instancia \"$VINST\" faz parte de um ambiente RAC? Sim [ 1 ] " VRAC

if [ $VRAC -eq 1 ]; then
INST1=$(echo $VINST | rev )
  for i in {1..10}
  do
    if [ "${INST1:0:1}" -eq "$i" ]; then
      VDB=$(echo ${INST1:1:20} | rev)
      break
    else
      VDB=$VINST
    fi
  done
else
  VDB=$VINST
fi

clear

cat <<JHB>/tmp/InitSystempropfiler

vi $DIR_SPROF/init.par

JHB

read -p "Informe o inicio do apelido das instancias: " INICIO_ALIAS


for i in {1..10}
do


cat <<JHB>>/tmp/InitSystempropfiler
instance_user_$i =sprof
instance_alias_$i =$(echo $VINST | tr [a-z] [A-Z])
instance_password_$i =kmod77ou90
sql_set_$i =$INICIO_ALIAS$VDB

JHB

done

clear


cat <<EOF>>/tmp/InitSystempropfiler

################################################################################

# Atualizar o arquivo XML.
gen_local_xml $(grep -i "namespace" $DIR_SPROF/init.par | cut -d "=" -f 2)


# Parar System profiler
sprof -u -p $DIR_SPROF/init.par


# Iniciar o System profiler
sprof -s -p $DIR_SPROF/init.par


grep "url=" $DIR_SPROF/local.xml | sort | uniq


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



