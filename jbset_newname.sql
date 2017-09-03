-- Set newname

set serveroutput on
set pages 100 lines 200 long 200

declare
v_diretorio varchar2(90):='+DATA';
v_qtd_channel numeric(2):='5';

begin

  dbms_output.put_line(chr(10)||chr(10)||chr(10)||'run{ ');
for y in 1..v_qtd_channel loop
  dbms_output.put_line('    allocate channel channel'|| y || ' device type disk;');
end loop;
    for x in (select  file_id, tablespace_name from dba_data_files order by 1) loop
      dbms_output.put_line('  set newname for datafile ' || x.file_id || ' to ''' || v_diretorio || x.tablespace_name || x.file_id || '.dbf'';');
    end loop;

    for x in (select  file_id, tablespace_name from dba_temp_files order by 1) loop
      dbms_output.put_line('  set newname for tempfile ' || x.file_id || ' to ''' || v_diretorio || x.tablespace_name || x.file_id || '.dbf'';');
    end loop;
      dbms_output.put_line('restore database;');
      dbms_output.put_line('switch datafile all;');

for y in 1..v_qtd_channel loop
  dbms_output.put_line('    release channel channel'|| y || ';');
end loop;


  dbms_output.put_line(' }'||chr(10)||chr(10)||chr(10));

end;
/






############################################################################################################################
###  ASM
############################################################################################################################


-- Set newname

set serveroutput on
set pages 100 lines 200 long 200

declare
v_diretorio varchar2(90):='+DATA';
v_qtd_channel numeric(2):='5';

begin

  dbms_output.put_line(chr(10)||chr(10)||chr(10)||'run{ ');
for y in 1..v_qtd_channel loop
  dbms_output.put_line('    allocate channel channel'|| y || ' device type disk;');
end loop;
    for x in (select  file_id, tablespace_name from dba_data_files order by 1) loop
      dbms_output.put_line('  set newname for datafile ' || x.file_id || ' to ''' || v_diretorio || chr(39) || ';');
    end loop;

    for x in (select  file_id, tablespace_name from dba_temp_files order by 1) loop
      dbms_output.put_line('  set newname for tempfile ' || x.file_id || ' to ''' || v_diretorio || chr(39) || ';');
    end loop;
      dbms_output.put_line('restore database;');
      dbms_output.put_line('switch datafile all;');

for y in 1..v_qtd_channel loop
  dbms_output.put_line('    release channel channel'|| y || ';');
end loop;


  dbms_output.put_line(' }'||chr(10)||chr(10)||chr(10));

end;
/

