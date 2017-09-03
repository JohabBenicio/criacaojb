echo "Servidor: $(hostname)">/tmp/SizeDB.out
while read SID
do

VORATAB=$(grep "$SID:" /etc/oratab | wc -l)
if [ "$VORATAB" -eq "1" ]; then
export ORAENV_ASK=NO ; ORACLE_SID=$SID ; . oraenv; export ORAENV_ASK=YES;
else
export ORACLE_SID=$SID
fi

sqlplus -S / as sysdba <<EOF>>/tmp/SizeDB.out
set serveroutput on feedback off
declare
name_db varchar2(90);
size_db varchar2(90);
BEGIN
SELECT NAME into name_db FROM V\$DATABASE;
select sum(trunc(d.tbs_size/1024/1024)) into size_db
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
      t.tablespace_name = s.tablespace(+);

dbms_output.put_line(name_db||': '||size_db||' Mb');

END;
/


quit;
EOF

done < <(ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/')
clear
cat /tmp/SizeDB.out
rm -f /tmp/SizeDB.out





















Servidor: hq-tgl-devor-01
SILTCRT: 396070 Mb
SILTHOM: 110422 Mb

Servidor: HQ-TGL-OR-00.tegma.br
WMS: 146539 Mb
SILTCRT: 42021 Mb
TMSHMLG: 317767 Mb
WMSTEGMA: 423469 Mb

Servidor: hq-tgl-db-03.tegma.br
HELAS: 295696 Mb

Servidor: hq-tgl-or-03.tegma.br e hq-tgl-or-04.tegma.br
RMAN: 2317 Mb
HELASBA: 185386 Mb
TMSDRT: 220356 Mb
WMSPRD: 95886 Mb
SILT: 505347 Mb
WMSBA: 255662 Mb
WMS: 448447 Mb
WMSTEGMA: 425495 Mb
SILTCRT: 599715 Mb

Servidor: vt-tgl-bd-01.tegma.br
WMSVIXQA: 171044 Mb
WMSVIXPD: 171684 Mb
WMSVIXHM: 171438 Mb

Servidor: sb-tgl-hmor-01
SILTHML: 140247 Mb
SILT: 435519 Mb
SILTCRT: 436939 Mb









