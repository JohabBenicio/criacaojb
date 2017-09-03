-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Descrição       : Identificar lock e seus detalhes.
-- Data de criação : 01/07/2014
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 200 
Set pages 200
set long 999
set feedback off
col SQL_TEXT for a180

declare

v_1 varchar2(90);
v_2 varchar2(90);
v_3 varchar2(90);
v_4 varchar2(90);
v_5 varchar2(90);
v_6 varchar2(90);
v_4Y numeric(10);
v_TO1 varchar2(90);
v_O2 varchar2(90);
v_O3 varchar2(90);
V_7 varchar2(90);
x1v varchar2(90); 
v_kill varchar2(90);
loop_lock_qtd number(9):=0;
qtd_lock number(9):=0;
v_nome_table varchar2(90):='&NOME_TABELA';

begin


for v_x in (
select s1.sid, s1.serial#, o.OBJECT_NAME
from v$lock l1, v$session s1, GV$LOCKED_OBJECT L, DBA_OBJECTS O 
where s1.sid=l1.sid and L.SESSION_ID=s1.sid and L.OBJECT_ID = O.OBJECT_ID and O.OBJECT_NAME=upper(v_nome_table)
 group by s1.sid,s1.serial#,O.OBJECT_ID ,O.OBJECT_NAME,L.SESSION_ID) loop
		
	select sid, serial#, username, status, osuser, machine, sql_hash_value, inst_id 
	into v_1,v_2,v_3,v_4,v_5,v_6,x1v,v_7
	from gv$session
	where sid = v_x.sid and serial#=v_x.serial#;
			
	select 'alter system kill session '''||v_1||','||v_2||''' immediate;' into v_kill from v$session where sid=v_1;
	
	
	
		dbms_output.put_line('	');
		dbms_output.put_line('+++++++++++++++++++++++++ BLOQUEADOR +++++++++++++++++++++++++++++++ ');
		dbms_output.put_line('DATABASE INFORMATION:');
		dbms_output.put_line('SID:......................... ' || v_1);
		dbms_output.put_line('SERIAL#:..................... ' || v_2);
		dbms_output.put_line('OWNER OF THE DATABASE:....... ' || v_3);
		DBMS_OUTPUT.PUT_LINE('INSTANCE ID:................. ' || 'NODE ' || V_7);
		dbms_output.put_line('STATUS:...................... ' || v_4);
		dbms_output.put_line('	');
		dbms_output.put_line('S.O INFORMATION:');
		dbms_output.put_line('PID:......................... ' || v_4Y);
		dbms_output.put_line('OWNER OF THE S.O:............ ' || v_5);
		dbms_output.put_line('MACHINE:..................... ' || v_6);
		dbms_output.put_line('	');
		dbms_output.put_line('KILL SESSION:');
		dbms_output.put_line(v_kill);
		dbms_output.put_line('	');
		dbms_output.put_line('LOCK INFORMATION:');
		if x1v <> 0 then
		dbms_output.put_line('SQL HASH VALUE:.............. ' || x1v);
		dbms_output.put_line('QUERY TEXT:.................. select sql_text from v$sql where HASH_VALUE=' || x1v || ';');
		dbms_output.put_line('	');
		end if;
		dbms_output.put_line('	');
		dbms_output.put_line('TABLE EM LOCK:::::::::::::' );
		dbms_output.put_line(v_3 || '.' || v_x.OBJECT_NAME );
		
		dbms_output.put_line('	');
		dbms_output.put_line('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ');

		dbms_output.put_line('============================ BLOQUEADO ====================== ');		
		for v_y in (
			select 
				distinct s2.sid 
			from v$lock l1, v$session s1, v$lock l2, v$session s2
			where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 and l1.id1 = l2.id1 and l2.id2 = l2.id2) loop
				
				select SID, SERIAL#, SQL_HASH_VALUE
				into v_1,v_2,x1v 
				from gv$session 
				where SID = v_y.sid;

				dbms_output.put_line('.....   SID:......................... ' || v_1 || ' | SERIAL#:... ' || v_2);
				dbms_output.put_line('.....   QUERY TEXT:.................. select sql_text from v$sql where HASH_VALUE=' || x1v || ';');
				dbms_output.put_line('	');
		end loop;
	
end loop;

exception
	when no_data_found then 
	dbms_output.put_line('	');dbms_output.put_line('	');
	dbms_output.put_line('NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO');
	dbms_output.put_line('	');dbms_output.put_line('	');

end;
/
