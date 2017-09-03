-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Descrição       : Identificar query mais antiga.
-- Data de criação : 22/07/2014
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 200 
Set pages 200
set long 999
set feedback off
col SQL_TEXT for a180
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

declare

v_1 varchar2(90);
v_2 varchar2(90);
v_3 varchar2(90);
v_4 varchar2(90);
v_5 varchar2(90);
v_6 varchar2(90);
V_7 varchar2(90);
v_4Y numeric(10);
x1v varchar2(90); 
v_tem varchar2(20); 

begin

select sl.sid,sl.serial#,sl.ELAPSED_SECONDS,s.username, s.status, s.osuser, s.machine, s.sql_hash_value, s.inst_id
into v_1,v_2,v_tem,v_3,v_4,v_5,v_6,x1v,v_7
from gv$session_longops sl, gv$session s 
where sl.sid=s.sid and 
	sl.serial#=s.serial# and 
	sl.TIME_REMAINING != 0 and 
	sl.ELAPSED_SECONDS >= (select max(ELAPSED_SECONDS) from gv$session_longops where TIME_REMAINING != 0);
	
		dbms_output.put_line('	');
		dbms_output.put_line('+++++++++++++++++++++++++ QUERY MAIS ANTIGA +++++++++++++++++++++++++++++++ ');
		dbms_output.put_line('DATABASE INFORMATION:');
		dbms_output.put_line('SID:............................ ' || v_1);
		dbms_output.put_line('SERIAL#:........................ ' || v_2);
		dbms_output.put_line('OWNER OF THE DATABASE:.......... ' || v_3);
		DBMS_OUTPUT.PUT_LINE('INSTANCE ID:.................... ' || 'NODE ' || V_7);
		dbms_output.put_line('STATUS:......................... ' || v_4);
		dbms_output.put_line('TEMPO DE EXECUCAO EM SEGUNDOS:.. ' || v_tem);
		dbms_output.put_line('	');
		dbms_output.put_line('S.O INFORMATION:');
		dbms_output.put_line('PID:............................ ' || v_4Y);
		dbms_output.put_line('OWNER OF THE S.O:............... ' || v_5);
		dbms_output.put_line('MACHINE:........................ ' || v_6);
		dbms_output.put_line('	');
		dbms_output.put_line('SQL HASH VALUE:................. ' || x1v);
		dbms_output.put_line('QUERY TEXT:..................... select sql_text from v$sql where HASH_VALUE=' || x1v || ';');
		dbms_output.put_line('	');

		dbms_output.put_line('	');
		dbms_output.put_line('+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ');

exception
	when no_data_found then 
	dbms_output.put_line('	');dbms_output.put_line('	');
	dbms_output.put_line('Nada encontrado.');
	dbms_output.put_line('	');dbms_output.put_line('	');
	
end;
/
set lines 100
