

pro ============================================================================================
pro ================================ PROCESS & SESSCIONS =======================================
pro ============================================================================================
pro
pro

set serveroutput on

declare
qtd_proc varchar2(90);

BEGIN
dbms_output.put_line(chr(10)||chr(10)||chr(10));

for y in (select * from gv$resource_limit where resource_name in ('processes','sessions') )loop
	dbms_output.put_line('NODE: '||y.inst_id);
	dbms_output.put_line('RESOURCE NAME........... '||ltrim(rtrim(y.resource_name)));
	dbms_output.put_line('CURRENT UTILIZATION..... '||ltrim(rtrim(y.current_utilization)));
	dbms_output.put_line('MAX UTILIZATION......... '||ltrim(rtrim(y.max_utilization)));
	dbms_output.put_line('INITIAL ALLOCATION...... '||ltrim(rtrim(y.initial_allocation)));
	dbms_output.put_line('LIMIT VALUE............. '||ltrim(rtrim(y.limit_value)) ||chr(10));

end loop;

dbms_output.put_line(chr(10)||chr(10));
for x in (select username,inst_id,count(*) qtd_sess from gv$session where username is not null group by username,inst_id order by qtd_sess desc)LOOP
	select count(*) into qtd_proc from gv$process p, gv$session s where p.addr=s.paddr and p.inst_id=x.inst_id and s.username=x.username;

	if x.qtd_sess > 20 or qtd_proc > 20 then
		dbms_output.put_line('NODE: '||x.inst_id ||chr(10)|| 'OWNER:............ '||x.username );
		dbms_output.put_line('QTD. SESSAO:...... '||x.qtd_sess);
		dbms_output.put_line('QTD. PROCESS:..... '||qtd_proc||chr(10)||chr(10));
	end if;

END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/
