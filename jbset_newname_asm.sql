-- Set newname
set serveroutput on
set pages 100 lines 200 long 200
declare
v_diretorio varchar2(90):=upper('&novo_local_asm');
v_qtd_channel numeric(2):='&QTD_CHANNEL';
v_dir char(1);
v_size number;
v_qtd number;
begin
select substr(v_diretorio,1,1) into v_dir from dual;
if v_dir != '+' then
  v_diretorio:='+'||v_diretorio;
end if;
  dbms_output.put_line(chr(10)||chr(10)||chr(10)||'run{ ');
for y in 1..v_qtd_channel loop
  IF Y < v_qtd_channel THEN
  dbms_output.put_line('allocate channel channel'|| y || ' device type disk;');
  ELSE
  dbms_output.put_line('allocate channel channel'|| y || ' device type disk;'||CHR(10));
  END IF;
end loop;

    for x in (select  file_id, tablespace_name from dba_data_files order by 1) loop
      dbms_output.put_line('set newname for datafile ' || x.file_id || ' to ''' || v_diretorio || ''';');
    end loop;
    for x in (select  file_id, tablespace_name from dba_temp_files order by 1) loop
      dbms_output.put_line('set newname for tempfile ' || x.file_id || ' to ''' || v_diretorio || ''';');
    end loop;
      dbms_output.put_line('COMANDO DO RESTORE OU DUPLICATE');
      dbms_output.put_line('LOGFILE');

    SELECT (A.MB/B.QTD),B.QTD into v_size,v_qtd FROM (SELECT SUM(BYTES)/1024/1024 MB FROM V$LOG) A, (SELECT COUNT(*) QTD FROM V$LOG) B;
      FOR Y IN 1..v_qtd LOOP
        IF Y < v_qtd THEN
          DBMS_OUTPUT.PUT_LINE('GROUP ' || Y || '(''' || V_DIRETORIO || ''') SIZE ' || v_size || 'M REUSE,');
        ELSE
          DBMS_OUTPUT.PUT_LINE('GROUP ' || Y || '(''' || V_DIRETORIO || ''') SIZE ' || v_size || 'M REUSE;');
        END IF;
      END LOOP;
for y in 1..v_qtd_channel loop
  IF Y = 1 THEN
    dbms_output.put_line(CHR(10)||'release channel channel'|| y || ';');
  ELSE
    dbms_output.put_line('release channel channel'|| y || ';');
  END IF;
end loop;
  dbms_output.put_line(' }'||chr(10)||chr(10)||chr(10));
end;
/
