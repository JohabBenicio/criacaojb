

set lines 200
set serveroutput on
declare
vpid varchar2(200);
vtrace varchar2(2000);
vtrace1 varchar2(2000);
begin
dbms_output.put_line(chr(10)||chr(10)||chr(10));

for v1 in (select * from sys.traceflag where flag=1)LOOP

for x in (select distinct s.sql_id,s.username,s.program,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,s.LOGON_TIME,s.status,s.EVENT, i.instance_name,i.host_name,s.paddr
from gv$session s,gv$instance i
where (upper(s.osuser)=upper(v1.osuser) or upper(s.username)=upper(v1.username))
and s.inst_id=i.inst_id
order by 5) LOOP



dbms_output.put_line(rpad('+',40,'+')||' SESSAO '||rpad('+',40,'+')||chr(10));
    dbms_output.put_line('DATABASE INFORMATION:');
    dbms_output.put_line(rpad('USUARIO DATABASE:',29,'.')||chr(32)||lpad(x.username,10,' ')||chr(32)||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
    dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,10,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
    dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,10,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name||chr(10) );

    dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
    dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || chr(10));

    dbms_output.put_line('S.O INFORMATION:');

  for y in ( SELECT distinct i.instance_name,p.spid,pa.value from gv$process p, gv$instance i, gv$parameter pa where pa.NAME like '%user_dump_dest%' and i.inst_id=p.inst_id and i.inst_id=pa.inst_id and  addr = x.paddr and spid is not null) LOOP

  if vpid is not null then
    vpid:=y.spid ||', '|| vpid;
    vtrace:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '.trc'||chr(10)||vtrace;
    vtrace1:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.username || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc'||chr(10)||vtrace1;
  else
    vpid:=y.spid;
    vtrace:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '.trc';
    vtrace1:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.username || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc';
  end if;

END LOOP;

    dbms_output.put_line('PID:......................... ' || vpid);

    dbms_output.put_line('S/O USER:.................... ' || x.osuser);
    dbms_output.put_line('MACHINE:..................... ' || x.machine || chr(10));
    dbms_output.put_line('KILL SESSION:');
    dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||',@'||x.inst_id||''' immediate;' || chr(10));


if x.sql_id is not null then
    dbms_output.put_line('QUERY INFORMATION:');
    dbms_output.put_line('SQL_ID ATUAL:....... ' || nvl(x.sql_id,'NONE'));
    dbms_output.put_line('QUERY TEXT:'||chr(10)||'select sql_fulltext from gv$sql where sql_id=''' || x.sql_id || ''';' || chr(10));
else
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('NESTE MOMENTO O SQL_ID ESTA NULO');
end if;

DBMS_OUTPUT.PUT_LINE('NOME DO TRACE:' || chr(10) || vtrace || chr(10)||'OU'||chr(10)||vtrace1);


END LOOP;
END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(chr(10)||chr(10)||chr(10)||'Tabela traceflag não encontrada.'||chr(10)||chr(10)||chr(10));

end;
/
