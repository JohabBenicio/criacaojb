

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

SELECT owner,table_name,num_rows,(blocks*8)/1024 Kb,LAST_ANALYZED FROM DBA_TABLES where owner='WMSPRD2' and table_name='ENTIDADE';



select table_owner, table_name, inserts, updates, deletes from dba_tab_modifications where table_name='ENTIDADE' and table_owner='WMSPRD2';




SQL>
SQL> SELECT owner,table_name,num_rows,(blocks*8)/1024 Kb,LAST_ANALYZED FROM DBA_TABLES where owner='WMSPRD2' and table_name='ENTIDADE';

OWNER            TABLE_NAME          NUM_ROWS      KB LAST_ANALYZED
------------------------------ ------------------------------ --------------- --------------- -------------------
WMSPRD2            ENTIDADE              848039    190.578125 02/02/2017 23:32:15
SQL>
SQL> select table_owner, table_name, inserts, updates, deletes from dba_tab_modifications where table_name='ENTIDADE' and table_owner='WMSPRD2';

TABLE_OWNER          TABLE_NAME           INSERTS       UPDATES       DELETES
------------------------------ ------------------------------ --------------- --------------- ---------------
WMSPRD2            ENTIDADE         25473   33438       0
SQL>



SQL> select count(*) from WMSPRD2.ENTIDADE;

       COUNT(*)
---------------
   873707


