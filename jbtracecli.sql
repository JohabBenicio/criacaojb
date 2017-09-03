-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descricao           : Ativar e desativar trace de uma outra sessao
-- Nome do arquivo     : jbtracecli.sql
-- Data de criacao     : 11/06/2014
-- Data de atualização : 28/09/2016
-- -----------------------------------------------------------------------------------
/*
	OWNER_DB_OR_SO_OR_TERMINAL : Informe o nome do usuario que esta conectado no banco de dados, ou nome do usuario que esta conectado no S.O., ou o nome do Terminal.
	TEMPO_DE_CONEXAO_EM_MINUT: Informe o tempo que o usuario conectou (nos ultimos "5" minutos).
*/
SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
SET LINES 200 long 9999
col SQL_TEXT for a180

DECLARE
	V_VAR_QUERY VARCHAR2(30) := '&OWNER_OSUSER_TERMINAL_SID';
	V_1T varchar2(99) := '&TEMPO_DE_CONEXAO_EM_MINUT';
	v_1Y varchar2(10);
	v_2Y varchar2(10);
	v_3Y varchar2(90);
	JBQB VARCHAR2(2) := CHR(13) || CHR(10);
	v_isnt varchar2(10);
	vpid varchar2(100);
BEGIN

	dbms_output.put_line( JBQB || JBQB );
	V_1T:=V_1T*60;

	FOR X IN ( SELECT INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, SQL_HASH_VALUE, TERMINAL,PROGRAM,SQL_ID FROM GV$SESSION
		WHERE USERNAME = UPPER(V_VAR_QUERY) AND LAST_CALL_ET < V_1T
		or (SID = UPPER(V_VAR_QUERY) and USERNAME is not null) AND LAST_CALL_ET < V_1T
		ORDER BY LOGON_TIME ASC
	)LOOP
	select VALUE into v_3Y from gv$parameter where NAME like '%user_dump_dest%' and inst_id=x.inst_id  ;
	select lower(instance_name) into v_isnt from gv$instance where inst_id=x.inst_id;

		DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
		DBMS_OUTPUT.PUT_LINE('DATABASE INFORMATION:');
		DBMS_OUTPUT.PUT_LINE('SID:.............................. ' || X.SID);
		DBMS_OUTPUT.PUT_LINE('SERIAL#:.......................... ' || X.SERIAL#);
		DBMS_OUTPUT.PUT_LINE('OWNER OF THE DATABASE:............ ' || X.USERNAME);
		DBMS_OUTPUT.PUT_LINE('STATUS:........................... ' || X.STATUS);
		DBMS_OUTPUT.PUT_LINE('INSTANCE ID:...................... ' || 'NODE ' || X.INST_ID);
		if X.SQL_HASH_VALUE <> 0 then
			DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);
			DBMS_OUTPUT.PUT_LINE('QUERY TEXT:....................... SELECT SQL_FULLTEXT FROM GV$SQL WHERE SQL_ID=' || X.SQL_ID || ';' || JBQB);
		else
			DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME || JBQB);
		end if;
		DBMS_OUTPUT.PUT_LINE('FORMA DE CONEXAO (programa usado):');
  		DBMS_OUTPUT.PUT_LINE('SESSION PROGRAM:.................. ' || X.PROGRAM || JBQB);
		DBMS_OUTPUT.PUT_LINE('S.O INFORMATION:');
  		for y in ( SELECT p.spid from gv$process p, gv$session s where s.sid=x.sid and s.serial#=x.serial# and p.addr = s.paddr and p.spid is not null) LOOP
  		  if vpid is not null then
  		    vpid:=y.spid ||', '|| vpid;
  		    null;
  		  else
  		    vpid:=y.spid;
  		  end if;
  		END LOOP;
		dbms_output.put_line('PID:.............................. ' || vpid);
		DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
		DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
		DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL || JBQB);
		DBMS_OUTPUT.PUT_LINE('ATIVAR E DASATIVAR TRACE:');
		DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,12,'''');');
		DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||X.SID||','||X.SERIAL#||',TRUE,TRUE);'||chr(10));
		DBMS_OUTPUT.PUT_LINE('DESATIVAR TRACE................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,0,'''');');
		DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||X.SID||','||X.SERIAL#||');'||JBQB);

		DBMS_OUTPUT.PUT_LINE(chr(10)||'NOME DO TRACE:.................... ');
		for y in ( SELECT p.spid from gv$process p, gv$session s where s.sid=x.sid and s.serial#=x.serial# and p.addr = s.paddr and p.spid is not null ) LOOP
		DBMS_OUTPUT.PUT_LINE(v_3Y || '/' || v_isnt || '_ora_' || y.spid || '.trc');
  		END LOOP;

		DBMS_OUTPUT.PUT_LINE('========================================================================================================================' || JBQB);
	END LOOP;

dbms_output.put_line('10046 Trace levels');
dbms_output.put_line('...  0 - Nenhum traco. Como mudar sql_trace off.');
dbms_output.put_line('...  2 - O equivalente a sql_trace regular.');
dbms_output.put_line('...  4 - O mesmo que 2, mas com a adicao de valores de variaveis de ligacao.');
dbms_output.put_line('...  8 - O mesmo que 2, mas com a adicao de eventos de espera.');
dbms_output.put_line('... 12 - O mesmo que 2, mas com tanto vincular os valores das variaveis e eventos de espera.');

EXCEPTION
  WHEN OTHERS THEN

    FOR X IN ( SELECT INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, SQL_HASH_VALUE, TERMINAL,PROGRAM,SQL_ID FROM GV$SESSION
		WHERE USERNAME = UPPER(V_VAR_QUERY) AND LAST_CALL_ET < V_1T
		or ((TERMINAL = UPPER(V_VAR_QUERY) or TERMINAL = LOWER(V_VAR_QUERY)) and USERNAME is not null) AND LAST_CALL_ET < V_1T
		or ((UPPER(OSUSER) = UPPER(V_VAR_QUERY) ) and USERNAME is not null) AND LAST_CALL_ET < V_1T
		ORDER BY LOGON_TIME ASC
	)LOOP
		select VALUE into v_3Y from gv$parameter where NAME like '%user_dump_dest%' and inst_id=x.inst_id  ;
		select lower(instance_name) into v_isnt from gv$instance where inst_id=x.inst_id;
		DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
		DBMS_OUTPUT.PUT_LINE('DATABASE INFORMATION:');
		DBMS_OUTPUT.PUT_LINE('SID:.............................. ' || X.SID);
		DBMS_OUTPUT.PUT_LINE('SERIAL#:.......................... ' || X.SERIAL#);
		DBMS_OUTPUT.PUT_LINE('OWNER OF THE DATABASE:............ ' || X.USERNAME);
		DBMS_OUTPUT.PUT_LINE('STATUS:........................... ' || X.STATUS);
		DBMS_OUTPUT.PUT_LINE('INSTANCE ID:...................... ' || 'NODE ' || X.INST_ID);
		if X.SQL_HASH_VALUE <> 0 then
			DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);
			DBMS_OUTPUT.PUT_LINE('QUERY TEXT:....................... SELECT SQL_FULLTEXT FROM GV$SQL WHERE SQL_ID=' || X.SQL_ID || ';' || JBQB);
		else
			DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME || JBQB);
		end if;
		DBMS_OUTPUT.PUT_LINE('FORMA DE CONEXAO (programa usado):');
  		DBMS_OUTPUT.PUT_LINE('SESSION PROGRAM:.................. ' || X.PROGRAM || JBQB);
		DBMS_OUTPUT.PUT_LINE('S.O INFORMATION:');
		for y in ( SELECT p.spid from gv$process p, gv$session s where s.sid=x.sid and s.serial#=x.serial# and p.addr = s.paddr and p.spid is not null) LOOP
  		  if vpid is not null then
  		    vpid:=y.spid ||', '|| vpid;
  		    null;
  		  else
  		    vpid:=y.spid;
  		  end if;
  		END LOOP;
		dbms_output.put_line('PID:.............................. ' || vpid);
		DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
		DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
		DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL || JBQB);
		DBMS_OUTPUT.PUT_LINE('ATIVAR E DASATIVAR TRACE:');
		DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,12,'''');');
		DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||X.SID||','||X.SERIAL#||',TRUE,TRUE);'||chr(10));
		DBMS_OUTPUT.PUT_LINE('DESATIVAR TRACE................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,0,'''');');
		DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||X.SID||','||X.SERIAL#||');'||JBQB);
		DBMS_OUTPUT.PUT_LINE(chr(10)||'NOME DO TRACE:.................... ');
		for y in ( SELECT p.spid from gv$process p, gv$session s where s.sid=x.sid and s.serial#=x.serial# and p.addr = s.paddr and p.spid is not null ) LOOP
			DBMS_OUTPUT.PUT_LINE(v_3Y || '/' || v_isnt || '_ora_' || y.spid || '.trc');
  		END LOOP;
		DBMS_OUTPUT.PUT_LINE('========================================================================================================================' || JBQB);
		END LOOP;
END;
/
