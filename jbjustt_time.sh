
cat <<EOF>/tmp/jbjust_time.sh
#/bin/bash
read -p "Informe o DIA: " DD
read -p "Informe o MES (1-12): " MM
read -p "Informe o ANO (YYYY): " YY
read -p "Informe a HORA (HH24): " HH
read -p "Informe o MINUTO: " MI
read -p "Deseja efetuar a execucao do comando? [ ENTER ] " CONFORM


if [ ! -z "\$DD" ] && [ ! -z "\$MM" ] && [ ! -z "\$YY" ] && [ ! -z "\$HH" ] && [ ! -z "\$MI" ]; then
echo -e "\n"

if [ -z \$CONFORM ]; then
date \$MM\$DD\$HH\$MI\$YY
hwclock -w
clock -w
else
cat <<JB

date \$MM\$DD\$HH\$MI\$YY
hwclock -w
clock -w


JB


fi
fi
EOF

bash /tmp/jbjust_time.sh
