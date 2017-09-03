
set serveroutput on
BEGIN
  dbms_output.put_line(chr(10)||chr(10)||chr(10));
for x in  (select FILE_NAME,FILE_ID,TABLESPACE_NAME from dba_data_files where file_name like '+DATA%' and TABLESPACE_NAME='AUDIT_PROTHEUS') LOOP
    dbms_output.put_line('sql ''alter database datafile '||x.file_id||' offline'';');
    dbms_output.put_line('copy datafile '||x.file_id||' to ''+DG_HOMOLOG'';');
    dbms_output.put_line('switch datafile '||x.file_id||' to copy;');
    dbms_output.put_line('recover datafile '||x.file_id||';');
    dbms_output.put_line('sql ''alter database datafile '||x.file_id||' online'';');
    dbms_output.put_line('DELETE noprompt DATAFILECOPY  '''||x.FILE_NAME||''';'||chr(10)||chr(10)||chr(10));

END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/












sql 'alter database datafile 82 offline';
copy datafile 82 to '+DG_HOMOLOG';
switch datafile 82 to copy;
recover datafile 82;
sql 'alter database datafile 82 online';
DELETE noprompt DATAFILECOPY '+DATA/dadosadv/datafile/audit_protheus.347.847623525';



sql 'alter database datafile 96 offline';
copy datafile 96 to '+DG_HOMOLOG';
switch datafile 96 to copy;
recover datafile 96;
sql 'alter database datafile 96 online';
DELETE noprompt DATAFILECOPY '+DATA/dadosadv/datafile/audit_protheus.336.868015393';



sql 'alter database datafile 97 offline';
copy datafile 97 to '+DG_HOMOLOG';
switch datafile 97 to copy;
recover datafile 97;
sql 'alter database datafile 97 online';
DELETE noprompt DATAFILECOPY '+DATA/dadosadv/datafile/audit_protheus.333.854275509';



sql 'alter database datafile 100 offline';
copy datafile 100 to '+DG_HOMOLOG';
switch datafile 100 to copy;
recover datafile 100;
sql 'alter database datafile 100 online';
DELETE noprompt DATAFILECOPY '+DATA/dadosadv/datafile/audit_protheus.346.865161957';



sql 'alter database datafile 110 offline';
copy datafile 110 to '+DG_HOMOLOG';
switch datafile 110 to copy;
recover datafile 110;
sql 'alter database datafile 110 online';
DELETE noprompt DATAFILECOPY '+DATA/dadosadv/datafile/audit_protheus.377.870603857';



sql 'alter database datafile 115 offline';
copy datafile 115 to '+DG_HOMOLOG';
switch datafile 115 to copy;
recover datafile 115;
sql 'alter database datafile 115 online';
DELETE noprompt DATAFILECOPY '+DATA/dadosadv/datafile/audit_protheus.382.874932167';



