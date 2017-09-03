
HOM_HOME=$ORACLE_BASE/admin/$ORACLE_SID/scripts/atualizacao
HOM_HOME=/u01/app/oracle/admin/t11simul/scripts/atualizacao

mkdir -p $HOM_HOME/log
mkdir -p $HOM_HOME/rcv


rm -f $HOM_HOME/AtuBanc.sh

vi $HOM_HOME/AtuBanc.sh
i

#!/bin/bash

source ~/.bash_profile


HOM_SID=teste
PROD_TNS=jhbmst
PROD_PASS=Oracle11g
HOM_HOME=$ORACLE_BASE/admin/$HOM_SID/scripts/atualizacao
HOM_RCV=$HOM_HOME/rcv/duplicate_$HOM_SID.rcv
HOM_LOG=$HOM_HOME/log/duplicate_$HOM_SID.log
HOM_DROP=$HOM_HOME/log/duplicate_shut_$HOM_SID.log


alias SET_ASM="export ORAENV_ASK=NO ; ORACLE_SID=+ASM ; . oraenv; export ORAENV_ASK=YES"
alias SET_SID="export ORAENV_ASK=NO ; ORACLE_SID=$HOM_SID ; . oraenv; export ORAENV_ASK=YES"

SET_SID


if [ ! -e "$HOM_RCV" ]; then
cat <<EOF>$HOM_RCV
duplicate target database to $HOM_SID;
EOF
fi

VALID=$(ps -ef | grep pmon | grep $ORACLE_SID | grep -v grep | wc -l)
if [ "$VALID" -eq "0" ]; then
sqlplus -S / as sysdba <<EOF
startup nomount;
exit
EOF
fi

sqlplus / as sysdba <<EOF>>$HOM_DROP
select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') Horas from dual;

pro shutdown immediate;
pro
shutdown immediate;

pro startup mount restrict;
pro
startup mount restrict;

pro alter system set control_files='+DGDATA' scope=spfile;
alter system set control_files='+DGDATA' scope=spfile;

pro create pfile from spfile;
create pfile from spfile;

pro drop database;
drop database;

pro conn / as sysdba
conn / as sysdba

pro create spfile from pfile;
create spfile from pfile;

pro startup nomount;
startup nomount;


show parameter name;
show parameter control_files;
show parameter spfile;

exit
EOF

SET_ASM

asmcmd -p ls +DGDATA/$HOM_SID/

SET_SID

rman target sys/$PROD_PASS@$PROD_TNS auxiliary / cmdfile $HOM_RCV msglog $HOM_LOG


sqlplus -S / as sysdba <<EOF>>$HOM_DROP
pro shutdown immediate;
shutdown immediate;

pro connect / as sysdba;
connect / as sysdba;

pro startup mount;
startup mount;

pro alter database noarchivelog;
alter database noarchivelog;

pro alter database open;
alter database open;


set feedback off;
set lines 200;
col STATUS for a15
col "OPEN MODE" for a11
col INSTANCIA for a15
col VERSAO for a58
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
        INS.PARALLEL RAC, 
        INS.STATUS, 
        DAT.NAME DATABASE, 
        DAT.OPEN_MODE "OPEN MODE", 
        DAT.LOG_MODE "MODO ARCHIVE", 
        VER.BANNER VERSAO 
FROM V\$INSTANCE INS, V\$DATABASE DAT, V\$VERSION VER 
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';
set feedback on;


exit
EOF





chmod 755 $HOM_HOME/AtuBanc.sh










