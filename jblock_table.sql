#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuarios que estao usando a tabela informada e seus detalhes
#-- Nome do arquivo     : jbusing_table.sql
#-- Data de criação     : 19/11/2014
#-- ---------------------------------------------------------------------------------------------------------#

set lines 100
set serveroutput on size unlimited
set echo off
set feedback off

declare

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(20);
vdatabase varchar2(20);
vvalid number;

vtmps varchar2(2000):=0;
vtmpm varchar2(2000):=0;
vtmph varchar2(2000):=0;
vtmpd varchar2(2000):=0;
vpid varchar2(2000);

begin

  dbms_output.put_line(chr(10)||chr(10)||'LOCK EM TABELAS');

select upper(instance_name) into vinstance from v$instance;
select upper(name) into vdatabase from v$database;

  dbms_output.put_line(JBQB||JBQB||JBQB);

for x in (
   SELECT s.sid, s.last_call_et, s.status, s.username, s.osuser, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine,o.object_name,DECODE ( l.locked_mode, 0, 'None', 1, 'NoLock', 2, 'Row-Share (SS)', 3, 'Row-Exclusive (SX)', 4, 'Share-Table', 5, 'Share-Row-Exclusive (SSX)', 6, 'Exclusive','[Nothing]')   LOCKED_MODE,o.owner,o.object_type,s.serial# serial
   FROM gv$process p, gv$session s,gv$locked_object l, dba_objects o
   WHERE s.username is not null and l.session_id=s.sid and l.object_id=o.object_id and s.last_call_et>600
   group by s.sid, s.serial# , s.last_call_et, s.status, s.username, s.osuser, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine,o.object_name,l.locked_mode,o.owner,o.object_type
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
        dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status,33,'.') || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status,33,'.') || vtmpm
        || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status,33,'.') || vtmph
        || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
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
        dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status,33,'.') || vtmpd
            || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status,33,'.') || vtmpd
        || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line(rpad('TEMPO COM STATUS '||x.status,33,'.') || vtmpd
        || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  end if;

  dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
  dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);

  dbms_output.put_line('INFORMACOES DA TABELA');
  dbms_output.put_line('DONO DA TABELA:.................. ' || x.owner );
  dbms_output.put_line('NOME DA TABELA:.................. ' || x.object_name || JBQB );

  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S USER:........................ ' || x.osuser);
  dbms_output.put_line('SERVIDOR:........................ ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state);
  dbms_output.put_line('TIPO DE LOCK:.................... ' || x.locked_mode );
  if x.sql_hash_value <> 0 then
    dbms_output.put_line(JBQB || 'SQL HASH VALUE:.................. ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v$sql where HASH_VALUE=' || x.sql_hash_value || ';');
  end if;
  dbms_output.put_line('=============================================================================================='||JBQB||JBQB);

end loop;

SELECT nvl(count(sid),0) into vvalid FROM gv$process p, gv$session s
WHERE p.addr =  s.paddr and s.sql_hash_value is not null and s.sql_hash_value <> 0  and s.username is not null and s.status = 'ACTIVE' and audsid != userenv('SESSIONID');


end;
/
