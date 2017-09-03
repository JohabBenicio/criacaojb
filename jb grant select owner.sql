create user view_orcl identified by gB3s65S5#Out_olT;
grant create session to view_orcl;




set serveroutput on
DECLARE
    V_OWNER varchar2(30):='DATACENTER';
    V_NEW_OWNER varchar2(30):='VIEW_ORCL';

BEGIN

for x in (select 'grant select on '||owner||'.'||object_name||' to '||V_NEW_OWNER comando from dba_objects where object_type in ('TABLE','VIEW') and owner=V_OWNER )LOOP
    execute immediate x.comando;
    --dbms_output.put_line(x.comando);
END LOOP;

END;
/


set lines 200 pages 9999
select * from dba_tab_privs where GRANTEE='VIEW_ORCL';

