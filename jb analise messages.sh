
export DAT="$(date +"%b %d")\|$(date +"%b") $(echo $(date +"%d")-10|bc)"
echo -e "LOG /var/log/messages: /var/log/messages\n" > /tmp/jbmessages_boot.log
cat /var/log/messages | grep -2i "/proc/kmsg started\|power\|eboot" | grep "$DAT" | tail -50 >> /tmp/jbmessages_boot.log
echo -e "\nLOG /var/log/messages: QTD. I/O error" >> /tmp/jbmessages_boot.log
cat /var/log/messages 2>>/tmp/jhberr | grep -i "I/O error" | grep "$DAT" | wc -l >> /tmp/jbmessages_boot.log
echo -e "\nLOG /var/log/messages: QTD. SCSI error" >> /tmp/jbmessages_boot.log
cat /var/log/messages 2>>/tmp/jhberr | grep -i "SCSI error" | grep "$DAT" | wc -l >> /tmp/jbmessages_boot.log
echo -e "\n\n\nCommand LAST" >> /tmp/jbmessages_boot.log
last | grep -2 "eboo" | grep "$DAT" >> /tmp/jbmessages_boot.log
echo -e "\n\n\n$(w)\n\n" >> /tmp/jbmessages_boot.log

rm -f /tmp/jhberr && less /tmp/jbmessages_boot.log


May  2

DAT="May  2\|May  1"





# less /var/log/secure


export DAT="$(date +"%b %d")\|$(date +"%b") $(echo $(date +"%d")-10|bc)"

echo -e "LOG /var/log/messages: /var/log/messages\n" > /tmp/jbmessages_boot.log && cat /var/log/messages | grep -2i "/proc/kmsg started\|power\|eboot" | grep "$DAT" | tail -50 >> /tmp/jbmessages_boot.log

&& echo -e "\nLOG /var/log/messages: QTD. I/O error" >> /tmp/jbmessages_boot.log && cat /var/log/messages 2>>/tmp/jhberr | grep -i "I/O error" | grep "$DAT" | wc -l >> /tmp/jbmessages_boot.log && echo -e "\nLOG /var/log/messages: QTD. SCSI error" >> /tmp/jbmessages_boot.log && cat /var/log/messages 2>>/tmp/jhberr | grep -i "SCSI error" | grep "$DAT" | wc -l >> /tmp/jbmessages_boot.log && echo -e "\n\n\nCommand LAST" >> /tmp/jbmessages_boot.log && last | grep -2 "eboo" | grep "$DAT" >> /tmp/jbmessages_boot.log && echo -e "\n\n\n$(w)\n\n" >> /tmp/jbmessages_boot.log && rm -f /tmp/jhberr && less /tmp/jbmessages_boot.log




DIAS=1
export VMESSAGES=/var/log/messages
export DAT1="$(date +"%d")"
export DAT2="$(echo $DAT1-$DIAS|bc)"

rm -f /tmp/jbmessages_boot.log
for((i=$DAT2;i<=$DAT1;i++)); do

if [ "$i" -gt "9" ]; then
DAT="$(date +"%b $i")"
echo -e "\nLOG /var/log/messages: /var/log/messages ($DAT)\n" >> /tmp/jbmessages_boot.log && cat $VMESSAGES | grep -2i "/proc/kmsg started\|power\|eboot\|SCSI error\|I/O error" | grep "$DAT" | tail -50 >> /tmp/jbmessages_boot.log
else
DAT="$(date +"%b  $i")"
echo -e "\nLOG /var/log/messages: /var/log/messages ($DAT)\n" >> /tmp/jbmessages_boot.log && cat $VMESSAGES | grep -2i "/proc/kmsg started\|power\|eboot\|SCSI error\|I/O error" | grep "$DAT" | tail -50 >> /tmp/jbmessages_boot.log
fi
done


less /tmp/jbmessages_boot.log



SELECT  round(count(*)/24) Media,
        RESPONSE_RESULT
FROM ACM_SOL.ACM_HTTP_REQUESTS
where
DUMP_DATE = to_date(sysdate,'dd/mm/yyyy')
AND REQUEST_TYPE LIKE 'SMS%'
AND RESPONSE_RESULT = '202'
group by RESPONSE_RESULT,REQUEST_TYPE;








Nome:   Paulo Roberto 34 3293-6676 r. 4076
Email:  it@br.sodru.com















