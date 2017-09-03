-- -----------------------------------------------------------------------------------
-- Autor               : johab benicio de oliveira.
-- Descrição           : analisar jobs no banco de dados
-- Nome do arquivo     : jbfail_jobs.sql
-- Data de criação     : 16/03/2017
-- -----------------------------------------------------------------------------------

SET LINES 200;
SET LONG 999;
SET SERVEROUTPUT ON;
SET FEEDBACK OFF;
declare
    VALID varchar2(90);
    INST_NAME varchar2(90);
BEGIN
    SELECT count(*) into VALID FROM DBA_JOBS where BROKEN='N' and FAILURES>0;
    if VALID = 0 then
        DBMS_OUTPUT.PUT_LINE(chr(10)||chr(10)||chr(10)||'Nao existe jobs com falhas no momento.'||chr(10)||chr(10));
    else
        FOR X IN (SELECT JOB,INTERVAL,LOG_USER,TO_CHAR(LAST_DATE,'DD/MM/YYYY HH24:MI:SS') LAST_DATE,TO_CHAR(NEXT_DATE,'DD/MM/YYYY HH24:MI:SS')  NEXT_DATE,WHAT,FAILURES,BROKEN,TOTAL_TIME,INSTANCE
            FROM DBA_JOBS where BROKEN='N' and FAILURES>0 ORDER BY INSTANCE,LAST_DATE,JOB)  LOOP
            DBMS_OUTPUT.PUT_LINE(CHR(10)||'=================================================================');
--            DBMS_OUTPUT.PUT_LINE('INSTANCE:................... '||X.INSTANCE);
            DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB);
            DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.LOG_USER);
            DBMS_OUTPUT.PUT_LINE('PROCEDIMENTO EXECUTADO:..... '||X.WHAT);
            DBMS_OUTPUT.PUT_LINE('BLOQUEADO:.................. '||X.BROKEN);
            DBMS_OUTPUT.PUT_LINE('QUANTIDADE DE FALHAS:....... '||X.FAILURES);
            DBMS_OUTPUT.PUT_LINE('ULTIMA EXECUCAO:............ '||nvl(X.LAST_DATE,'------> Job saiu do estado bloqueado mas ainda nao foi executado. <------' ));
            DBMS_OUTPUT.PUT_LINE('TEMPO TOTAL DA EXECUCAO:.... '||round(X.TOTAL_TIME) || ' segundos.');
            DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_DATE);
            DBMS_OUTPUT.PUT_LINE('INTERVALO:.................. '||X.INTERVAL);

        END LOOP;

        for y in (select distinct value from v$parameter where name like '%dump_dest%' and name not like '%core%' and name not like '%background%') loop
            select value into INST_NAME from v$parameter where name='instance_name';
                DBMS_OUTPUT.PUT_LINE(chr(10)||'ALERT.LOG:.................. '||y.value||'/alert_'||INST_NAME||'.log'||CHR(10));
            end loop;
        end if;
END;
/
