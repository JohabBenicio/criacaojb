-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- Descrição       : Ativar e desativar trace
-- Data de criação : 19/05/2014
-- -----------------------------------------------------------------------------------


SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
SET LINES 200
set long 999
col SQL_TEXT for a180

DECLARE

	V_1DATE varchar2(20);
	v_1Y varchar2(10);
	v_2Y varchar2(10);
	v_3Y varchar2(90);
	v_4Y varchar2(90);
BEGIN


	select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into V_1DATE from dual;

		select sid,serial# into v_1Y,v_2Y from v$session where sid=(select distinct sid from v$mystat);

		FOR X IN (SELECT INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, TERMINAL FROM GV$SESSION WHERE SID=v_1Y and SERIAL#=v_2Y ORDER BY 5 ASC)
			LOOP

				select spid into v_4Y from gv$process p, gv$session s where p.addr = s.paddr and   s.sid  = X.SID;

				DBMS_OUTPUT.PUT_LINE('	');
				DBMS_OUTPUT.PUT_LINE('	');
				DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
				DBMS_OUTPUT.PUT_LINE('DATABASE INFORMATION:');
				DBMS_OUTPUT.PUT_LINE('SID:.............................. ' || X.SID);
				DBMS_OUTPUT.PUT_LINE('SERIAL#:.......................... ' || X.SERIAL#);
				DBMS_OUTPUT.PUT_LINE('OWNER OF THE DATABASE:............ ' || X.USERNAME);
				DBMS_OUTPUT.PUT_LINE('INSTANCE ID:...................... ' || 'NODE ' || X.INST_ID);
				DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);
				DBMS_OUTPUT.PUT_LINE('	');
				DBMS_OUTPUT.PUT_LINE('S.O INFORMATION:');
				DBMS_OUTPUT.PUT_LINE('PID:.............................. ' || v_4Y);
				DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
				DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
				DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL);
				DBMS_OUTPUT.PUT_LINE('	');
				DBMS_OUTPUT.PUT_LINE('ATIVAR E DASATIVAR TRACE:');
				DBMS_OUTPUT.PUT_LINE('ATUALIZAR NOME DO TRACE:.......... ALTER SESSION SET TRACEFILE_IDENTIFIER='||'''TRACE_'||X.USERNAME||'_'||X.SID||'_'||X.SERIAL#||'.TRC'';'  );
				DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION('||X.SID||','||X.SERIAL#||',TRUE);');
				DBMS_OUTPUT.PUT_LINE('DESATIVAR TRACE................... EXEC SYS.DBMS_SYSTEM.SET_SQL_TRACE_IN_SESSION('||X.SID||','||X.SERIAL#||',FALSE);');
				DBMS_OUTPUT.PUT_LINE('	');
				DBMS_OUTPUT.PUT_LINE('LOCAL DO TRACE:................... ' || v_3Y);
				DBMS_OUTPUT.PUT_LINE('HORARIO ATUAL:.................... ' || V_1DATE);
--				DBMS_OUTPUT.PUT_LINE('SEGUNDOS:......................... ' || V_1T);
				DBMS_OUTPUT.PUT_LINE('========================================================================================================================');
			END LOOP;


END;
/