
set serveroutput on
set lines 200 pages 999 long 99999
declare
VUSU varchar2(90):=upper('&owner');

begin
for x in (SELECT distinct grantee FROM dba_role_privs where grantee in (VUSU))LOOP
    dbms_output.put_line(chr(10)||chr(10));
    dbms_output.put_line('NOME DO OWNER:........................... '||x.grantee||chr(10));

for y in (SELECT distinct granted_role, ADMIN_OPTION, grantee FROM dba_role_privs where grantee = x.grantee)LOOP

    dbms_output.put_line('ROLE NAME:..... '||y.granted_role);
    dbms_output.put_line('ADMIN OPTION:.. '||y.ADMIN_OPTION);

    for x in (select distinct  privilege from dba_sys_privs where grantee=y.granted_role)LOOP
    if y.granted_role <> 'DBA' then
    dbms_output.put_line('............... '||x.privilege);
    end if;
    end loop;
    dbms_output.put_line(chr(10));
END LOOP;
END LOOP;

for x in (select privilege,owner,table_name,grantee,DECODE(grantable,'YES','WITH GRANT OPTION;',';') grantable from dba_tab_privs where grantee in (VUSU))loop

if x.privilege = 'WRITE' or x.privilege = 'READ' then
    dbms_output.put_line('grant '||x.privilege||' on directory '||x.OWNER||'.'||x.TABLE_NAME||' to '||x.GRANTEE||' '||x.grantable);
else
    dbms_output.put_line('grant '||x.privilege||' on '||x.OWNER||'.'||x.TABLE_NAME||' to '||x.GRANTEE||' '||x.grantable);
end if;

end loop;

end;
/
