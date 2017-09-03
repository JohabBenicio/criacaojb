
-- -----------------------------------------------------------------------------------
-- Autor           : Johab Benicio de Oliveira.
-- File            : jbdupasm_stand.sql
-- -----------------------------------------------------------------------------------

set serveroutput on
set pages 100 lines 200 long 200

DECLARE

V_DIRETORIO VARCHAR2(90):= '&LOCAL_ASM';
V_TAMANHO_REDO NUMBER(4);
V_MAX_MEMBER VARCHAR2(90);
V_MAX_MEMBER2 VARCHAR2(90);
V_MAX_GROUP NUMBER(3);

V_MEMBER VARCHAR2(90);
V_CONTAGEM_REDO number(2);
V_CONTAGEM_MEMBER NUMBER(2);

BEGIN

	DBMS_OUTPUT.PUT_LINE('	');
	DBMS_OUTPUT.PUT_LINE('	');
	DBMS_OUTPUT.PUT_LINE('RUN{ ');
	DBMS_OUTPUT.PUT_LINE('     ALLOCATE AUXILIARY CHANNEL NEWDB1 DEVICE TYPE DISK;');

		FOR X IN (SELECT  FILE_ID, TABLESPACE_NAME FROM DBA_DATA_FILES order by 1) LOOP
			DBMS_OUTPUT.PUT_LINE('  SET NEWNAME FOR DATAFILE ' || X.FILE_ID || ' TO ''' || V_DIRETORIO || ''';');
		END LOOP;
	   
		FOR X IN (SELECT  FILE_ID, TABLESPACE_NAME FROM DBA_TEMP_FILES order by 1) LOOP
			DBMS_OUTPUT.PUT_LINE('  SET NEWNAME FOR TEMPFILE ' || X.FILE_ID || ' TO ''' || V_DIRETORIO || ''';');
		END LOOP;

		DBMS_OUTPUT.PUT_LINE('  DUPLICATE TARGET DATABASE FOR STANDBY;');
			   
	DBMS_OUTPUT.PUT_LINE('}');

END;
/
