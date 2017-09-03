

rm -f jbcheck_list.sh

vi jbcheck_list.sh
i

#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer detalhes do servidor LINUX e banco de dados
#-- Nome do arquivo     : jbcheck_list.sh
#-- Data de criação     : 04/11/2014
#-- Data de atualização : 24/11/2014
#-- -----------------------------------------------------------------------------------

BASH=~/.bash_profile

if [ -e "$BASH" ]; then
  . $BASH
else
  BASH=~/.profile
  . $BASH
fi

EXEC_DIG=`cat $BASH | grep -i $0 | awk {'print $2'} | cut -f1 -d"="`

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"

if [ "$USER" != "oracle" ]; then
  echo -e "\n\nExecute com usuario 'ORACLE'\n\n"
  exit
fi

BANCO=`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |$)"`

LOG=check_list_$1.log

if [ -z "$1" ]; then

  if [ -z "$EXEC_DIG" ]; then
    echo teste1
    echo -e "\n\nPARA CRIAR UM LOG => check_list_<SID>.log\n"
    ps -ef | grep smon | grep -v opuser | grep -v "asm" | grep -v "ASM" | sed 's/.*mon_\(.*\)$/\1/' | while read instance
    do
      echo -e "Digite: sh $0 $instance Y <QTD LINHAS ALERT>\n"
    done
    echo -e "\nPARA NAO CRIAR LOG\n"
    ps -ef | grep smon | grep -v opuser | grep -v "asm" | grep -v "ASM" | sed 's/.*mon_\(.*\)$/\1/' | while read instance
    do
      echo -e "Digite: sh $0 $instance N <QTD LINHAS ALERT>\n"
    done
  else
    echo teste2
    echo -e "\nPARA CRIAR UM LOG => check_list_<SID>.log\n"
    ps -ef | grep smon | grep -v opuser | grep -v "asm" | grep -v "ASM" | sed 's/.*mon_\(.*\)$/\1/' | while read instance
    do
      echo -e "Digite: $EXEC_DIG $instance Y <QTD LINHAS ALERT>\n"
    done
    echo -e "\nPARA NAO CRIAR LOG\n"
    ps -ef | grep smon | grep -v opuser | grep -v "asm" | grep -v "ASM" | sed 's/.*mon_\(.*\)$/\1/' | while read instance
    do
      echo -e "Digite: $EXEC_DIG $instance N <QTD LINHAS ALERT>\n"
    done
  fi
  exit
fi


if [ -z "$2" ]; then
  if [ -z "$EXEC_DIG" ]; then
    echo -e "\n\nPARA CRIAR UM LOG => check_list_<SID>.log\n"
    echo -e "Digite: sh $0 $1 Y <QTD LINHAS ALERT>\n"
    echo -e "\n\nPARA NAO CRIAR LOG\n"
    echo -e "Digite: sh $0 $1 N <QTD LINHAS ALERT>\n\n"
  else
    echo -e "\n\nPARA CRIAR UM LOG => check_list_<SID>.log\n"
    echo -e "Digite: $EXEC_DIG $1 Y <QTD LINHAS ALERT>\n"
    echo -e "\n\nPARA NAO CRIAR LOG\n"
    echo -e "Digite: $EXEC_DIG $1 N <QTD LINHAS ALERT>\n\n"
  fi
  exit
fi
if [ -z "$3" ]; then
  if [ -z "$EXEC_DIG" ]; then
    echo -e "\n\nDigite: sh $0 $1 $2 <QTD LINHAS ALERT>\n"
  else
      echo -e "\n\nDigite: $EXEC_DIG $1 $2 <QTD LINHAS ALERT>\n"
  fi
  exit
fi



if [ "$BANCO" = "$1" ]; then
   export ORACLE_SID=$1
else
   echo "";echo "";echo "Banco nao existe" ;echo "";echo ""
   exit ;
fi


if [ -e "check_0.log" ]; then
  rm -f check_0.log
fi


$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF >> check_0.log

set feedback off;
set lines 500;
col STATUS for a15
col "OPEN MODE" for a11
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
  INS.PARALLEL RAC, 
  INS.STATUS, 
  DAT.NAME DATABASE, 
  DAT.OPEN_MODE "OPEN MODE", 
  DAT.LOG_MODE "MODO ARCHIVE"
FROM V\$INSTANCE INS, V\$DATABASE DAT;


exit;

EOF


if [ -e "check_1.log" ]; then
  rm -f check_1.log
fi


$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF >> check_1.log



set pages 9999 lines 9999
COL KTABLESPACE   FOR A20      HEADING 'Tablespace'
COL KTBS_SIZE     FOR 999,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL KTBS_EM_USO   FOR 999,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL KTBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL KFREE_SPACE   FOR 999,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL KSPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL KPERC         FOR 990      HEADING '%|Ocupacao'          JUSTIFY RIGHT

break on report

compute sum label Total: of ktbs_size    on report
compute sum              of ktbs_em_uso  on report
compute sum              of ktbs_maxsize on report
compute sum              of kfree_space  on report
compute sum              of kspace       on report

