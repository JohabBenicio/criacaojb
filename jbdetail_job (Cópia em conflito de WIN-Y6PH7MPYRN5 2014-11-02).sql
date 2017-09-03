-- -----------------------------------------------------------------------------------
-- AUTOR               : JOHAB BENICIO DE OLIVEIRA.
-- DESCRIÇÃO           : ANALISAR JOBS NO BANCO DE DADOS
-- NOME DO ARQUIVO     : JBDETAIL_JOB.SQL
-- DATA DE CRIAÇÃO     : 30/09/2014
-- -----------------------------------------------------------------------------------

SET LINES 200;
SET LONG 999;
SET SERVEROUTPUT ON;
SET FEEDBACK OFF;
BEGIN
	DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));
	FOR X IN (SELECT JOB,LOG_USER,TO_CHAR(LAST_DATE,'DD/MM/YYYY HH24:MI:SS') LAST_DATE,TO_CHAR(NEXT_DATE,'DD/MM/YYYY HH24:MI:SS') NEXT_DATE,WHAT,FAILURES,BROKEN,INTERVAL 
		FROM DBA_JOBS ORDER BY JOB)  LOOP
		DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||'=================================================================');
		DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB);
		DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.LOG_USER);
		DBMS_OUTPUT.PUT_LINE('PROCEDIMENTO EXECUTADO:..... '||X.WHAT);
		DBMS_OUTPUT.PUT_LINE('BLOQUEADO:.................. '||X.BROKEN);
		DBMS_OUTPUT.PUT_LINE('QUANTIDADE DE FALHAS:....... '||X.FAILURES);
		DBMS_OUTPUT.PUT_LINE('ULTIMA EXECUCAO:............ '||X.LAST_DATE);
		DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_DATE);
		DBMS_OUTPUT.PUT_LINE('INTERVALO DO JOB:........... '||X.INTERVAL||CHR(10));
		DBMS_OUTPUT.PUT_LINE('ACOES:');
		DBMS_OUTPUT.PUT_LINE('EXECUTAR JOB:............... EXEC DBMS_JOB.RUN('||X.JOB||');');
		DBMS_OUTPUT.PUT_LINE('APAGAR JOB:................. EXEC DBMS_JOB.REMOVE('||X.JOB||');');
		IF X.BROKEN = 'N' THEN
			DBMS_OUTPUT.PUT_LINE('DESABILITAR JOB:............ EXEC DBMS_JOB.BROKEN('||X.JOB||', TRUE);');	
		ELSE
			DBMS_OUTPUT.PUT_LINE('HABILITAR JOB:.............. EXEC DBMS_JOB.BROKEN('||X.JOB||', FALSE);');	
		END IF;
		DBMS_OUTPUT.PUT_LINE('ALTERAR INTERVALO:.......... DBMS_JOB.INTERVAL('||X.JOB||', [INTERVALO])');
		
	END LOOP;


	dbms_output.put_line(CHR(10)||CHR(10)||'AUXILIO NOS INTERVALOS:');
	dbms_output.put_line('Extamente quatro dias da ultima execucao:........... ''SYSDATE + 4''');
	dbms_output.put_line('Toda segunda-feira as 13:00:........................ ''NEXT_DAY(TRUNC(SYSDATE), "MONDAY") + 13/24''');
	dbms_output.put_line('Cada meia hora:..................................... ''SYSDATE + 1/48''');
	dbms_output.put_line('Todo dia a meia noite:.............................. ''TRUNC(SYSDATE + 1)''');
	dbms_output.put_line('Todo dia as 03:00:.................................. ''TRUNC(SYSDATE + 1) + 3/24''');
	dbms_output.put_line('Primeiro dia de cada mes a meia noite:.............. ''TRUNC(LAST_DAY(SYSDATE) + 1)''');

	DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10));
END;
/
