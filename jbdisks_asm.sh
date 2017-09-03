#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Lista discos que estão sendo usados pelo ASM
#-- Nome do arquivo     : jbdisks_asm.sh
#-- Data de criação     : 01/12/2014
#-- Data de atualização : 23/01/2015
#-- -----------------------------------------------------------------------------------




for NUMBER in {1..15}
do
if [ $NUMBER -lt 10 ]; then
     oracleasm querydisk -p ASM0$NUMBER | grep "mapper"
else
    oracleasm querydisk -p ASM$NUMBER | grep "mapper"
fi;
done




if [ "$USER" != "root" ]; then
	clear
	echo -e "\n\nExecute o script com usuario ROOT.\n\n"
else

if [ -e /tmp/queryduskASM.log ]; then
	rm -f /tmp/queryduskASM.log
fi

fdisk -l | grep -i "/dev/" | grep -v "Disk" | awk '{print "oracleasm querydisk "$1 }' | while read queryduskASM
do
$queryduskASM 2>>/dev/null >> /tmp/queryduskASM.log
done
clear
VALID=$(cat /tmp/queryduskASM.log | wc -l)

if [ "$VALID" -eq "0" ]; then
	echo -e "\n\nNenhum disco encontrado para o ASM\nexecute: oracleasm listdisks\n\n"
else
cat /tmp/queryduskASM.log
fi

echo -e '\noracleasm querydisk -d\n'

oracleasm listdisks | xargs oracleasm querydisk -d

echo -e '\n /dev/disk/by-path - NOME DA LUN\n'

cat /tmp/queryduskASM.log |  cut -c13-17 | while read VDISK
do
	ls -lthr /dev/disk/by-path | grep $VDISK
done

echo -e '\n/dev/disk/by-id - WWID\n'

cat /tmp/queryduskASM.log |  cut -c13-17 | while read VDISK
do
	ls -lthr /dev/disk/by-id | grep $VDISK
done

echo -e '\n'

#rm -f /tmp/queryduskASM.log

fi