select t.tablespace_name ktablespace,
       substr(t.contents, 1, 1) tipo,
       trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) ktbs_em_uso,
       trunc(d.tbs_size/1024/1024) ktbs_size,
       trunc(d.tbs_maxsize/1024/1024) ktbs_maxsize,
       trunc(nvl(s.free_space, 0)/1024/1024) kfree_space,
       trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) kspace,
       decode(d.tbs_maxsize, 0, 0, trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize)) kperc
from
  ( select SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize,
           tablespace_name tablespace
    from ( select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_data_files
           union all
           select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_temp_files
         )
    group by tablespace_name
  ) d,
  ( select SUM(bytes) free_space,
           tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
  ) s,
  dba_tablespaces t
where t.tablespace_name = d.tablespace(+) and
      t.tablespace_name = s.tablespace(+)
order by 8
/

exit;

EOF

if [ -e "check_2.log" ]; then
  rm -f check_2.log
fi

$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF>> check_2.log

SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN free_mb                FORMAT 999,999,999   HEAD 'Free Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
COLUMN pct_free               FORMAT 999.99        HEAD 'Pct. Free'

break on report on disk_group_name skip 1

compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , free_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
  , ROUND((1- ((total_mb - free_mb) / total_mb))*100, 2)  pct_livre
FROM
    v\$asm_diskgroup
ORDER BY
    name
/

exit;

EOF


if [ -e "check_3.log" ]; then
  rm -f check_3.log
fi

$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF>> check_3.log

set feedback off
set serveroutput on

declare 
x varchar2(90);
y varchar2(90);
BEGIN
  
select VALUE into x from v\$parameter where NAME='background_dump_dest';
select instance_name into y from v\$instance;

dbms_output.put_line(chr(10)||x||'/alert_'||y||'.log'||chr(10));

END;
/

exit

EOF

if [ -e "check_4.log" ]; then
  rm -f check_4.log
fi

$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF>> check_4.log

set lines 200 long 200 pages 70
col name for a80
col status for a25
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

select * from (
  select b.instance_name, a.object_type, a.status, a.start_time, a.end_time from v\$rman_status a, v\$instance b order by 4 desc
)
where rownum <=50 order by 3 asc;


EOF



if [ -e "check_5.log" ]; then
  rm -f check_5.log
fi

$ORACLE_HOME/bin/sqlplus / as sysdba <<EOF>> check_5.log

