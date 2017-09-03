-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Descrição       : Ativar e desativar trace
-- Data de criação : 11/06/2014
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
SET LINES 200
set long 999
col SQL_TEXT for a180

DECLARE
	V_OWNER VARCHAR2(20) := '&OWNER_DB_OR_SO_OR_TERMINAL';
	V_1DATE varchar2(20);
	v_1Y varchar2(10);
	v_2Y varchar2(10);
	v_3Y varchar2(90);
	v_4Y varchar2(90);
	JBQUEBRA VARCHAR2(2) := CHR(13) || CHR(10); -- quebra de linha
BEGIN

	select VALUE into v_3Y from v$parameter where NAME like '%user_dump_dest%' ;
	
	select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into V_1DATE from dual;

	DBMS_OUTPUT.PUT_LINE(JBQUEBRA||JBQUEBRA||JBQUEBRA);

		FOR X IN (
			SELECT 	
				INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, SQL_HASH_VALUE, TERMINAL 
			FROM GV$SESSION 
			WHERE 
			   USERNAME = UPPER(V_OWNER) 
			or ((TERMINAL = UPPER(V_OWNER) or TERMINAL = LOWER(V_OWNER)) and USERNAME is not null) 
			or ((OSUSER = UPPER(V_OWNER) or OSUSER = LOWER(V_OWNER)) and USERNAME is not null) 
			ORDER BY 5 ASC)
			LOOP

			for y in (select distinct spid from gv$process p, gv$session s where p.addr = s.paddr and s.sid  = X.SID) loop
				v_4Y:=y.spid;
				
				DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
				DBMS_OUTPUT.PUT_LINE('DATABASE INFORMATION:');
				DBMS_OUTPUT.PUT_LINE('SID:.............................. ' || X.SID);
				DBMS_OUTPUT.PUT_LINE('SERIAL#:.......................... ' || X.SERIAL#);
				DBMS_OUTPUT.PUT_LINE('OWNER OF THE DATABASE:............ ' || X.USERNAME);
				DBMS_OUTPUT.PUT_LINE('STATUS:........................... ' || X.STATUS);
				DBMS_OUTPUT.PUT_LINE('INSTANCE ID:...................... ' || 'NODE ' || X.INST_ID);
				DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);
				
				if X.SQL_HASH_VALUE <> 0 then
				DBMS_OUTPUT.PUT_LINE('QUERY TEXT:....................... SELECT SQL_TEXT FROM V$SQL WHERE HASH_VALUE=' || X.SQL_HASH_VALUE || ';');
				end if;

				DBMS_OUTPUT.PUT_LINE(JBQUEBRA || 'S.O INFORMATION:');
				DBMS_OUTPUT.PUT_LINE('PID:.............................. ' || v_4Y);
				DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
				DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
				DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL || JBQUEBRA);
				
				DBMS_OUTPUT.PUT_LINE(JBQUEBRA || 'ATIVAR E DASATIVAR TRACE:');
				DBMS_OUTPUT.PUT_LINE('ATUALIZAR NOME DO TRACE:.......... ALTER SESSION SET TRACEFILE_IDENTIFIER='||'''TRACE_'||X.USERNAME||'_'||X.SID||'_'||X.SERIAL#||'.TRC'';'  );
				DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION('||X.SID||','||X.SERIAL#||',TRUE);');
				DBMS_OUTPUT.PUT_LINE('DESATIVAR TRACE................... EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION('||X.SID||','||X.SERIAL#||',FALSE);' || JBQUEBRA);

				DBMS_OUTPUT.PUT_LINE('LOCAL DO TRACE:................... ' || v_3Y);
				DBMS_OUTPUT.PUT_LINE('HORARIO ATUAL:.................... ' || V_1DATE);
				DBMS_OUTPUT.PUT_LINE('========================================================================================================================' || JBQUEBRA || JBQUEBRA);
			END LOOP;
			END LOOP;

	
END;
/