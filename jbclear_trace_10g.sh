#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Realiza a limpeza dos traces, alertas e audit files para Oracle 10G
#-- Nome do arquivo     : ClearLogs10g.sh
#-- Data de criação     : 07/01/2016
#-- Data de atualização : 10/01/2016
#-- -----------------------------------------------------------------------------------

cat <<EOF>/tmp/ClearLogs10g.sh
#!/bin/bash

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi

cat <<JHB
Antes da limpeza:
JHB
case \$(uname) in
"AIX") df -g;;
"Linux") df -hPT | column -t;;
*) dbf;;
esac

if [ ! -z "\$1" ] && [ "\$1" > "0" ]; then
export HOR=\$1
export VTMP=\$(echo \$HOR*60 | bc)

if [ ! -z "\$ORACLE_BASE" ]; then

ps -ef | grep smon | grep -v opuser | grep -v -i "osysmond.bin\|grep" | sed 's/.*mon_\(.*\)\$/\1/'| while read instance
do
VSID=\$(echo \$instance | sed "s/\$(echo \$instance | rev | cut -c 1)//")
DIR1=\$ORACLE_BASE/admin/\$instance/
DIR2=\$ORACLE_BASE/admin/\$VSID/

if [ -e "\$DIR1" ]; then
find \$DIR1/cdump/ -name "*.trm" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR1/cdump/ -name "*.trc" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR1/bdump/ -name "*.trm" -type f -mmin +\$V TMP -exec rm -f {} \; 2>/dev/null
find \$DIR1/bdump/ -name "*.trc" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR1/udump/ -name "*.trc" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR1/adump/ -name "*.aud" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
fi

if [ -e "\$DIR2" ]; then
find \$DIR2/cdump/ -name "*.trm" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR2/cdump/ -name "*.trc" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR2/bdump/ -name "*.trm" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR2/bdump/ -name "*.trc" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR2/udump/ -name "*.trc" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
find \$DIR2/adump/ -name "*.aud" -type f -mmin +\$VTMP -exec rm -f {} \; 2>/dev/null
fi

done

fi
else
echo -e "\n\nDigite \$0 HORAS ou sh \$0 HORAS \n\n"
fi


echo -e "\n"

cat <<JHB

Depois da limpeza:
JHB
case \$(uname) in
"AIX") df -g;;
"Linux") df -hPT | column -t;;
*) dbf;;
esac


EOF

chmod +x /tmp/ClearLogs10g.sh

