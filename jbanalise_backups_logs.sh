
## ####################################################################################
## # Retorna ultimas linhas do ultimo log de backup de archives  "ORACLE_SID"
## ####################################################################################

crontab -l | grep "archive*.sh" 2>>/dev/null | grep "$ORACLE_SID" | awk '{ if ($6=="*" || $6=="sh" ) hm = $7; else hm = $6}  {print hm}'  | while read archive
do
BKP_HOME=$(cat $archive 2>>/dev/null | grep "BACKUP_HOME=" | sed 's/.*=//')
LOG=$(ls -ltr $BKP_HOME/log/*arch*.log 2>>/dev/null | tail -1 | awk '{print $NF}')
echo -e "\n"
ls -l $LOG
echo -e "\n"
tail -30 $LOG
echo -e "\n\n"
done



## ####################################################################################
## # Retorna ultimas linhas do ultimo log de backup via RMAN "ORACLE_SID"
## ####################################################################################

crontab -l | grep "bkp_full.sh" 2>>/dev/null | grep -E "(^| )$ORACLE_SID( |$)" | awk '{ if ($6=="*" || $6=="sh" ) hm = $7; else hm = $6}  {print hm}'  | while read fisico
do
BKP_HOME=$(cat $fisico 2>>/dev/null | grep "BACKUP_HOME=" | sed 's/.*=//')
LOG=$(ls -ltr $BKP_HOME/log/*full* 2>>/dev/null | tail -1 | awk '{print $NF}')
echo -e "\n"
ls -l $LOG
echo -e "\n"
tail -30 $LOG
echo -e "\n\n"
done




## ####################################################################################
## # Listar Todos logs de backup via RMAN
## ####################################################################################


crontab -l | grep "bkp_full.sh" 2>>/dev/null | awk '{ if ($6=="*" || $6=="sh" ) hm = $7; else hm = $6}  {print hm}' | while read fisico
do
BKP_HOME=$(cat $fisico 2>>/dev/null | grep "BACKUP_HOME=" | sed 's/.*=//')
LOG=$(ls -ltr $BKP_HOME/log/*full* 2>>/dev/null | tail -1 | awk '{print $NF}')
echo -e "\n"
ls -l $LOG
echo -e "\n"
tail -30 $LOG
echo -e "\n\n"
done




## ####################################################################################
## # Listar Todos logs de backup de archives
## ####################################################################################


crontab -l | grep "bkp_full.sh" 2>>/dev/null | awk '{ if ($6=="*" || $6=="sh" ) hm = $7; else hm = $6}  {print hm}' | while read fisico
do
BKP_HOME=$(cat $fisico 2>>/dev/null | grep "BACKUP_HOME=" | sed 's/.*=//')
LOG=$(ls -ltr $BKP_HOME/log/*arch* 2>>/dev/null | tail -1 | awk '{print $NF}')

echo -e "\n"
ls -l $LOG
echo -e "\n"
tail -15 $LOG
echo -e "\n\n"
done




## ####################################################################################
## # Retorna ultimas linhas do ultimo log de backup logico exp ou expdp "ORACLE_SID"
## ####################################################################################

crontab -l | grep "exp" 2>>/dev/null | grep "$ORACLE_SID" | awk '{ if ($6=="*" || $6=="sh" ) hm = $7; else hm = $6}  {print hm}' | while read logico
do
BKP_HOME=$(cat $logico 2>>/dev/null | grep "DIR=" | sed 's/.*=//' | sed 's/$ORACLE_SID/'$ORACLE_SID'/')
LOG=$(ls -ltr $BKP_HOME/exp*.log 2>>/dev/null | tail -1 | awk '{print $NF}')
echo -e "\n"
ls -l $LOG
echo -e "\n"
tail -30 $LOG
echo -e "\n\n"
done



(echo $SCRPTDIR/log | sed 's/$ORACLE_SID/'$1'/')


## ####################################################################################
## # Listar Todos logs de backup logico
## ####################################################################################

crontab -l | grep "exp" 2>>/dev/null | grep -v "#" | awk '{ if ($6=="*" || $6=="sh" ) hm = $7; else hm = $6}  {print hm}' | while read logico
do
BKP_HOME=$(cat $logico 2>>/dev/null | grep "DIR=" | sed 's/.*=//')
LOG=$(ls -ltr $BKP_HOME/exp*.log 2>>/dev/null | tail -1 | awk '{print $NF}')
echo -e "\n"
ls -l $LOG
echo -e "\n"
tail -15 $LOG
echo -e "\n\n"
done






