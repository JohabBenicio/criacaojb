rm -f /tmp/jbcopy_bkp.sh

vi /tmp/jbcopy_bkp.sh
i

clear

cat /etc/hosts
echo -e "\n"

read -p "Informe o IP do standby: " IPSTAND

echo -e "\n"
ps -ef | grep smon | grep -iv "grep\|+asm" | sed 's/.*mon_\(.*\)$/\1/' 
echo -e "\n"

read -p "Informe o nome da instancia: " ORACLE_SID
echo -e "\n"

find $ORACLE_BASE/admin/$ORACLE_SID/ -name bkp_full.rcv | while read arq; do cat $arq | grep -i "full_"; done
echo -e "\n"

read -p "Informe o diretorio onde se encontra o backup (PRODUCAO): " DIRBKP

read -p "Informe o diretorio onde vai ser armazenado no STANDBY: " DIRBKPSTAND

read -p "Backup full ou arch ? " PECASCOPY

cat <<EOF>/tmp/jbcopy.sh
find $DIRBKP/ -name "$PECASCOPY*" -mtime 0 | while read bkp
do 
echo -n "Copiando peca \$bkp para $IPSTAND:$DIRBKPSTAND ... " >> /tmp/copy_bkp.log
scp \$bkp $IPSTAND:$DIRBKPSTAND
if [ "\$?" -eq "0" ]; then 
echo "OK"   >> /tmp/copy_bkp.log
else
echo "ERRO"   >> /tmp/copy_bkp.log
fi
done
echo -e "\n\nBackup copiado com sucesso!\n\n" >> /tmp/copy_bkp.log
EOF

rm -f /tmp/copy_bkp.log
nohup 1>>/dev/null  2>>/dev/null sh /tmp/jbcopy.sh & 
sleep 3

clear

tail -200f /tmp/copy_bkp.log


:wq!



