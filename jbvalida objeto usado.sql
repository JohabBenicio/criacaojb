

select count(s.sql_id) from (select distinct sql_id from gv$session where status='ACTIVE') s, gv$sql sql
where s.sql_id=sql.sql_id
and upper(sql.SQL_FULLTEXT) like '%CVC_AP_REL_TITULOS_PK%'
and upper(sql.SQL_FULLTEXT) not like '%SQL_FULLTEXT%';

