
#######################################################################################################################################################################
#######################################################################################################################################################################
#######################################################################################################################################################################
oracle =
T3cn0l0gia@0racl3
#######################################################################################################################################################################
#######################################################################################################################################################################
#######################################################################################################################################################################


rm -f /tmp/alert_*
rm -f /tmp/falhas_ASM_*
rm -f /tmp/falhas_*.log
while read instance
do
find $ORACLE_BASE/admin -name "alert_$instance.log" | while read alert
do
instance=$(echo $alert | sed 's/.*alert_//' | sed 's/.log//')
VALID=$(echo $alert | grep "$ORACLE_HOME" | wc -l )
if [ "$VALID" -eq "0" ]; then
tail -80000 $alert >> /tmp/alert_$instance
ls -lthr $alert >>/tmp/falhas_ASM_$instance
grep -B4 -i "IO Failed." /tmp/alert_$instance >>/tmp/falhas_ASM_$instance
fi
done
done < <(ps -ef | grep smon | grep -iv "grep\|+asm\|/" | sed 's/.*mon_\(.*\)$/\1/')




rm -f /tmp/alert_*
rm -f /tmp/falhas_ASM_*
rm -f /tmp/falhas_*.log
while read alert
do
instance=$(echo $alert | sed 's/.*alert_//' | sed 's/.log//')
VALID=$(echo $alert | grep "$ORACLE_HOME" | wc -l )
if [ "$VALID" -eq "0" ]; then
tail -80000 $alert >> /tmp/alert_$instance
ls -lthr $alert >>/tmp/falhas_ASM_$instance
grep -B4 -i "IO Failed." /tmp/alert_$instance >>/tmp/falhas_ASM_$instance
fi

done < <(find $ORACLE_BASE -name "alert_*.log" )




############################################################################################################################################################


rm -f /tmp/falhas_*.log
while read instance
do
cat /tmp/falhas_ASM_$instance | grep -i "IO Failed.\| 2016" | while read RESULT
do
echo "$RESULT" >> /tmp/falhas_$instance.log
done
done < <(ls /tmp/falhas_ASM_* | sed 's/.*falhas_ASM_\(.*\)$/\1/')




VDISK="NONE"
VDATA="NONE"
rm -f /tmp/disks_*
while read LOG
do
SID=${LOG%.log}
LOG_DISK="/tmp/disks_$SID"
while read VAL
do
VALID=$(echo $VAL | grep -i " 2014\| 2015\| 2016\| 2017" | wc -l)

if [ "$VALID" -eq "0" ]; then

VALID=$(echo $VAL | grep "Unknown disk" | wc -l)

if [ "$VALID" -eq "0" ]; then
if [ "$VDISK" != "${VAL#*diskname:}" ]; then
VDISK=${VAL#*diskname:}
if [ ! -z "$VDISK" ]; then
echo "JBASM:$VDISK" >> $LOG_DISK
#echo "$VDISK"
fi
fi
fi
else

if [ "$VDATA" != "${VAL:0:11}" ]; then
VDATA=${VAL:0:11}
echo "$VDATA" >> $LOG_DISK
#echo "$VDATA"
VDISK="NONE"
fi

fi

done < /tmp/falhas_$LOG
done < <(ls /tmp/falhas_*.log | sed 's/.*falhas_\(.*\)$/\1/')





############################################################################################################################################################


slx121sac
123456
T3cn0l0gia@R00t
su - root -c "multipath -ll > /tmp/multipath_list.out; chown oracle:oinstall  /tmp/multipath_list.out"


############################################################################################################################################################



rm -f /tmp/JBFILES*
cat <<EOF>/tmp/resultado_final.log


$(hostname) ($(/sbin/ifconfig eth0 | grep -i "addr:" | head -1 | sed 's/.*addr://1' | sed 's/\ .*//'))
EOF
while read SID
do
while read VAL
do
VALID=$(echo $VAL | grep JBASM | wc -l )

if [ "$VALID" -eq "1" ]; then
DISCO=$(echo $VAL | rev | cut -d ":" -f 1 | rev )

VALIDASM=$(echo $DISCO | grep "/" | wc -l )

if [ "$VALIDASM" -gt "0" ]; then
DISKASM=$(echo $DISCO | rev | cut -d "/" -f 1 | rev )
else
DISKASM=$(echo $VAL | rev | cut -d ":" -f 1 | rev )
fi

VALID_SO=$(/sbin/blkid | grep $DISKASM | grep "mapper" | wc -l)

if [ "$VALID_SO" -gt "0" ]; then
DISKSO=$(/sbin/blkid | grep $DISKASM | grep "mapper" | cut -d ":" -f 1)



DISKMULTP=$(echo $DISKSO | rev | cut -d "/" -f 1 | sed 's/1p//' | rev)
MULT=$(cat /tmp/multipath_list.out | grep $DISKMULTP)
MULT=${MULT#*(}
MULT=${MULT%)*}
VWWID=${MULT% dm-*}

cat <<EOF>>$FILE
$SID    $DISKSO    $VWWID    $DISKASM
EOF
else
DISKSO=$(/sbin/blkid | grep $DISKASM | cut -d ":" -f 1)

cat <<EOF>>$FILE
$SID    $DISKSO    $DISKASM
EOF
fi

else

FILE="/tmp/JBFILES:$(echo $VAL | sed 's/ /:/g'):$SID"

fi
done < /tmp/disks_$SID
done < <(ls /tmp/disks_* | sed 's/.*disks_\(.*\)$/\1/')

while read SID
do
echo -e "\n######################################## $SID ########################################">>/tmp/resultado_final.log

while read FINAL
do

DIA=${FINAL:21:2}
MES=${FINAL:17:3}
ANO=$(date +"%Y")

echo "$DIA $MES $ANO" >> /tmp/resultado_final.log
cat $FINAL | sort | uniq >> /tmp/resultado_final.log

echo -e "\n" >> /tmp/resultado_final.log

done < <(ls -tr /tmp/JBFILES*$SID)
done < <(ls /tmp/JBFILES* | rev | cut -d ":" -f 1 | rev | sort | uniq )

cat /tmp/resultado_final.log







rm -f /tmp/falhas_*.log
rm -f /tmp/disks_*
rm -f /tmp/JBFILES*
rm -f /tmp/alert_*
rm -f /tmp/falhas_ASM_*
rm -f /tmp/falhas_*.log


