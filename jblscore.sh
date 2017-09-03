#-- -----------------------------------------------------------------------------------
#-- Autor           : Johab Benicio de Oliveira.
#-- Descrição       : Analisar quantidade de soquetes, core e CPUs do servidor.
#-- Data de criação : 18/08/2014
#-- -----------------------------------------------------------------------------------

export JBSOQ=$(cat /proc/cpuinfo | grep -i "physical id" | sort | uniq | wc -l)
export JBCORE=$(cat /proc/cpuinfo | grep -i "core id" | sort | uniq | wc -l)
export JBCPU=$(cat /proc/cpuinfo| grep processor | sed 's/.*:\(.*\)$/\1/' | sort | wc -l)

VIP=$(/sbin/ifconfig eth0)
VIP=${VIP#*end.: }

cat <<EOF

Servidor: $(hostname)
IP: ${VIP% Bc*}
IP Hostname: $(hostname -i)
QTD de SOQUETES: $JBSOQ
QTD de CORE: $JBCORE
Processor (CPU's): $JBCPU


EOF


