-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Lista as features usadas pelo banco de dados.
-- Nome do arquivo     : jbls_feature_db.sql
-- Data de criação     : 01/03/2014
-- Data de atualização : 13/04/2016
-- -----------------------------------------------------------------------------------

set feedback on
set serveroutput on

set lines 300 long 500 pages 100

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

declare
    v_SP varchar2(3):=chr(59)||chr(32);
    v_1 varchar2(3);
    v_Titulo varchar2(2000);
    v_Result varchar2(2000);
begin

dbms_output.put_line(chr(10)||chr(10)||rpad('#',129,'#'));
dbms_output.put_line('FEATURE USADAS');
dbms_output.put_line(rpad('#',129,'#')||chr(10));

v_Titulo:=rpad('DBID',13,' ')||v_SP||rpad('NAME',40,' ')||v_SP||rpad('VERSION',12,' ')||v_SP||rpad('DETECTED USAGES',17,' ')||v_SP||rpad('FIRST USAGE DATE',20,' ')||v_SP||rpad('LAST USAGE DATE',20,' ')||v_SP||'DESCRIPTION';

dbms_output.put_line(v_Titulo);

for y in (
select distinct parameter from v$option where parameter not in ('Basic Compression','Unused Block Compression','Advanced Compression') and VALUE='TRUE'
) loop

    begin

        for x in (SELECT * from DBA_FEATURE_USAGE_STATISTICS
        where DETECTED_USAGES <> 0 and (NAME like ''||y.parameter||'%' or y.parameter like ''||NAME||'%')
        and name not in ('AWR Report','Automatic Workload Repository','Data Guard','Data Guard Broker','Database Replay: Workload Capture','Diagnostic Pack','Label Security','Locator','Messaging Gateway','OLAP - Analytic Workspaces','OLAP - Cubes','Oracle Database Vault','Partitioning (system)','Partitioning (user)','Real Application Clusters (RAC)','SQL Tuning Advisor','SQL Tuning Set','Spatial','Transparent Gateway','Tuning Pack','Partitioning','Incremental backup and recovery','Change Data Capture','Spatial','OLAP Window Functions','Block Media Recovery','Fine-grained Auditing','Enterprise User Security','Oracle Data Guard','Oracle Label Security','OLAP','Table compression','Transparent Data Encryption','Backup Encryption','Unused Block Compression','Oracle Database Vault','Real Application Testing')) loop

        v_Result:=rpad(x.DBID,13,' ')||v_SP||rpad(x.NAME,40,' ')||v_SP||rpad(x.VERSION,12,' ')||v_SP||rpad(x.DETECTED_USAGES,17,' ')||v_SP||rpad(x.FIRST_USAGE_DATE,20,' ')||v_SP||rpad(x.LAST_USAGE_DATE,20,' ')||v_SP||x.DESCRIPTION;

        dbms_output.put_line(v_Result);

        end loop;

    end;

end loop;

for x in (
SELECT * from DBA_FEATURE_USAGE_STATISTICS where DETECTED_USAGES > 0 and
    (name like '%ADDM%'
    or (name like '%Compression%' and name not like '%HeapCompression%')  -- (#46352) - Ignore HeapCompression in dba fus)
    or (name like '%SQL Tuning%' and name not like 'Automatic SQL Tuning Advisor') -- (#46989) - Ignore Automatic SQL Tuning Advisor in DBA FUS
    or (name like '%Datapump%Export%' and regexp_like(lower(feature_info), '*compression used: [1-9]* times*'))
    or (name in ('AWR Report','Automatic Workload Repository','Data Guard','Data Guard Broker','Database Replay: Workload Capture','Diagnostic Pack','Label Security','Locator','Messaging Gateway','OLAP - Analytic Workspaces','OLAP - Cubes','Oracle Database Vault','Partitioning (system)','Partitioning (user)','Real Application Clusters (RAC)','SQL Tuning Advisor','SQL Tuning Set','Spatial','Transparent Gateway','Tuning Pack','Partitioning','Incremental backup and recovery','Change Data Capture','Spatial','OLAP Window Functions','Block Media Recovery','Fine-grained Auditing','Enterprise User Security','Oracle Data Guard','Oracle Label Security','OLAP','Table compression','Transparent Data Encryption','Backup Encryption','Unused Block Compression','Oracle Database Vault','Real Application Testing'))
    )
order by name, version
) loop

        v_Result:=rpad(x.DBID,13,' ')||v_SP||rpad(x.NAME,40,' ')||v_SP||rpad(x.VERSION,12,' ')||v_SP||rpad(x.DETECTED_USAGES,17,' ')||v_SP||rpad(x.FIRST_USAGE_DATE,20,' ')||v_SP||rpad(x.LAST_USAGE_DATE,20,' ')||v_SP||x.DESCRIPTION;

        dbms_output.put_line(v_Result);

end loop;

dbms_output.put_line(chr(10)||chr(10));

dbms_output.put_line('PARAMETRO QUE ESTAO HABILITADOS MAS NAO FORAM USADOS;');
for y in (
    select distinct parameter from v$option where parameter not in ('Basic Compression','Unused Block Compression','Advanced Compression') and VALUE='TRUE')
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

dbms_output.put_line('PARAMETRO NAO ENCONTRADO NA (DBA_FEATURE_USAGE_STATISTICS) MAS ESTA COMO (TRUE) NA V$OPTION;');
for y in (select distinct parameter from v$option where parameter not in ('Basic Compression','Unused Block Compression','Advanced Compression') and VALUE='TRUE')
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

