#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer detalhes de uma sessão
#-- Nome do arquivo     : jbdetail_session.sql
#-- Data de criação     : 26/01/2015
#-- Data de atualização : 29/04/2015
#-- ---------------------------------------------------------------------------------------------------------#

set lines 180 pages 999 long 9999999
set serveroutput on
set echo off

declare

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);
vsid varchar2(10):=&sid;
vretorn varchar2(3):='&RETORN_QUERY_TEXT_Y_N';
vpe varchar2(10):='&PLANO_EXEC_Y_N';


vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin

select upper(instance_name) into vinstance from v$instance;
select upper(name) into vdatabase from v$database;

  dbms_output.put_line(JBQB);

for x in (
  SELECT s.sid, s.serial# serial, s.last_call_et, s.status, s.username, s.osuser, p.spid, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine, s.prev_hash_value
  FROM gv$process p, gv$session s
  WHERE p.addr = s.paddr and s.sid=vsid
  ORDER BY s.last_call_et asc
)loop

  dbms_output.put_line('INFORMACOES DO BANCO DE DADOS');
  dbms_output.put_line('SID:............................. ' || x.sid);
  dbms_output.put_line('SERIAL:.......................... ' || x.serial);
  dbms_output.put_line('INSTANCIA:....................... ' || vinstance);
  dbms_output.put_line('BANCO DE DADOS:.................. ' || vdatabase || JBQB);

  dbms_output.put_line('ORACLE USER:..................... ' || x.username);
  dbms_output.put_line('STATUS:.......................... ' || x.status);
  DBMS_OUTPUT.PUT_LINE('INSTANCE ID:..................... ' || 'NODE ' || x.inst_id);
  --dbms_output.put_line(x.last_call_et/60/60);
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
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpm || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
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
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  end if;

  dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
  dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);
  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S PID:......................... ' || x.spid);
  dbms_output.put_line('O/S USER:........................ ' || x.osuser);
  dbms_output.put_line('SERVIDOR:........................ ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state || JBQB);
  if x.sql_hash_value <> 0 then
    dbms_output.put_line('SQL HASH VALUE ATUAL:............ ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_fulltext from v$sql where HASH_VALUE=' || x.sql_hash_value || ';');

      if vretorn='Y' or vretorn='y' then
        for query_loop in (select sql_fulltext from v$sql where HASH_VALUE=x.sql_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_fulltext||chr(10));
        end loop;
      end if;

    dbms_output.put_line('=============================================================================================='||JBQB);
  else

    dbms_output.put_line('SQL HASH VALUE ANTIGO:........... ' || x.prev_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_fulltext from v$sql where HASH_VALUE=' || x.prev_hash_value || ';');

      if vretorn='Y' or vretorn='y' then
        for query_loop in (select sql_fulltext from v$sql where HASH_VALUE=x.prev_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_fulltext||chr(10));
        end loop;
      end if;

      if vpe='Y' or vpe='y' then
        dbms_output.put_line('PLANO(s) DE EXECUCAO CRIADO(s) PARA ESTA QUERY:...');
        for pe in (SELECT distinct PLAN_HASH_VALUE FROM v$sql_plan where HASH_VALUE=x.sql_hash_value )LOOP
             dbms_output.put_line(pe.PLAN_HASH_VALUE||', ');
        END LOOP;

        dbms_output.put_line(chr(10));

        for pe in (SELECT PLAN_TABLE_OUTPUT FROM TABLE(dbms_xplan.display_cursor(x.sql_hash_value)) )LOOP
          dbms_output.put_line(pe.PLAN_TABLE_OUTPUT);
        END LOOP;
        dbms_output.put_line(JBQB||JBQB||JBQB||JBQB||JBQB||JBQB);
      END IF;

    dbms_output.put_line('=============================================================================================='||JBQB);

  end if;

end loop;


SELECT nvl(count(sid),0) into vvalid
  FROM gv$process p, gv$session s
  WHERE p.addr = s.paddr and s.sid=vsid;


if vvalid = 0 then
  dbms_output.put_line(JBQB);
  dbms_output.put_line('NESTE MOMENTO ESTA SESSAO NAO ESTA EXECUTANDO NADA NO BANCO DE DADOS.');
  dbms_output.put_line(JBQB);
end if;


end;
/
