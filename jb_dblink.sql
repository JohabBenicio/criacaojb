#############################################################################################################
#





set lines 300 pages 2000 long 9999
col DBLINK for a140
SELECT owner,REPLACE(TRIM(dbms_metadata.get_ddl('DB_LINK',db_link,owner)),CHR(10),' ')||';' DBLINK FROM dba_db_links ORDER BY 1;






SET lines 800
SET LONG 800
SET serveroutput ON
BEGIN
  FOR x IN
  (SELECT owner,db_link, username, host FROM dba_db_links ORDER BY 1,2
  )
  LOOP
    dbms_output.put_line('      ');
    dbms_output.put_line('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    dbms_output.put_line('DDL:');
    dbms_output.put_line('SELECT dbms_metadata.get_ddl(''DB_LINK'',''' || x.db_link || ''',''' || x.owner || ''') stmt FROM dual;' );
    dbms_output.put_line('      ');
    dbms_output.put_line('Host: ');
    dbms_output.put_line(x.host);
  END LOOP;
END;
/


#############################################################################################################
#
spool /tmp/dblink_database.sql
SET lines 800
SET LONG 800
SET serveroutput ON
define vowner = 'SYS_VETORH'
BEGIN
  FOR x IN
  (SELECT owner,
    db_link,
    username,
    host
  FROM dba_db_links
  WHERE owner='&vowner'
  ORDER BY 1,2
  )
  LOOP
    dbms_output.put_line('      ');
    dbms_output.put_line('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');
    dbms_output.put_line('DDL:');
    dbms_output.put_line('SELECT dbms_metadata.get_ddl(''DB_LINK'',''' || x.db_link || ''',''' || x.owner || ''') stmt FROM dual;' );
    dbms_output.put_line('      ');
    dbms_output.put_line('Host: ');
    dbms_output.put_line(x.host);
  END LOOP;
END;
/
spool off;

#############################################################################################################
# Matar todos DBLINKS

SET lines 200 LONG 999 pages 999 feed off serveroutput ON
BEGIN
  dbms_output.put_line(chr(10)||chr(10)||chr(10));
  FOR x IN
  (SELECT owner,db_link, username, host FROM dba_db_links ORDER BY 1,2
  )
  LOOP
    dbms_output.put_line(chr(10));
    IF x.owner = 'PUBLIC' THEN
      dbms_output.put_line('drop public database link '||x.db_link||';' );
    ELSE
      dbms_output.put_line('create procedure '||x.owner||'.JHB_MYTH_DROP_DB_LINK as ');
      dbms_output.put_line('begin ');
      dbms_output.put_line('EXECUTE IMMEDIATE '||chr(39)||'drop database link '||x.db_link||chr(39)||';');
      dbms_output.put_line('end;');
      dbms_output.put_line('/'||chr(10));
      dbms_output.put_line('exec '||x.owner||'.JHB_MYTH_DROP_DB_LINK; ');
      dbms_output.put_line('drop procedure '||x.owner||'.JHB_MYTH_DROP_DB_LINK; ');
    END IF;
  END LOOP;
END;
/






