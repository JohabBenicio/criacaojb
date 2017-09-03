


SET LINES 200;
SET LONG 999;
SET SERVEROUTPUT ON;
SET FEEDBACK ON;

declare
JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);
vretorn varchar2(3):='y';
vpe varchar2(10):='n';
vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;
BEGIN
	DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));

select upper(instance_name) into vinstance from v$instance;
select upper(name) into vdatabase from v$database;

	for y in (select * from dba_jobs_running) loop
	FOR X IN (SELECT JOB,LOG_USER,TO_CHAR(LAST_DATE,'DD/MM/YYYY HH24:MI:SS') LAST_DATE,TO_CHAR(NEXT_DATE,'DD/MM/YYYY HH24:MI:SS') NEXT_DATE,WHAT,FAILURES,BROKEN FROM DBA_JOBS
--	where   JOB=y.JOB and job=1329 ORDER BY BROKEN,JOB)  LOOP
where   JOB=y.JOB  ORDER BY BROKEN,JOB)  LOOP
		DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||'=================================================================');
		DBMS_OUTPUT.PUT_LINE('SID:........................ '||Y.SID);
		DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB);
		DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.LOG_USER);
		DBMS_OUTPUT.PUT_LINE('PROCEDIMENTO EXECUTADO:..... '||X.WHAT);
		DBMS_OUTPUT.PUT_LINE('BLOQUEADO:.................. '||X.BROKEN);
		DBMS_OUTPUT.PUT_LINE('QUANTIDADE DE FALHAS:....... '||X.FAILURES);
		DBMS_OUTPUT.PUT_LINE('ULTIMA EXECUCAO:............ '||X.LAST_DATE);
		DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_DATE||CHR(10));

        dbms_output.put_line(JBQB||JBQB||JBQB||JBQB||JBQB||JBQB); 


for xloc in (
  SELECT s.sid, s.serial# serial, s.last_call_et, s.status, s.username, s.osuser, p.spid, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine, s.prev_hash_value
  FROM gv$process p, gv$session s
  WHERE p.addr = s.paddr and s.sid=y.sid and s.program like '%(J00%'
  ORDER BY s.last_call_et asc
)loop

  dbms_output.put_line('INFORMACOES DO BANCO DE DADOS');
  dbms_output.put_line('SID:............................. ' || xloc.sid);
  dbms_output.put_line('SERIAL:.......................... ' || xloc.serial);
  dbms_output.put_line('INSTANCIA:....................... ' || vinstance);
  dbms_output.put_line('BANCO DE DADOS:.................. ' || vdatabase || JBQB);

  dbms_output.put_line('ORACLE USER:..................... ' || xloc.username);
  dbms_output.put_line('STATUS:.......................... ' || xloc.status);
  DBMS_OUTPUT.PUT_LINE('INSTANCE ID:..................... ' || 'NODE ' || xloc.inst_id);
  --dbms_output.put_line(xloc.last_call_et/60/60);
  vtmpm := substr(xloc.last_call_et/60,1,(INSTR(xloc.last_call_et/60,'.'))-1);
  if vtmpm is null then
    vtmpm := substr(xloc.last_call_et/60,1,(INSTR(xloc.last_call_et/60,','))-1);
    if vtmpm is null then
      vtmpm := xloc.last_call_et/60;
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


  if xloc.last_call_et < 86400 then
    if xloc.last_call_et < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || xloc.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif xloc.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpm || ' MINUTO(s) E ' || (xloc.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif xloc.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  elsif xloc.last_call_et > 86400 then
    vtmps:=xloc.last_call_et-(vtmpd*86400);

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
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;
  
  end if;
  
  dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
  dbms_output.put_line('SESSION PROGRAM:................. ' || xloc.program || JBQB);
  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S PID:......................... ' || xloc.spid);
  dbms_output.put_line('O/S USER:........................ ' || xloc.osuser);
  dbms_output.put_line('SERVIDOR:........................ ' || xloc.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || xloc.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || xloc.state || JBQB);
  if xloc.sql_hash_value <> 0 then
    dbms_output.put_line('SQL HASH VALUE ATUAL:............ ' || xloc.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v$sql where HASH_VALUE=' || xloc.sql_hash_value || ';');

      if vretorn='Y' or vretorn='y' then
        for query_loop in (select sql_text from v$sql where HASH_VALUE=xloc.sql_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_text||chr(10));
        end loop;
      end if;

    dbms_output.put_line('=============================================================================================='||JBQB);
  else

    dbms_output.put_line('SQL HASH VALUE ANTIGO:........... ' || xloc.prev_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v$sql where HASH_VALUE=' || xloc.prev_hash_value || ';');

      if vretorn='Y' or vretorn='y' then
        for query_loop in (select sql_text from v$sql where HASH_VALUE=xloc.prev_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_text||chr(10));
        end loop;
      end if;

      if vpe='Y' or vpe='y' then 
        dbms_output.put_line('PLANO(s) DE EXECUCAO CRIADO(s) PARA ESTA QUERY:...');
        for pe in (SELECT distinct PLAN_HASH_VALUE FROM v$sql_plan where HASH_VALUE=xloc.sql_hash_value )LOOP
             dbms_output.put_line(pe.PLAN_HASH_VALUE||', ');  
        END LOOP; 

        dbms_output.put_line(chr(10));

        for pe in (SELECT PLAN_TABLE_OUTPUT FROM TABLE(dbms_xplan.display_cursor(xloc.sql_hash_value)) )LOOP
          dbms_output.put_line(pe.PLAN_TABLE_OUTPUT);  
        END LOOP;  
        dbms_output.put_line(JBQB||JBQB||JBQB||JBQB||JBQB||JBQB); 
      END IF;


dbms_output.put_line('alter system kill session '''||xloc.sid||','||xloc.serial||'''immediate;');
    dbms_output.put_line('=============================================================================================='||JBQB);

  end if;

end loop;


	END LOOP;
END LOOP;




END;
/



select job,LOG_USER,TOTAL_TIME,BROKEN,INSTANCE,SCHEMA_USER,PRIV_USER from DBA_JOBS where job=1329;