RUN{
ALLOCATE AUXILIARY CHANNEL NEWDB1 DEVICE TYPE DISK;
SET NEWNAME FOR DATAFILE 1 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 2 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 3 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 4 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 5 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 6 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 7 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 8 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 9 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 10 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 11 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 12 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 13 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 14 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 15 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 16 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 17 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 18 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 19 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 20 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 21 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 22 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 23 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 24 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 25 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 26 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 27 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 28 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 29 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 30 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 31 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 32 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 33 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 34 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 35 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 36 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 37 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 38 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 39 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 40 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 41 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 42 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 43 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 44 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 45 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 46 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 47 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 48 TO '+DGDATA';
SET NEWNAME FOR DATAFILE 49 TO '+DGDATA';
SET NEWNAME FOR TEMPFILE 1 TO '+DGDATA';
SET NEWNAME FOR TEMPFILE 2 TO '+DGDATA';
SET NEWNAME FOR TEMPFILE 3 TO '+DGDATA';
DUPLICATE TARGET DATABASE TO t11simul
LOGFILE
GROUP 1 ('+DGDATA') SIZE 128M REUSE,
GROUP 6 ('+DGDATA') SIZE 128M REUSE,
GROUP 2 ('+DGDATA') SIZE 128M REUSE,
GROUP 4 ('+DGDATA') SIZE 128M REUSE,
GROUP 5 ('+DGDATA') SIZE 128M REUSE,
GROUP 8 ('+DGDATA') SIZE 128M REUSE,
GROUP 3 ('+DGDATA') SIZE 128M REUSE,
GROUP 7 ('+DGDATA') SIZE 128M REUSE;
}





 CREATE CONTROLFILE SET DATABASE "T11SIMUL" RESETLOGS NOARCHIVELOG
  MAXLOGFILES     16
  MAXLOGMEMBERS      3
  MAXDATAFILES      100
  MAXINSTANCES     8
  MAXLOGHISTORY     2920
 LOGFILE
  GROUP  1 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  6 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  2 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  4 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  5 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  8 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  3 ( '+DGDATA' ) SIZE 128 M  REUSE,
  GROUP  7 ( '+DGDATA' ) SIZE 128 M  REUSE
 DATAFILE
'+DGDATA/t11simul/datafile/D7IPROD_DATA.984.891983229',
'+DGDATA/t11simul/datafile/D7IPROD_INDEX.534.891983643',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO.1192.891987995',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO.530.891983643',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO.679.891983643',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO.963.891983229',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO_IDX.363.891987995',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO_IDX.535.891988391',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO_IDX.542.891988389',
'+DGDATA/t11simul/datafile/EGEL_PRODUCAO_IDX.555.891983229',
'+DGDATA/t11simul/datafile/EGEL_RECUPERACAO.509.891983643',
'+DGDATA/t11simul/datafile/EGEL_RECUPERACAO.947.891987995',
'+DGDATA/t11simul/datafile/ETICK.382.891988389',
'+DGDATA/t11simul/datafile/GSAHD.558.891988391',
'+DGDATA/t11simul/datafile/LABSOFT.712.891983229',
'+DGDATA/t11simul/datafile/LABSOFTIDX.523.891983645',
'+DGDATA/t11simul/datafile/RECUPERA.876.891987995',
'+DGDATA/t11simul/datafile/REPO_EXPDP.658.891985981',
'+DGDATA/t11simul/datafile/REPO_EXPDP.952.891980057',
'+DGDATA/t11simul/datafile/SPEDFISCAL.606.891981723',
'+DGDATA/t11simul/datafile/SPEDFISCAL.718.891985981',
'+DGDATA/t11simul/datafile/STATSPACK.532.891980057',
'+DGDATA/t11simul/datafile/SYSAUX.557.891985981',
'+DGDATA/t11simul/datafile/SYSTEM.651.891981723',
'+DGDATA/t11simul/datafile/TSIDXETICK.385.891988391',
'+DGDATA/t11simul/datafile/TSIDXGSHD.365.891987995',
'+DGDATA/t11simul/datafile/TSIND_EMS206BMULTIO10P10102.1255.891985979',
'+DGDATA/t11simul/datafile/TSIND_EMS506PORO9P10104.1180.891985979',
'+DGDATA/t11simul/datafile/TSIND_HCM210AMULTO9P10111.406.891980057',
'+DGDATA/t11simul/datafile/TS_CONTRACESSO.524.891981725',
'+DGDATA/t11simul/datafile/TS_CRM.1019.891984061',
'+DGDATA/t11simul/datafile/TS_EMS2.553.891981725',
'+DGDATA/t11simul/datafile/TS_EMS206BMULTIO10P10102.1174.891984059',
'+DGDATA/t11simul/datafile/TS_EMS206BMULTIO10P10102.548.891981723',
'+DGDATA/t11simul/datafile/TS_EMS206BMULTIO10P10102.559.891984059',
'+DGDATA/t11simul/datafile/TS_EMS5.556.891985981',
'+DGDATA/t11simul/datafile/TS_EMS506PORO9P10104.1296.891980055',
'+DGDATA/t11simul/datafile/TS_FND.539.891984061',
'+DGDATA/t11simul/datafile/TS_GP.527.891981725',
'+DGDATA/t11simul/datafile/TS_HCM.544.891984059',
'+DGDATA/t11simul/datafile/TS_HCM210AMULTO9P10111.357.891980057',
'+DGDATA/t11simul/datafile/TS_HCM210AMULTO9P10111.533.891981723',
'+DGDATA/t11simul/datafile/TS_MERGE.537.891980057',
'+DGDATA/t11simul/datafile/UNDOTBS1.531.891980057',
'+DGDATA/t11simul/datafile/UNDOTBS1.536.891985981',
'+DGDATA/t11simul/datafile/UNDOTBS1.596.891980057',
'+DGDATA/t11simul/datafile/USERS.543.891981725',
'+DGDATA/t11simul/datafile/USERS.549.891985981',
'+DGDATA/t11simul/datafile/USERS.949.891984059'
 CHARACTER SET WE8ISO8859P1;



                                            Tamanho      Tamanho      Espaco       Espaco        %
