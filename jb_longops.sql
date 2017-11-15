

set lines 200 pages 999 long 99999 feed off
set serveroutput on size unlimited
declare
	len_1 number;
	len_2 number;
	len_3 number;
	v_user varchar2(90):='SYS';
	len_f number;
	v_show_comman varchar2(1):='N';
	v_comand long;
	valid number;
	vdata varchar2(20);
begin

SELECT count(*) into valid
FROM   gv$session s,
       gv$session_longops sl,
       gv$instance i
WHERE  s.sid      = sl.sid
AND    s.serial#  = sl.serial#
and    s.inst_id  = sl.inst_id
and    s.inst_id  = i.inst_id
AND    SOFAR      <>   TOTALWORK
--and    sl.elapsed_seconds > 10
and    s.username = v_user;

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into vdata from dual;
dbms_output.put_line(chr(10)||'HORARIO DA ANALISE: '||vdata||chr(10));

if valid > 0 then

	dbms_output.put_line(rpad('+',100,'+')||chr(10));

	for x in (SELECT s.sid,
		  s.serial#,
		  s.osuser,
		  s.machine,
		  s.inst_id,
		  s.terminal,
		  s.event,
		  s.username,
		  s.status,
		  s.program,
		  ROUND(sl.elapsed_seconds/60) || ':' || MOD(sl.elapsed_seconds,60) elapsed,
		  nvl(ROUND(sl.time_remaining/60),00) || ':' || nvl(MOD(sl.time_remaining,60),00) temp_restante,
		  ROUND(sl.sofar/sl.totalwork*100, 2) progress_pct,
		  sl.sofar,
		  sl.totalwork,
		  s.sql_id,
		  sl.MESSAGE,
		  i.instance_name,
		  i.host_name
		FROM   gv$session s,
		       gv$session_longops sl,
		       gv$instance i
		WHERE  s.sid      = sl.sid
		AND    s.serial#  = sl.serial#
		and    s.inst_id  = sl.inst_id
		and    s.inst_id  = i.inst_id
		AND    SOFAR      <>   TOTALWORK
		and    s.username = v_user
		--and    sl.elapsed_seconds > 10
		order by progress_pct
	) LOOP

		len_1:=length(x.username);
		len_2:=length(x.sid);
		len_3:=length(x.instance_name);

		if len_1 > len_2 and len_1 > len_3 then
			len_f:=len_1;
		elsif len_2 > len_1 and len_2 > len_3 then
			len_f:=len_2;
		else
			len_f:=len_3;
		end if;

		dbms_output.put_line('INFORMACAO DO BANCO DE DADOS:');
		dbms_output.put_line(rpad('USUARIO D.B.:',29,'.')||chr(32)||lpad(x.username,len_f,' ')||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
		dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,len_f,' ')||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
		dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,len_f,' ')||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name);
		dbms_output.put_line(rpad('EVENTO DE ESPERA:',29,'.')||chr(32)||x.event||chr(10));

		dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
		dbms_output.put_line(rpad('SESSION PROGRAM:',29,'.')||chr(32)||x.program||chr(10));

		dbms_output.put_line('INFORMACAO DO S.O.:');
		dbms_output.put_line(rpad('USUARIO S.O.:',29,'.')||chr(32)||x.osuser);
		dbms_output.put_line(rpad('MAQUINA:',29,'.')||chr(32)||x.machine );
		dbms_output.put_line(rpad('TERMINAL:',29,'.')||chr(32)||x.terminal||chr(10));

		dbms_output.put_line('INFORMACAO DO PROCESSO:');
		dbms_output.put_line(rpad('SQL_ID:',29,'.')||chr(32)||x.sql_id);
		dbms_output.put_line(rpad('TEMPO PERCORRIDO:',29,'.')||chr(32)||x.elapsed);
		dbms_output.put_line(rpad('TEMPO RESTANTE:',29,'.')||chr(32)||x.temp_restante);
		dbms_output.put_line(rpad('PORCENTAGEM DO PROCESSO:',29,'.')||chr(32)||x.progress_pct||'%');
		dbms_output.put_line(rpad('MESSAGE - LONGOPS:',29,'.')||chr(32)||x.message);


		if upper(v_show_comman) = 'S' or upper(v_show_comman) = 'Y' then
			dbms_output.put_line(chr(10)||'COMANDO EXECUTADO');

			select sql_fulltext into v_comand from gv$sql where sql_id=x.sql_id and inst_id=x.inst_id;

			dbms_output.put_line(v_comand);

		end if;

		dbms_output.put_line(chr(10)||rpad('+',100,'+')||chr(10));

	END LOOP;

else
	len_f:=length('NAO EXISTE SESSOES DO USUARIO '||chr(34)||v_user||chr(34)||' PROCESSANDO');
	dbms_output.put_line('- '||rpad('-',len_f,'-')||' -');
	dbms_output.put_line('- NAO EXISTE SESSOES DO USUARIO '||chr(34)||v_user||chr(34)||' PROCESSANDO -');
	dbms_output.put_line('- '||rpad('-',len_f,'-')||' -');
end if;

select count(*) into valid from gv$session where username=v_user;

if valid > 0 then
	dbms_output.put_line(chr(10)||chr(10));
	dbms_output.put_line('INSTANCE'||chr(32)||'USERNAME'||chr(32)||rpad('SID',8,' ') ||chr(32)||rpad('OSUSER',12,' ') ||chr(32)||rpad('MAQUINA',20,' ')||chr(32)||rpad('STATUS',8,' ') ||chr(32)||rpad('SQL_ID',14,' ') ||chr(32)||'LAST_CALL_ET');
	dbms_output.put_line('--------'||chr(32)||'--------'||chr(32)||rpad('---',8,'-') ||chr(32)||rpad('-------',12,'-')||chr(32)||rpad('-------',20,'-')||chr(32)||rpad('-------',8,'-')||chr(32)||rpad('-------',14,'-')||chr(32)||'------------');

	for x in (select sid,username,osuser,machine,status,last_call_et,inst_id,nvl(sql_id,' ') sql_id from gv$session where username=v_user and ((osuser ='dgbraque' and sql_id is not null) or osuser !='dgbraque') and status!='KILLED' and osuser!='oracle') loop
		dbms_output.put_line(rpad(x.inst_id,8,' ')||chr(32)||rpad(x.username,8,' ')||chr(32)||rpad(x.sid,8,' ')||chr(32)||rpad(x.osuser,12,' ')||chr(32)||rpad(x.machine,20,' ')||chr(32)||rpad(x.status,8,' ')||chr(32)||rpad(x.sql_id,14,' ')||chr(32)||x.last_call_et);
	end loop;
	dbms_output.put_line(chr(10)||chr(10));
end if;

end;
/


