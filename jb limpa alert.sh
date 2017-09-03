
find $ORACLE_BASE/ -name alert_*.log | while read ALERT
do

SIZE=$(du -m $ALERT | awk '{print $1 }' )
BKP=$ALERT\_$(date +"%d%m%Y").bkp
if [ "$SIZE" -gt "100" ]; then
  LASTSIZE=$(du -m $ALERT)
  cp $ALERT $BKP
  tar -cvzf $BKP.tar.gz $BKP 1>>/dev/null 2>>/dev/null
  rm -f $BKP
  echo '' > $ALERT
  if [ "$?" -eq "0" ]; then
     echo -e "\nTamanho do alert.log antigo." 
     echo "$LASTSIZE"
     echo -e "\nBackup do alert.log." 
     du -h $BKP.tar.gz
     echo -e "\nTamanho do alert.log atual." 
     du -h $ALERT
  fi
fi

done




cat <<EOF> /tmp/teste.sh

find \$ORACLE_BASE/ -name alert_*.log | while read ALERT
do

SIZE=\$(du -m \$ALERT | awk '{print \$1 }' )
BKP=\$ALERT\_\$(date +"%d%m%Y").bkp
if [ "\$SIZE" -gt "100" ]; then
  LASTSIZE=\$(du -m \$ALERT)
  cp \$ALERT \$BKP
  tar -cvzf \$BKP.tar.gz \$BKP 1>>/dev/null 2>>/dev/null
  rm -f \$BKP
  echo '' > \$ALERT
  if [ "\$?" -eq "0" ]; then
     echo -e "\nTamanho do alert.log antigo." 
     echo "\$LASTSIZE"
     echo -e "\nBackup do alert.log." 
     du -h \$BKP.tar.gz
     echo -e "\nTamanho do alert.log atual." 
     du -h \$ALERT
  fi
fi

done

EOF

