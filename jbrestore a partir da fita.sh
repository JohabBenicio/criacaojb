

select name, dbid, to_char(RESETLOGS_TIME,'dd/mm/yyyy hh24:mi') from rc_database where name='WMSVIXPD';

NAME           DBID TO_CHAR(RESETLOG
-------- ---------- ----------------
WMSVIXPD 1384313968 05/03/2010 23:45
WMSVIXPD 3245724187 17/12/2016 12:22







connected to target database: WMSVIXPD (DBID=3245724187)









export NLS_DATE_FORMAT='DD/MM/YYYY'



rman target / catalog rman/rman#2014@rman



run {
   SET DBID 3245724187;
   set until time "to_date('05/01/2017','DD/MM/YYYY')";
   allocate channel c1 type sbt_tape parms 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.so64';
   send 'NB_ORA_POLICY=NICOLA_PRD_HQ-TGL-OR2-SCAN_ORA_WMSVIXPD1, NB_ORA_SERV=hq-tgl-netbk-01, NB_ORA_CLIENT=hq-tgl-or-03';
   restore controlfile from autobackup;
   alter database mount;
}






cat <<EOF>/tmp/restore.rcv
run {
   set until time "to_date('05/01/2017','DD/MM/YYYY')";
   set newname for database to '/data_log/oradata/wmsvixpd/%U';
   allocate channel c1 type sbt_tape parms 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.so64';
   send 'NB_ORA_POLICY=NICOLA_PRD_HQ-TGL-OR2-SCAN_ORA_WMSVIXPD1, NB_ORA_SERV=hq-tgl-netbk-01, NB_ORA_CLIENT=hq-tgl-or-03';
   restore database;
}
exit;
EOF


cat <<EOF>/tmp/recover.rcv
run {
   set until time "to_date('05/01/2017','DD/MM/YYYY')";
   set newname for database to '/data_log/oradata/wmsvixpd/%U';
   allocate channel c1 type sbt_tape parms 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.so64';
   send 'NB_ORA_POLICY=NICOLA_PRD_HQ-TGL-OR2-SCAN_ORA_WMSVIXPD1, NB_ORA_SERV=hq-tgl-netbk-01, NB_ORA_CLIENT=hq-tgl-or-03';
   recover database;
}
exit;
EOF


export NLS_DATE_FORMAT='DD/MM/YYYY'



rman target / catalog rman/rman#2014@rman




nohup rman target / catalog rman/rman#2014@rman cmdfile /tmp/restore.rcv msglog /tmp/restore.log &
sleep 3
tail -200f  /tmp/restore.log




run {
   set until time "to_date('05/01/2017','DD/MM/YYYY')";
   set newname for database to '/data_log/oradata/wmsvixpd/%U';
   allocate channel c1 type sbt_tape parms 'SBT_LIBRARY=/usr/openv/netbackup/bin/libobk.so64';
   send 'NB_ORA_POLICY=NICOLA_PRD_HQ-TGL-OR2-SCAN_ORA_WMSVIXPD1, NB_ORA_SERV=hq-tgl-netbk-01, NB_ORA_CLIENT=hq-tgl-or-03';
   recover database;
}




