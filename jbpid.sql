-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Trazer dados de sessões com PID
-- Nome do arquivo     : jbpid.sql
-- Data de criação     : 02/04/2014
-- Data de atualização : 27/08/2014
-- -----------------------------------------------------------------------------------

SELECT sess.process, sess.status, sess.username, sess.schemaname, sql.sql_text, OSUSER, sql.elapsed_time / 1000000 as TEMPO_DE_EXECUCAO_SQL
  FROM v$session sess,
       v$sql     sql
 WHERE sql.hash_value=2018244575 and sess.sql_hash_value=2018244575
 ORDER BY sql.elapsed_time DESC;


set serveroutput on
set lines 200 long 9999 pages 2000
col sql_fulltext for a200

declare
v_pid varchar2(90):='&PID'||',';
v_pid2 varchar2(90);
v_virgula number(15);
v_sid varchar2(90);
v_osuser varchar2(90);
v_machine varchar2(90);
v_SQL_HASH_VALUE  varchar2(90);
v_serial varchar2(90);
v_username varchar2(90);
v_status varchar2(90);
v_last_call_et varchar2(90);
v_spid varchar2(2000);
v_sql_id varchar2(90);

JBQB VARCHAR2(2) := CHR(13) || CHR(10);

begin

dbms_output.put_line(v_pid);
	loop
		v_virgula := instr( v_pid, ',' );
		exit when nvl(v_virgula, 0 ) = 0;
		v_pid2 := rtrim( ltrim( substr( v_pid, 1, v_virgula-1) ) );
		v_pid  := substr( v_pid, v_virgula+1 );

		begin

			select s.sid,s.osuser,s.machine,s.SQL_HASH_VALUE,s.serial#,s.username,s.status,s.last_call_et,p.spid,s.sql_id
			into v_sid,v_osuser,v_machine,v_SQL_HASH_VALUE,v_serial,v_username,v_status,v_last_call_et,v_spid,v_sql_id
			from v$process p, v$session s where s.paddr = p.addr and p.spid = v_pid2;

			dbms_output.put_line('	');
			dbms_output.put_line('	');
			dbms_output.put_line('=================================================================================');
			dbms_output.put_line('DATABASE INFORMATION:');
			dbms_output.put_line('SID:.............................. ' || v_sid);
			dbms_output.put_line('SERIAL#:.......................... ' || v_serial);
			dbms_output.put_line('OWNER OF THE DATABASE:............ ' || v_username);
			dbms_output.put_line('STATUS:........................... ' || v_status || JBQB);

			dbms_output.put_line('S.O INFORMATION:');
			dbms_output.put_line('PID:.............................. ' || v_spid);
			dbms_output.put_line('OWNER OF THE S.O:................. ' || v_osuser);
			dbms_output.put_line('MACHINE:.......................... ' || v_machine || JBQB);

			if v_SQL_HASH_VALUE <> 0 then
			dbms_output.put_line('QUERY INFORMATION:');
			dbms_output.put_line('SQL HASH VALUE:................... ' || v_SQL_HASH_VALUE);
			dbms_output.put_line('QUERY TEXT:....................... '||chr(10)||'select sql_fulltext from v$sql where sql_id=' || chr(39) || v_sql_id || chr(39) || ';' || JBQB);

			dbms_output.put_line('KILL SESSION:');
			dbms_output.put_line('--   alter system kill session '''||v_sid||','||v_serial||''' immediate;');

			dbms_output.put_line(JBQB);

--			for sql in (select elapsed_time from v$sql where hash_value=v_SQL_HASH_VALUE )loop
--			end loop;

			else
				dbms_output.put_line(JBQB || 'ESTA SESSAO NAO ESTA EXECUTANDO NENHUM PROCESSO NO BANCO DE DADOS');

			end if;

			dbms_output.put_line( JBQB || '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++');

		exception
			when no_data_found then
			DBMS_OUTPUT.PUT_LINE( JBQB || 'PID NAO EXISTE MAIS NO BANCO DE DADOS' );

		end;
	end loop;


end;
/
