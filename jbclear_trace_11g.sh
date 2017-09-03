#-- -----------------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Realiza a limpeza dos traces, alertas e audit files para Oracle 11G
#-- Nome do arquivo     : ClearLogs.sh
#-- Data de criação     : 11/11/2015
#-- Data de atualização : 07/01/2016
#-- -----------------------------------------------------------------------------------------

cat <<EOF>/tmp/ClearLogs11g.sh
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
adrci exec="show home" | grep -v "Homes:" | while read homes
do
adrci exec="set home \$homes; purge -age \$VTMP -type alert"
adrci exec="set home \$homes; purge -age \$VTMP -type trace"
done

if [ ! -z "\$ORACLE_BASE" ]; then

ps -ef | grep smon | grep -v opuser | grep -v -i "/\|+\|-\|grep" | sed 's/.*mon_\(.*\)\$/\1/'| while read instance
do
VSID=\$(echo \$instance | sed "s/\$(echo \$instance | rev | cut -c 1)//")
DIR1=\$ORACLE_BASE/admin/\$instance
DIR2=\$ORACLE_BASE/admin/\$VSID

if [ -d "\$DIR1" ]; then
find \$DIR1/adump/ -name "*.aud" -type f -mmin +\$VTMP -exec rm -fv {} \;
fi
if [ -d "\$DIR2" ]; then
find \$DIR2/adump/ -name "*.aud" -type f -mmin +\$VTMP -exec rm -fv {} \;
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

chmod +x /tmp/ClearLogs11g.sh


cat <<EOF

#
#+------------------------------------------------------------------------------------------------------------------------------------------------+
## Limpeza de Logs                                                                                                                                |
#+------------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour MonthDay  Month  Weekday   Command
# ------ ---- --------- ------ --------- ---------------------------------------------------------------------------------------------------------+
  00     02   *         *      *         $ORACLE_BASE/admin/scripts/ClearLogs11g.sh 168 > $ORACLE_BASE/admin/scripts/log/ClearLogs.log

EOF







vi /tmp/ClearLoglistener.sh
i
#!/bin/bash
date

DIR_LOG1=/u01/app/11.2.0/grid/log/diag/tnslsnr/atv-rac-02
DIR_LOG2=/u01/app/oracle/diag/tnslsnr/atv-rac-02/listener/trace

ls -1 $DIR_LOG1/listener_scan*/trace/listener_scan*.log $DIR_LOG2/listener.log | while read LOG
do

SIZE=$(du -m $LOG | awk '{print $1 }' )

BKP=$LOG\_$(date +"%d%m%Y").bkp
if [ "$SIZE" -gt "2048" ]; then
  mv $LOG $BKP && touch $LOG

  tar -cvzf $BKP.tar.gz $BKP 1>>/tmp/null 2>>/tmp/null

  if [ "$?" -eq "0" ]; then
     echo -e "\nLog do listener antigo."
     du -h $BKP
     rm -f $BKP
     echo " " > $LOG
     echo -e "\nBackup do log."
     du -h $BKP.tar.gz
  fi
fi
echo -e "\nLog do Listener atual."
du -h $LOG

done



find /u01/app/oracle/diag/tnslsnr/atv-rac-01/listener/trace/ -name "listener.log*" -mtime +7 -exec rm -f {} \;








cp /tmp/ClearLoglistener.sh $ORACLE_BASE/admin/scripts
chmod +x $ORACLE_BASE/admin/scripts/ClearLoglistener.sh


cat <<EOF

#
#+------------------------------------------------------------------------------------------------------------------------------------------------+
## Limpeza de Logs                                                                                                                                |
#+------------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour MonthDay  Month  Weekday   Command
# ------ ---- --------- ------ --------- ---------------------------------------------------------------------------------------------------------+
  00     23   *         *      *         $ORACLE_BASE/admin/scripts/ClearLoglistener.sh >> $ORACLE_BASE/admin/scripts/log/ClearLogs.log

EOF




