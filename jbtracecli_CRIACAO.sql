-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Descricao       : Ativar e desativar trace
-- Data de criacao : 11/06/2014
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
SET LINES 200
set long 999
col SQL_TEXT for a180

DECLARE
	V_OWNER VARCHAR2(20) := '&OWNER_DB_OR_SO_OR_TERMINAL';
	V_1T NUMERIC(12) := '&TEMPO_DE_CONEXAO_EM_MINUT';
	V_1DATE varchar2(20);
	v_1Y varchar2(10);
	v_2Y varchar2(10);
	v_3Y varchar2(90);
	v_4Y varchar2(90);
	JBQB VARCHAR2(2) := CHR(13) || CHR(10);
	v_isnt varchar2(10);
BEGIN

	select VALUE into v_3Y from v$parameter where NAME like '%user_dump_dest%' ;
	select instance_name into v_isnt from v$instance;
	
	select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into V_1DATE from dual;
	dbms_output.put_line( JBQB || JBQB );
	V_1T:=V_1T*60;
		
		FOR X IN (
			SELECT 	
				INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, SQL_HASH_VALUE, TERMINAL 
			FROM GV$SESSION 
			WHERE 
			   USERNAME = UPPER(V_OWNER) AND LAST_CALL_ET < V_1T 
			or ((TERMINAL = UPPER(V_OWNER) or TERMINAL = LOWER(V_OWNER)) and USERNAME is not null) AND LAST_CALL_ET < V_1T 
			or ((OSUSER = UPPER(V_OWNER) or OSUSER = LOWER(V_OWNER)) and USERNAME is not null) AND LAST_CALL_ET < V_1T 
			ORDER BY 5 ASC
		)LOOP

			for y in (select distinct spid from gv$process p, gv$session s where p.addr = s.paddr and s.sid  = X.SID) loop
				v_4Y:=y.spid;
				
				DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
				DBMS_OUTPUT.PUT_LINE('DATABASE INFORMATION:');
				DBMS_OUTPUT.PUT_LINE('SID:.............................. ' || X.SID);
				DBMS_OUTPUT.PUT_LINE('SERIAL#:.......................... ' || X.SERIAL#);
				DBMS_OUTPUT.PUT_LINE('OWNER OF THE DATABASE:............ ' || X.USERNAME);
				DBMS_OUTPUT.PUT_LINE('STATUS:........................... ' || X.STATUS);
				DBMS_OUTPUT.PUT_LINE('INSTANCE ID:...................... ' || 'NODE ' || X.INST_ID);
				
				if X.SQL_HASH_VALUE <> 0 then
				DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);
				DBMS_OUTPUT.PUT_LINE('QUERY TEXT:....................... SELECT SQL_TEXT FROM V$SQL WHERE HASH_VALUE=' || X.SQL_HASH_VALUE || ';' || JBQB);
				else
				DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME || JBQB);
				end if;
				
				DBMS_OUTPUT.PUT_LINE('S.O INFORMATION:');
				DBMS_OUTPUT.PUT_LINE('PID:.............................. ' || v_4Y);
				DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
				DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
				DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL || JBQB);

				DBMS_OUTPUT.PUT_LINE('ATIVAR E DASATIVAR TRACE:');
				DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,12,'''');');
				DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,0,'''');' || JBQB);
				DBMS_OUTPUT.PUT_LINE('NOME DO TRACE:.................... ' || v_3Y || '/' || v_isnt || '_ora_' || v_4Y || '.trc');
				DBMS_OUTPUT.PUT_LINE('HORARIO ATUAL:.................... ' || V_1DATE);
--				DBMS_OUTPUT.PUT_LINE('SEGUNDOS:......................... ' || V_1T);
				DBMS_OUTPUT.PUT_LINE('========================================================================================================================' || JBQB);
			END LOOP;
		END LOOP;

dbms_output.put_line('10046 Trace levels');
dbms_output.put_line('...0 - Nenhum traco. Como mudar sql_trace off.');
dbms_output.put_line('...2 - O equivalente a sql_trace regular.');
dbms_output.put_line('...4 - O mesmo que 2, mas com a adicao de valores de variaveis de ligacao.');
dbms_output.put_line('...8 - O mesmo que 2, mas com a adicao de eventos de espera.');
dbms_output.put_line('...12 - O mesmo que 2, mas com tanto vincular os valores das variaveis e eventos de espera.');

END;
/