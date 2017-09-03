-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Lista todos os jobs que estao em execucao e seus detalhes.
-- Nome do arquivo     : jbjob_run.sql
-- Data de atualização : 12/05/2016
-- -----------------------------------------------------------------------------------

SET LINES 200;
SET LONG 999;
SET SERVEROUTPUT ON;
SET FEEDBACK OFF;
DECLARE
vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;
vvalid number:=0;
BEGIN
    DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));

    FOR X IN (
        SELECT j.JOB,j.LOG_USER,TO_CHAR(j.LAST_DATE,'DD/MM/YYYY HH24:MI:SS') LAST_DATE,TO_CHAR(j.NEXT_DATE,'DD/MM/YYYY HH24:MI:SS') NEXT_DATE,j.WHAT,j.FAILURES,j.BROKEN,s.LAST_CALL_ET,s.sid,s.serial#,s.status,i.instance_name,i.host_name,s.sql_id,s.sql_hash_value,s.inst_id
        FROM DBA_JOBS j,gv$session s, gv$instance i, dba_jobs_running y
        where j.JOB=y.JOB and y.sid=s.sid and s.inst_id=i.inst_id
        ORDER BY s.last_call_et
    )  LOOP
        vvalid:=x.job;
        DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||rpad('=',100,'='));

        dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,10,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
        dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,10,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name||chr(10) );

        DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB);
        DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.LOG_USER||chr(10));


    vtmpm := substr(x.last_call_et/60,1,(INSTR(x.last_call_et/60,'.'))-1);
    if vtmpm is null then
        vtmpm := substr(x.last_call_et/60,1,(INSTR(x.last_call_et/60,','))-1);
        if vtmpm is null then
            vtmpm := x.last_call_et/60;
        end if;
    end if;

    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
    if vtmph is null then
        vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
        if vtmph is null then
            vtmph := vtmpm/60;
        end if;
    end if;

    vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,'.') )-1 );
    if vtmpd is null then
        vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,',') )-1 );
    end if;

    if x.last_call_et < 60 then
        dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status||':',28,'.') || chr(32) || x.last_call_et || ' SEGUNDO(s)' || chr(10) );
        elsif x.last_call_et < 3600 then
        dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status||':',28,'.') || chr(32) || vtmpm || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || chr(10) );
    elsif x.last_call_et > 3600 then
        dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status||':',28,'.') || chr(32) || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || chr(10) );
    end if;

        DBMS_OUTPUT.PUT_LINE('BLOQUEADO:.................. '||X.BROKEN);
        DBMS_OUTPUT.PUT_LINE('QUANTIDADE DE FALHAS:....... '||X.FAILURES);
        DBMS_OUTPUT.PUT_LINE('ULTIMA EXECUCAO:............ '||X.LAST_DATE);
        DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_DATE);

        DBMS_OUTPUT.PUT_LINE(chr(10)||'KILL SESSION:............... '||chr(10)||'alter system kill session '||chr(39)||x.sid||','||x.serial#||',@'||x.inst_id||chr(39)||' immediate;');

    for tab_z in
    (
        select distinct o.object_type from gv$locked_object l, dba_objects o where l.object_id = o.object_id and l.session_id = x.sid
    ) loop

        dbms_output.put_line(chr(10)||tab_z.object_type || '(s) EM LOCK:::::::::::::' );
        for tab_x in
        (
            select o.object_name,o.owner,
            Decode(l.LOCKED_MODE, 0, 'None',1, 'Null (NULL)',2, 'Row-S (SS)',3, 'Row-X (SX)',4, 'Share (S)',5, 'S/Row-X (SSX)',6, 'Exclusive (X)',l.LOCKED_MODE) LOCKED_MODE from gv$locked_object l, dba_objects o
            where l.object_id = o.object_id and  o.object_type=tab_z.object_type and l.session_id = x.sid
        ) loop
            dbms_output.put_line(rpad(tab_x.owner || '.' || tab_x.object_name||chr(32),50,'-') || '> ' || tab_x.locked_mode);
        end loop;
    end loop;

        DBMS_OUTPUT.PUT_LINE(chr(10)||RPAD('SQL_ID ATUAL:',29,'.')||CHR(32)||LPAD(X.SQL_ID,10,' '));
        DBMS_OUTPUT.PUT_LINE('select sql_fulltext from gv$sql where sql_id='||chr(39)||x.sql_id||chr(39)||chr(59));
        DBMS_OUTPUT.PUT_LINE(chr(10)||RPAD('SQL_HASH_VALUE ATUAL:',29,'.')||CHR(32)||LPAD(X.SQL_HASH_VALUE,10,' '));
        DBMS_OUTPUT.PUT_LINE('select sql_fulltext from gv$sql where hash_value='||x.sql_hash_value||chr(59));
        DBMS_OUTPUT.PUT_LINE(chr(10)||'EXECUCAO DO JOB:............. '||chr(10)||X.WHAT||chr(10));

END LOOP;

    DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||rpad('=+',100,'=+'));
if vvalid > 0 then

    DBMS_OUTPUT.PUT_LINE(chr(10)||'ACOES:');
    DBMS_OUTPUT.PUT_LINE('EXECUTAR JOB:............... EXEC DBMS_JOB.RUN(NOMERO_DO_JOB);');
    DBMS_OUTPUT.PUT_LINE('APAGAR JOB:................. EXEC DBMS_JOB.REMOVE(NOMERO_DO_JOB);');
    DBMS_OUTPUT.PUT_LINE('DESABILITAR JOB:............ EXEC DBMS_JOB.BROKEN(NOMERO_DO_JOB, TRUE);');
    DBMS_OUTPUT.PUT_LINE('HABILITAR JOB:.............. EXEC DBMS_JOB.BROKEN(NOMERO_DO_JOB, FALSE);');
    DBMS_OUTPUT.PUT_LINE('ALTERAR INTERVALO:.......... DBMS_JOB.INTERVAL(NOMERO_DO_JOB, [INTERVALO])');

    dbms_output.put_line(CHR(10)||'AUXILIO NOS INTERVALOS:');
    dbms_output.put_line('Extamente quatro dias da ultima execucao:........... ''SYSDATE + 4''');
    dbms_output.put_line('Toda segunda-feira as 13:00:........................ ''NEXT_DAY(TRUNC(SYSDATE), "MONDAY") + 13/24''');
    dbms_output.put_line('Cada meia hora:..................................... ''SYSDATE + 1/48''');
    dbms_output.put_line('Todo dia a meia noite:.............................. ''TRUNC(SYSDATE + 1)''');
    dbms_output.put_line('Todo dia as 03:00:.................................. ''TRUNC(SYSDATE + 1) + 3/24''');
    dbms_output.put_line('Primeiro dia de cada mes a meia noite:.............. ''TRUNC(LAST_DAY(SYSDATE) + 1)''');

else
DBMS_OUTPUT.PUT_LINE(chr(10)||'Nao existe jobs em execucao nesse momento.');
end if;
    DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10));
END;
/


