





SET SERVEROUTPUT ON
ALTER SESSION SET NLS_DATE_FORMAT='DD-MM-YYYY HH24:MI:SS';
SET LINES 200
set long 999
col SQL_TEXT for a180

DECLARE

V_VAR_QUERY VARCHAR2(30) := '&OWNER_OSUSER_TERMINAL_SID';
V_1DATE varchar2(20);
v_1Y varchar2(10);
v_2Y varchar2(10);
v_3Y varchar2(90);
v_4Y varchar2(90);
JBQB VARCHAR2(2) := CHR(13) || CHR(10);
v_isnt varchar2(10);
vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

BEGIN

select VALUE into v_3Y from v$parameter where NAME like '%user_dump_dest%' ;
select lower(instance_name) into v_isnt from v$instance;

select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into V_1DATE from dual;
dbms_output.put_line( JBQB || JBQB );

FOR X IN ( SELECT INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, SQL_HASH_VALUE, TERMINAL,PROGRAM,LAST_CALL_ET FROM GV$SESSION 
WHERE USERNAME = UPPER(V_VAR_QUERY)  
or (SID = UPPER(V_VAR_QUERY) and USERNAME is not null)  
ORDER BY LAST_CALL_ET ASC
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
DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);

if X.SQL_HASH_VALUE <> 0 then
DBMS_OUTPUT.PUT_LINE('QUERY TEXT:....................... SELECT SQL_TEXT FROM V$SQL WHERE HASH_VALUE=' || X.SQL_HASH_VALUE || ';');
end if;

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


  if x.last_call_et < 86400 then
    if x.last_call_et < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpm || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  elsif x.last_call_et > 86400 then
    vtmps:=x.last_call_et-(vtmpd*86400);

    vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,'.'))-1);
    if vtmpm is null then
      vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,','))-1);
      if vtmpm is null then
        vtmpm := vtmps/60;
      end if;
    end if;
    
    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
    if vtmph is null then
      vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
      if vtmph is null then
        vtmph := vtmpm/60;
      end if;
    end if;
  
    if vtmps < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;
  
  end if;

DBMS_OUTPUT.PUT_LINE('FORMA DE CONEXAO (programa usado):');
  DBMS_OUTPUT.PUT_LINE('SESSION PROGRAM:.................. ' || X.PROGRAM || JBQB);

DBMS_OUTPUT.PUT_LINE('S.O INFORMATION:');
DBMS_OUTPUT.PUT_LINE('PID:.............................. ' || v_4Y);
DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL || JBQB);

DBMS_OUTPUT.PUT_LINE('ATIVAR E DASATIVAR TRACE:');
DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,12,'''');');
DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||X.SID||','||X.SERIAL#||',TRUE,TRUE);'||chr(10));

DBMS_OUTPUT.PUT_LINE('DESATIVAR TRACE................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,0,'''');');
DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||X.SID||','||X.SERIAL#||');'||JBQB);
DBMS_OUTPUT.PUT_LINE('NOME DO TRACE:.................... ' || v_3Y || '/' || v_isnt || '_ora_' || v_4Y || '.trc');
DBMS_OUTPUT.PUT_LINE('HORARIO ATUAL:.................... ' || V_1DATE);
--DBMS_OUTPUT.PUT_LINE('SEGUNDOS:......................... ' || V_1T);
DBMS_OUTPUT.PUT_LINE('========================================================================================================================' || JBQB);
END LOOP;
END LOOP;


EXCEPTION
  WHEN OTHERS THEN
    
    FOR X IN ( SELECT INST_ID, SID, SERIAL#, USERNAME, LOGON_TIME, MACHINE, OSUSER, STATUS, SQL_HASH_VALUE, TERMINAL,PROGRAM,LAST_CALL_ET FROM GV$SESSION 
WHERE USERNAME = UPPER(V_VAR_QUERY)  
or ((TERMINAL = UPPER(V_VAR_QUERY) or TERMINAL = LOWER(V_VAR_QUERY)) and USERNAME is not null)  
or ((UPPER(OSUSER) = UPPER(V_VAR_QUERY) ) and USERNAME is not null)  
ORDER BY LAST_CALL_ET ASC
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
DBMS_OUTPUT.PUT_LINE('LOGON TIME:....................... ' || X.LOGON_TIME);

if X.SQL_HASH_VALUE <> 0 then
DBMS_OUTPUT.PUT_LINE('QUERY TEXT:....................... SELECT SQL_TEXT FROM V$SQL WHERE HASH_VALUE=' || X.SQL_HASH_VALUE || ';');
end if;


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


  if x.last_call_et < 86400 then
    if x.last_call_et < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpm || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  elsif x.last_call_et > 86400 then
    vtmps:=x.last_call_et-(vtmpd*86400);

    vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,'.'))-1);
    if vtmpm is null then
      vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,','))-1);
      if vtmpm is null then
        vtmpm := vtmps/60;
      end if;
    end if;
    
    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
    if vtmph is null then
      vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
      if vtmph is null then
        vtmph := vtmpm/60;
      end if;
    end if;
  
    if vtmps < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:................ ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;
  
  end if;



DBMS_OUTPUT.PUT_LINE('FORMA DE CONEXAO (programa usado):');
  DBMS_OUTPUT.PUT_LINE('SESSION PROGRAM:.................. ' || X.PROGRAM || JBQB);

DBMS_OUTPUT.PUT_LINE('S.O INFORMATION:');
DBMS_OUTPUT.PUT_LINE('PID:.............................. ' || v_4Y);
DBMS_OUTPUT.PUT_LINE('OWNER OF THE S.O:................. ' || X.OSUSER);
DBMS_OUTPUT.PUT_LINE('MACHINE:.......................... ' || X.MACHINE);
DBMS_OUTPUT.PUT_LINE('TERMINAL:......................... ' || X.TERMINAL || JBQB);

DBMS_OUTPUT.PUT_LINE('ATIVAR E DASATIVAR TRACE:');
DBMS_OUTPUT.PUT_LINE('ATIVAR TRACE...................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,12,'''');');
DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||X.SID||','||X.SERIAL#||',TRUE,TRUE);'||chr(10));

DBMS_OUTPUT.PUT_LINE('DESATIVAR TRACE................... EXEC SYS.DBMS_SYSTEM.SET_EV('||X.SID||','||X.SERIAL#||',10046,0,'''');');
DBMS_OUTPUT.PUT_LINE('.................................. EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||X.SID||','||X.SERIAL#||');'||JBQB);
DBMS_OUTPUT.PUT_LINE('NOME DO TRACE:.................... ' || v_3Y || '/' || v_isnt || '_ora_' || v_4Y || '.trc');
DBMS_OUTPUT.PUT_LINE('HORARIO ATUAL:.................... ' || V_1DATE);
--DBMS_OUTPUT.PUT_LINE('SEGUNDOS:......................... ' || V_1T);
DBMS_OUTPUT.PUT_LINE('========================================================================================================================' || JBQB);
END LOOP;
END LOOP;

END;
/
