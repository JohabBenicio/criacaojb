7) How to find the complete SQL statement caused ORA-1555 :

If the Database was not restarted after the error ORA-1555 , so the Statement can be obtained from :

select SQL_TEXT from SQL_TEXT where SQL_ID='<sql id from the error message>';

If the Database was restarted after the error ORA-1555 and an AWR snapshot was gathered before the restart , so the Statement can be obtained from :

select SQL_TEXT from DBA_HIST_SQLTEXT where SQL_ID='<sql id from the error message>';


