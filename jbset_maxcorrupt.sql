-- set maxcorrupt

set serveroutput on
set pages 100 lines 200 long 200

declare
v_qtd_channel numeric(2):='&QTD_CHANNEL';
v_dir_backup varchar2(100):='&DIR_BACKUP';

begin

  dbms_output.put_line(chr(10)||chr(10)||chr(10)||'run{ ');

  for x in (select  file_id, tablespace_name from dba_data_files order by 1) loop
    dbms_output.put_line('   set maxcorrupt for datafile ' || x.file_id || ' to 100;' || chr(10) || 'backup datafile ' || x.file_id || ';');
  end loop;

  for y in 1..v_qtd_channel loop
    dbms_output.put_line('    allocate channel chl'|| y || ' device type disk maxpiecesize=2048M;');
  end loop;

  dbms_output.put_line(chr(10) || 'backup database format ''' || v_dir_backup || 'full_%d_%s_%p_%D_%M_%Y_%t'''); 
  dbms_output.put_line(chr(10) || 'plus archivelog' || chr(10) || 'format ''' || v_dir_backup || 'arch_%d_%s_%p_%D_%M_%Y_%t'';');
  dbms_output.put_line(chr(10) || 'backup as compressed backupset' || chr(10) || 'format ''' || v_dir_backup || 'control_%d_%s_%p_%d_%T_%t'' current controlfile;' );
  dbms_output.put_line(chr(10) || 'backup as compressed backupset' || chr(10) || 'format ''' || v_dir_backup || 'spfile_%s_%p_%t'' spfile;' || chr(10));

  for y in 1..v_qtd_channel loop
    dbms_output.put_line('    release channel chl'|| y || ';');
  end loop;
   
  dbms_output.put_line(' }'||chr(10)||chr(10)||chr(10));

end;
/