Tablespace                  T     Em uso      atual       maximo livre atual  livre total Ocupacao
--------------------------- - ---------- ---------- ------------ ----------- ------------ --------
REPO_EXPDP                  P          0      5,120        6,144       5,119        6,143        0
TS_EMS5                     P         56        384       32,767         327       32,710        0
TS_CRM                      P         66        128       32,767          61       32,700        0
TSIDXETICK                  P          5         10        4,096           4        4,090        0
RECUPERA                    P          0          2        4,096           1        4,095        0
GSAHD                       P         14         20        4,096           5        4,081        0
STATSPACK                   P          7        512        4,096         504        4,088        0
TS_FND                      P        283        384       32,767         100       32,483        0
TSIDXGSHD                   P          7         10        4,096           2        4,088        0
UNDOTBS1                    U        151     12,776       51,200      12,624       51,048        0
TS_MERGE                    P          0        128       32,767         127       32,766        0
TS_GP                       P        359        384       32,767          24       32,407        1
TS_CONTRACESSO              P        209        220        8,192          10        7,982        2
SPEDFISCAL                  P        358      4,346        8,192       3,987        7,833        4
TS_HCM                      P      1,366      1,408       32,767          41       31,400        4
TSIND_HCM210AMULTO9P10111   P      1,528      3,850       32,767       2,321       31,239        4
TS_EMS2                     P      2,292      2,304       32,767          11       30,474        6
ETICK                       P        390      4,096        4,096       3,705        3,705        9
D7IPROD_DATA                P        553      1,512        4,096         958        3,542       13
TS_HCM210AMULTO9P10111      P     11,472     12,250       65,535         777       54,063       17
TSIND_EMS206BMULTIO10P10102 P      5,822     14,550       32,767       8,727       26,945       17
D7IPROD_INDEX               P        759      4,096        4,096       3,336        3,336       18
LABSOFTIDX                  P        817      1,024        4,096         206        3,278       19
TEMP                        T     10,240     10,240       32,767           0       22,527       31
TEMP1                       T     40,959     40,959       53,247           0       12,288       76
                              ---------- ---------- ------------ ----------- ------------
Total:                           195,841    255,338      765,937      59,465      570,069


alter tablespace TEMP add tempfile '+DGDATA' size 200m autoextend on next 128m maxsize 8g;
alter tablespace TEMP1 add tempfile '+DGDATA' size 200m autoextend on next 128m maxsize 8g;