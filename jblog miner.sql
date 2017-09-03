

set lines 200 long 200 pages 100
col name for a80
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
break on report
compute sum of MB on report

select
    to_char(completion_time,'DD/MM/YYYY HH24:MI:SS') DATA,
    THREAD#,
    SEQUENCE#,
    (blocks*block_size)/1048576 MB,
    name
from
    v$archived_log
where
    (to_char(completion_time,'DD/MM/YYYY')='04/05/2016' or to_char(completion_time,'DD/MM/YYYY')='03/05/2016')
--    and THREAD#=3
order by 1;





run {
  allocate channel c1 device type sbt_tape parms 'SBT_LIBRARY=/usr/local/simpana/Base/libobk.so,BLKSIZE=262144,ENV=(CV_mmsApiVsn=2,CvClientName=sdm103,CvInstanceName=Instance001,CVOraRacDBName=P1B3,CvMediaAgent=sdmms)';
  restore archivelog from sequence 372 until sequence 376 thread 1;
}



run {
  allocate channel c1 device type sbt_tape parms 'SBT_LIBRARY=/usr/local/simpana/Base/libobk.so,BLKSIZE=262144,ENV=(CV_mmsApiVsn=2,CvClientName=sdm103,CvInstanceName=Instance001,CVOraRacDBName=P1B3,CvMediaAgent=sdmms)';
  restore archivelog from sequence 432 until sequence 436 thread 2;
}


run {
  allocate channel c1 device type sbt_tape parms 'SBT_LIBRARY=/usr/local/simpana/Base/libobk.so,BLKSIZE=262144,ENV=(CV_mmsApiVsn=2,CvClientName=sdm103,CvInstanceName=Instance001,CVOraRacDBName=P1B3,CvMediaAgent=sdmms)';
  restore archivelog from sequence 371 until sequence 375 thread 3;
}



set lines 200 long 200 pages 10000
col name for a80
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
break on report
compute sum of MB on report

select 'define arch='||chr(39)||name||chr(39)||';' from v$archived_log
where name is not null
    and to_char(completion_time,'DD/MM/YYYY')='04/05/2016';





cat <<EOF>define_file_jb
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_2_seq_437.2985.910937407';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_1_seq_377.4232.910937407';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_3_seq_376.1432.910937407';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_1_seq_372.3296.910952083';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_1_seq_373.3439.910952095';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_1_seq_374.4139.910952103';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_1_seq_375.3955.910952111';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_1_seq_376.3956.910952125';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_2_seq_432.3832.910952221';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_2_seq_433.4176.910952233';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_2_seq_434.4200.910952239';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_2_seq_435.3947.910952247';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_2_seq_436.4184.910952261';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_3_seq_371.4340.910952377';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_3_seq_372.4034.910952389';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_3_seq_373.4277.910952403';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_3_seq_374.4259.910952419';
define arch='+RECO_SDM1/p1b3/archivelog/2016_05_04/thread_3_seq_375.3688.910952433';
EOF


cat define_file_jb | while read archive
do

sqlplus -S / as sysdba <<EOF
set echo on
set lines 300 pages 50000 long 99999999
pro $archive
$archive

pro
pro habilit logminer
BEGIN
DBMS_LOGMNR.ADD_LOGFILE(LOGFILENAME => '&&arch', OPTIONS => DBMS_LOGMNR.NEW);
DBMS_LOGMNR.START_LOGMNR(OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.COMMITTED_DATA_ONLY);
END;
/


pro
pro query

set serveroutput on
begin
for x in (SELECT *
FROM V\$LOGMNR_CONTENTS
WHERE upper(SQL_REDO) like '%REVOKE%' order by TIMESTAMP) LOOP
dbms_output.put_line(chr(10)||chr(10)||chr(10));
dbms_output.put_line(rpad('=+',50,'=+'));
dbms_output.put_line('SCN: '||x.SCN);
dbms_output.put_line('TIMESTAMP: '||x.TIMESTAMP);
dbms_output.put_line('SEG_OWNER: '||x.SEG_OWNER);
dbms_output.put_line('SEG_NAME: '||x.SEG_NAME);
dbms_output.put_line('TABLE_NAME: '||x.TABLE_NAME);
dbms_output.put_line('SEG_TYPE_NAME: '||x.SEG_TYPE_NAME);
dbms_output.put_line('USERNAME: '||x.USERNAME);
dbms_output.put_line('SESSION_INFO: '||x.SESSION_INFO);
dbms_output.put_line('OPERATION: '||x.OPERATION);
dbms_output.put_line('SQL_REDO: '||chr(10)||x.SQL_REDO);
END LOOP;

end;
/

pro
pro sair logminer
BEGIN
DBMS_LOGMNR.END_LOGMNR();
END;
/

pro
pro fim
pro ######################################################################################################
pro
quit
EOF

done


