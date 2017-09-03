

rm -f /tmp/ConfigSystemProf.sh
vi /tmp/ConfigSystemProf.sh
i

#!/sbin/bash
clear
cat <<EOF
Ajuda para escolher o IP.
$(grep -i HOST $TNS_ADMIN/tnsnames.ora | sort | uniq)

EOF
read -p "Informe o IP do servidor $(hostname): " VIP
clear


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

cat <<EOF

Instancias ja configuradas:
$(grep instance_alias_ $TNS_ADMIN/init.par)


EOF


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
read -p "É um ambiente RAC? Sim [ 1 ] " VRAC

cat <<EOF

Ajuda para escolher o apelido da instancia.

$(grep sql_set_ $TNS_ADMIN/init.par)


EOF

read -p "Informe o inicio do apelido das instancias: " INICIO_ALIAS


if [ -z "$BANCO" ]; then
VALID=0
else
VALID=$(ps -ef | grep ora_smon | sed 's/.*smon_\(.*\)$/\1/' | grep -E "(^| )$BANCO( |$)" | wc -l)
fi

if [ "$VALID" -eq "0" ]; then
f_instance
else
VINST=$BANCO
fi

}

f_instance



cat <<EOF>/tmp/tnsnames_systemprofiler

cat <<EOF>>$TNS_ADMIN/tnsnames.ora

EOF


if [ -z $VRAC ]; then
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

cat <<JHB>>/tmp/tnsnames_systemprofiler

$(echo $VINST | tr [a-z] [A-Z]) =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = $VIP)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = $VINST)
    )
  )

$(echo $VINST | tr [a-z] [A-Z]) =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = IPC)(KEY = LISTENER))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SID = $VINST)
    )
  )

EOF

JHB


clear


cat <<JHB>/tmp/InitSystempropfiler

vi $TNS_ADMIN/init.par

JHB


 if [ "$VRAC" -eq "1" ]; then
INST1=$(echo $VINST | rev )
if [ "${INST1:0:1}" -eq "1" ] || [ "${INST1:0:1}" -eq "2" ] || [ "${INST1:0:1}" -eq "3" ]; then
VDB=$(echo ${INST1:1:20} | rev)
fi
else
VDB=$VINST
fi


for ((i=1; i<11; i++)); do
  VALID=$(grep instance_alias_$i $TNS_ADMIN/init.par | wc -l)
  if [ $VALID -eq 0 ]; then

cat <<JHB>>/tmp/InitSystempropfiler
instance_user_$i =sprof
instance_alias_$i =$(echo $VINST | tr [a-z] [A-Z])
instance_password_$i =kmod77ou90
sql_set_$i =$INICIO_ALIAS$VDB

JHB

    break
  fi
done





cat <<EOF>>/tmp/InitSystempropfiler


################################################################################


Parar System profiler
sprof -u -p $TNS_ADMIN/init.par

Iniciar o System profiler
sprof -s -p $TNS_ADMIN/init.par

gen_local_xml $(grep namespace $TNS_ADMIN/init.par | cut -d "=" -f 2)



grep "orainstance" $TNS_ADMIN/local.xml
grep "oradb" $TNS_ADMIN/local.xml


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






EOF


clear
cat <<EOF

Execute o script no banco de dados:

$TNS_ADMIN/catuser.sql

SPROF
kmod77ou90


confira o TNS: /tmp/tnsnames_systemprofiler
Caso esteja OK, entao execute abaixo

cat /tmp/tnsnames_systemprofiler

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