SELECT 
  UPPER(I.INSTANCE_NAME) INSTANCE_NAME, 
  SUBSTR(D.OPEN_MODE,1,11) "OPEN MODE",  
  H.THREAD#, 
  MAX(H.SEQUENCE#) SEQUENCE# 
FROM 
  V\$LOG_HISTORY H, 
  V\$INSTANCE I, 
  V\$DATABASE D 
WHERE 
  H.THREAD# IN (1,2) 
GROUP BY 
  H.THREAD#, 
  I.INSTANCE_NAME, 
  D.OPEN_MODE
ORDER BY 3;

EOF







if [ -e "limpa_log.sh" ]; then
  rm -f limpa_log.sh
fi


cat << EOF > ./limpa_log.sh

LIMPA_LOG=\$1


find \$LIMPA_LOG -exec sed -i '/^$/d;' {} \;
find \$LIMPA_LOG -exec sed -i '/Disconnected from/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Connected to/d' {} \;
find \$LIMPA_LOG -exec sed -i '/ - Production/d' {} \;
find \$LIMPA_LOG -exec sed -i '/SYS@/d' {} \;
find \$LIMPA_LOG -exec sed -i '/ Real Application Testing options/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Disconnected/d' {} \;
find \$LIMPA_LOG -exec sed -i '/With the Real/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Testing options/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Copyright (c)/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Plus: Release/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Oracle Database/d' {} \;
find \$LIMPA_LOG -exec sed -i '/ Management option/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Data Mining/d' {} \;
find \$LIMPA_LOG -exec sed -i '/dbms_output/d' {} \;
find \$LIMPA_LOG -exec sed -i '/select/d' {} \;
find \$LIMPA_LOG -exec sed -i '/begin/d' {} \;
find \$LIMPA_LOG -exec sed -i '/loop/d' {} \;
find \$LIMPA_LOG -exec sed -i '/end/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Session altered/d' {} \;
find \$LIMPA_LOG -exec sed -i '/SQL procedure succes/d' {} \;
find \$LIMPA_LOG -exec sed -i '/Conectado a/d' {} \;
find \$LIMPA_LOG -exec sed -i 's/SQL>//g' {} \;
find \$LIMPA_LOG -exec sed -i '/2    3    4/d' {} \;
#find \$LIMPA_LOG -exec sed -i 's/^M//g' {} \;
find \$LIMPA_LOG -exec sed -i '/==================/G' {} \;
find \$LIMPA_LOG -exec sed -i '/CRS/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/DISK GROUPS ASM/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/ARQUIVELOG SEQUENCE/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/DADOS DO BANCO E INSTANCIA/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/USABILIDADE DA MEMORIA/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/TAMANHO DO BANCO DE DADOS EM MB/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/TABLESPACES/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/DATAFILES/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/ARCHIVING HISTORY/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/COLETA DE ESTATISTICA/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/OBJETOS-INVALIDOS/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/DIREORIO DO DUMP/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;
find \$LIMPA_LOG -exec sed -i '/BACKUP/{x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;x;p;x;}' {} \;

EOF


sh ./limpa_log.sh check_0.log
sh ./limpa_log.sh check_1.log
sh ./limpa_log.sh check_2.log
sh ./limpa_log.sh check_3.log
sh ./limpa_log.sh check_4.log
sh ./limpa_log.sh check_5.log

if [ -e "$LOG" ]; then
  rm -f $LOG
fi

export JBSWPERUS=$(free -m | grep wap | awk  '{ print "Total de Swap Usado: " ($3 * 100) / $2 "%"}');
export JBSWUSGB=$(free -m | grep wap | awk  '{ print "Swap Usado: " $3/1024 " GB"}');
export JBSWUSMB=$(free -m | grep wap | awk  '{ print "Swap Usado: " $3 " MB" }');

export JBSWPERFR=$(free -m | grep wap | awk  '{ print "Total de Swap Livre: " ($4 * 100) / $2 "%"}');
export JBSWFRGB=$(free -m | grep wap | awk  '{ print "Swap Livre: " $4/1024 " GB"}');
export JBSWFRMB=$(free -m | grep wap | awk  '{ print "Swap Livre: " $4 " MB" }');

ALERT=$(cat check_3.log)

echo -e '\n'>> $LOG
echo $JBSWPERUS>> $LOG
echo $JBSWUSGB>> $LOG
echo $JBSWUSMB>> $LOG
echo ''>> $LOG
echo $JBSWPERFR>> $LOG
echo $JBSWFRGB>> $LOG
echo $JBSWFRMB>> $LOG
echo -e '\n'>> $LOG
echo -e '\n'>> $LOG
df -h >> $LOG
echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- Dados da instancia">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
cat check_0.log>> $LOG
echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- TABLESPACES">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
cat check_1.log>> $LOG
echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- ASM">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
cat check_2.log>> $LOG
echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- BACKUP VIA RMAN">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
cat check_4.log>> $LOG
echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- SEQUENCE ARCHIVELOG">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
cat check_5.log>> $LOG
echo -e '\n'>> $LOG

VAL_CRON=$(crontab -l | grep -i exp | grep $ORACLE_SID | wc -l)

if [ "$VAL_CRON" -gt "0" ]; then

crontab -l | grep -i exp | grep $1 | awk {'print $6'} | \
while read export
do
  DIR_EXP=$(cat $export | grep -i "DIR=" |  sed 's/.*=//' |  sed 's/$ORACLE_SID/'$1'/')
  LOG_EXP=$(ls -ltr $DIR_EXP/exp*.log 2>>/dev/null | tail -1 2>>/dev/null | awk {'print $NF'})
  echo $(ls -l "$LOG_EXP" 2>>/dev/null)>> $LOG
  echo "">> $LOG
  tail -20 "$LOG_EXP" 2>>/dev/null >> $LOG
done

echo -e '\n'>> $LOG

fi

echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- ALERT LOG: (Alertas nas ultimas $3 linhas)" >> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo `ll $ALERT` >> $LOG
echo "" >> $LOG
tail -$3 $ALERT 2>>/dev/null | grep -4i "ORA-" | \
while read ALERT_LOG
do
  echo $ALERT_LOG >> $LOG
done

echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- /etc/hosts">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "" >> $LOG
cat /etc/hosts | \
while read HOSTS
do
  echo $HOSTS >> $LOG
done

echo -e '\n'>> $LOG
echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- CRONTAB S.O." >> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
crontab -l | grep -i "$ORACLE_SID" | while read crontab_val
do
  echo "$crontab_val" >> $LOG
done


echo -e '\n'>> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "#-- LOG S.O.">> $LOG
echo "#-- -------------------------------------------------------------------------------------------------">> $LOG
echo "/var/log/messages">> $LOG
echo -e '\n'>> $LOG
echo -e '\n'>> $LOG

#cat $LOG
less $LOG

if [ -e "check_0.log" ]; then
  rm -f check_0.log
fi
if [ -e "check_1.log" ]; then
  rm -f check_1.log
fi
if [ -e "check_2.log" ]; then
  rm -f check_2.log
fi
if [ -e "check_3.log" ]; then
  rm -f check_3.log
fi
if [ -e "check_4.log" ]; then
  rm -f check_4.log
fi
if [ -e "check_5.log" ]; then
  rm -f check_5.log
fi
if [ -e "limpa_log.sh" ]; then
  rm -f limpa_log.sh
fi
if [ "$2" = "N" ]; then
  rm -f $LOG
fi



:wq!




