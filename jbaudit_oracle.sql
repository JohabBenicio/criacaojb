rm -f /tmp/jbaudit_oracle.sh
vi /tmp/jbaudit_oracle.sh
i
#!/bin/bash

while read SID
do

VORATAB=$(grep "$SID:" /etc/oratab | wc -l)
if [ "$VORATAB" -eq "1" ]; then
export ORAENV_ASK=NO ; ORACLE_SID=$SID ; . oraenv; export ORAENV_ASK=YES;
else
export ORACLE_SID=$SID
fi

sqlplus -S / as sysdba <<EOF>/tmp/audit_oracle_$SID.txt
set head off
set colsep ';'
pro INSTANCIA;RAC;STATUS;DATABASE;MODO ARCHIVE;VERSAO
set feedback off;
set lines 200;
col STATUS for a15
col "OPEN MODE" for a11
col INSTANCIA for a15
col VERSAO for a80
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
    INS.PARALLEL RAC,
    INS.STATUS,
    DAT.NAME DATABASE,
    DAT.LOG_MODE "MODO ARCHIVE",
    VER.BANNER VERSAO
FROM V\$INSTANCE INS, V\$DATABASE DAT, V\$VERSION VER
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';
set colsep ''

set serveroutput on
set lines 300 long 500 pages 100

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

declare
    v_SP varchar2(3):=chr(59)||chr(32);
    v_1 varchar2(3);
    v_Titulo varchar2(2000);
    v_Result varchar2(2000);
begin
dbms_output.put_line(chr(10)||chr(10));

v_Titulo:=rpad('DBID',13,' ')||v_SP||rpad('NAME',50,' ')||v_SP||rpad('VERSION',12,' ')||v_SP||rpad('DETECTED USAGES',17,' ')||v_SP||rpad('FIRST USAGE DATE',20,' ')||v_SP||rpad('LAST USAGE DATE',20,' ')||v_SP||'DESCRIPTION';

dbms_output.put_line(v_Titulo);

for y in (
select distinct parameter from v\$option where parameter not in ('Basic Compression','Unused Block Compression','Advanced Compression') and VALUE='TRUE'
) loop

    begin

        for x in (SELECT distinct dbid,name,version,detected_usages,first_usage_date,last_usage_date,description from DBA_FEATURE_USAGE_STATISTICS
        where DETECTED_USAGES <> 0 and (NAME like ''||y.parameter||'%' or y.parameter like ''||NAME||'%')) loop

        v_Result:=rpad(x.DBID,13,' ')||v_SP||rpad(x.NAME,50,' ')||v_SP||rpad(x.VERSION,12,' ')||v_SP||rpad(x.DETECTED_USAGES,17,' ')||v_SP||rpad(x.FIRST_USAGE_DATE,20,' ')||v_SP||rpad(x.LAST_USAGE_DATE,20,' ')||v_SP||x.DESCRIPTION;

        dbms_output.put_line(v_Result);

        end loop;

    end;

end loop;
dbms_output.put_line(chr(10)||chr(10));
dbms_output.put_line(v_Titulo);

for x in (select distinct * from
            (SELECT dbid,name,version,detected_usages,first_usage_date,last_usage_date,description
            from DBA_FEATURE_USAGE_STATISTICS
            where DETECTED_USAGES <> 0 and
               (upper(name) like '%ADDM%'
            or (upper(name) like '%COMPRESSION%' and upper(name) not like '%HEAPCOMPRESSION%')  -- (#46352) - Ignore HeapCompression in dba fus)
            or (upper(name) like '%SQL TUNING%'  and upper(name) not like 'AUTOMATIC SQL TUNING ADVISOR') -- (#46989) - Ignore Automatic SQL Tuning Advisor in DBA FUS
            or (upper(name) like '%DATAPUMP%EXPORT%' and regexp_like(upper(feature_info), '*COMPRESSION USED: [1-9]* TIMES*')))
            union all
            SELECT dbid,name,version,detected_usages,first_usage_date,last_usage_date,description
            from DBA_FEATURE_USAGE_STATISTICS
            where DETECTED_USAGES <> 0 and upper(name) in ('AWR REPORT','AUTOMATIC WORKLOAD REPOSITORY','DATA GUARD','DATA GUARD BROKER','DATABASE REPLAY: WORKLOAD CAPTURE','DIAGNOSTIC PACK','LABEL SECURITY','LOCATOR','MESSAGING GATEWAY','OLAP - ANALYTIC WORKSPACES','OLAP - CUBES','ORACLE DATABASE VAULT','PARTITIONING (SYSTEM)','PARTITIONING (USER)','REAL APPLICATION CLUSTERS (RAC)','SQL TUNING ADVISOR','SQL TUNING SET','SPATIAL','TRANSPARENT GATEWAY','TUNING PACK','PARTITIONING','INCREMENTAL BACKUP AND RECOVERY','CHANGE DATA CAPTURE','SPATIAL','OLAP WINDOW FUNCTIONS','BLOCK MEDIA RECOVERY','FINE-GRAINED AUDITING','ENTERPRISE USER SECURITY','ORACLE DATA GUARD','ORACLE LABEL SECURITY','OLAP','TABLE COMPRESSION','TRANSPARENT DATA ENCRYPTION','BACKUP ENCRYPTION','UNUSED BLOCK COMPRESSION','ORACLE DATABASE VAULT','REAL APPLICATION TESTING')) query
            ) loop

        v_Result:=rpad(x.DBID,13,' ')||v_SP||rpad(x.NAME,50,' ')||v_SP||rpad(x.VERSION,12,' ')||v_SP||rpad(x.DETECTED_USAGES,17,' ')||v_SP||rpad(x.FIRST_USAGE_DATE,20,' ')||v_SP||rpad(x.LAST_USAGE_DATE,20,' ')||v_SP||x.DESCRIPTION;

        dbms_output.put_line(v_Result);

        end loop;

dbms_output.put_line(chr(10)||chr(10));

dbms_output.put_line('PARAMETRO QUE ESTAO HABILITADOS MAS NAO FORAM USADOS;');
for y in (
    select distinct parameter from v\$option where parameter not in ('Basic Compression','Unused Block Compression','Advanced Compression') and VALUE='TRUE')
loop
    begin

    for x in (
        SELECT NAME from DBA_FEATURE_USAGE_STATISTICS where DETECTED_USAGES = 0 and (NAME like ''||y.parameter||'%' or y.parameter like ''||NAME||'%')
        )
        loop
        dbms_output.put_line(x.NAME || ';');
        end loop;

    exception
        when NO_DATA_FOUND then dbms_output.put_line(' ');
    end;
end loop;

dbms_output.put_line(chr(10)||chr(10));

dbms_output.put_line('PARAMETRO NAO ENCONTRADO NA (DBA_FEATURE_USAGE_STATISTICS) MAS ESTA COMO (THUE) NA V\$OPTION;');
for y in (select distinct parameter from v\$option where parameter not in ('Basic Compression','Unused Block Compression','Advanced Compression') and VALUE='TRUE')
loop
    SELECT count(NAME) into v_1 from DBA_FEATURE_USAGE_STATISTICS
    where NAME like ''||y.parameter||'%' and y.parameter like ''||NAME||'%';

    if v_1 <> 0 then
    dbms_output.put_line(y.parameter || ';');
    end if;

end loop;
dbms_output.put_line(chr(10)||chr(10));

end;
/

quit;
EOF

echo "/tmp/audit_oracle_$SID.txt"
done < <(ps -ef | grep smon | grep -iv "grep\|+\|/\|-" | sed 's/.*mon_\(.*\)$/\1/')




