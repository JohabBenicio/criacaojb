#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuario(s) ativos e seu tempo de atividade junto com detalhes de sua sessão
#-- Nome do arquivo     : jbsess_usin_time.sql
#-- Data de criação     : 01/09/2014
#-- ---------------------------------------------------------------------------------------------------------#



set lines 200
set serveroutput on

declare 

jbqb varchar2(2) := chr(13) || chr(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);

vmemoryg varchar2(100):=0;
vmemorym varchar2(100):=0;
vmemoryk varchar2(100):=0;
vmemoryb varchar2(100):=0;
vmemory varchar2(100):=0;

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0; 

begin

select upper(instance_name) into vinstance from v$instance;
select upper(name) into vdatabase from v$database;

  dbms_output.put_line(JBQB||JBQB||JBQB);

for x in (
  SELECT s.sid, s.serial# serial,sql_id, s.last_call_et, s.status, s.username, s.osuser, p.spid, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine
  FROM gv$process p, gv$session s
  WHERE p.addr = s.paddr and s.sql_hash_value != 0  and s.username is not null and audsid != userenv('SESSIONID')
  ORDER BY s.last_call_et asc
)loop

--# ---------------------------------------------------------------------------------------#
--# CALCULO TEMPO USADO
--# ---------------------------------------------------------------------------------------#

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


--# ---------------------------------------------------------------------------------------#
--# CALCULO MEMORIA USADA
--# ---------------------------------------------------------------------------------------#

  select runtime_mem into vmemoryb from gv$sql where sql_id=x.sql_id;

  vmemoryg := substr(vmemoryb/1024/1024/1024,1,(INSTR(vmemoryb/1024/1024/1024,'.'))-1);
  if vmemoryg is null then
    vmemoryg := substr(vmemoryb/1024/1024/1024,1,(INSTR(vmemoryb/1024/1024/1024,','))-1);
    if vmemoryg is null then
      vmemoryg := vmemoryb/1024/1024/1024;
    end if;
  end if;
  vmemorym := substr(vmemoryb/1024/1024,1,(INSTR(vmemoryb/1024/1024,'.'))-1);
  if vmemorym is null then
    vmemorym := substr(vmemoryb/1024/1024,1,(INSTR(vmemoryb/1024/1024,'.'))-1);
    if vmemorym is null then
      vmemorym := vmemoryb/1024/1024;
    end if;
  end if;
  vmemoryk := substr(vmemoryb/1024,1,(INSTR(vmemoryb/1024,'.'))-1);
  if vmemoryk is null then
    vmemoryk := substr(vmemoryb/1024,1,(INSTR(vmemoryb/1024,'.'))-1);
    if vmemoryk is null then
      vmemoryk := vmemoryb/1024;
    end if;
  end if;

  if vmemoryg >= 1 then
    vmemory:= vmemoryg || ' GB';
  elsif vmemorym >= 1 then
    vmemory:= vmemorym || ' MB';
  elsif vmemoryk >= 1 then
    vmemory:= vmemoryk || ' KB';
  else
    vmemory:= vmemoryb || ' B';
  end if;

--# ---------------------------------------------------------------------------------------#
--# INFORMACOES DO BANCO DE DADOS
--# ---------------------------------------------------------------------------------------#

  dbms_output.put_line('INFORMACOES DO BANCO DE DADOS');
  dbms_output.put_line('SID:............................. ' || x.sid);
  dbms_output.put_line('SERIAL:.......................... ' || x.serial);
  dbms_output.put_line('INSTANCIA:....................... ' || vinstance);
  dbms_output.put_line('BANCO DE DADOS:.................. ' || vdatabase || JBQB);

  dbms_output.put_line('ORACLE USER:..................... ' || x.username);
  dbms_output.put_line('STATUS:.......................... ' || x.status);
  DBMS_OUTPUT.PUT_LINE('INSTANCE ID:..................... ' || 'NODE ' || x.inst_id);
  
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
  

--# ---------------------------------------------------------------------------------------#
--# INFORMACOES DO SERVIDOR
--# ---------------------------------------------------------------------------------------#

  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S PID:......................... ' || x.spid);
  dbms_output.put_line('O/S USER:........................ ' || x.osuser);
  dbms_output.put_line('SERVIDOR:........................ ' || x.machine || JBQB);

  dbms_output.put_line('QUANTIDADE FIXA DE MEMORIA NECESSARIA DURANTE A EXECUCAO DO CURSOR: ' || JBQB || vmemory || JBQB );


--# ---------------------------------------------------------------------------------------#
--# INFORMACOES DA ESPERA
--# ---------------------------------------------------------------------------------------#

  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state || JBQB);
  if x.sql_hash_value <> 0 then
    dbms_output.put_line('SQL HASH VALUE:.................. ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v$sql where HASH_VALUE=' || x.sql_hash_value || ';');
    dbms_output.put_line('=============================================================================================='||JBQB);
    end if;

end loop;

SELECT nvl(count(sid),0) into vvalid FROM gv$process p, gv$session s
WHERE p.addr =  s.paddr and s.sql_hash_value is not null and s.sql_hash_value <> 0  and s.username is not null and s.status = 'ACTIVE' and audsid != userenv('SESSIONID');

if vvalid = 0 then
  dbms_output.put_line(JBQB);
  dbms_output.put_line('NESTE MOMENTO NAO HA USUARIOS ATIVOS EXECUTANDO PROCESSOS NO BANCO DE DADOS.');
  dbms_output.put_line(JBQB);
end if;



end;
/












GV$LOADISTAT
GV$LOADPSTAT
GV$LOBSTAT
GV$LOCKS_WITH_COLLISIONS


GV$IOFUNCMETRIC
GV$IOFUNCMETRIC_HISTORY
GV$IOSTAT_CONSUMER_GROUP
GV$IOSTAT_FILE
GV$IOSTAT_FUNCTION
GV$IOSTAT_FUNCTION_DETAIL
GV$IOSTAT_NETWORK
GV$IO_CALIBRATION_STATUS








GV$SQLSTATS_PLAN_HASH
GV$SQL_CS_STATISTICS
GV$SQL_PLAN_STATISTICS
GV$SQL_PLAN_STATISTICS_ALL
GV$SQL_REDIRECTION





GV$SGASTAT
GV$SQLSTATS
GV$SEGMENT_STATISTICS
GV$SEGSTAT
GV$SEGSTAT_NAME
GV$SERVICE_STATS
GV$SERV_MOD_ACT_STATS
GV$SESSION
GV$SESSION_BLOCKERS
GV$SESSION_CONNECT_INFO
GV$SESSION_CURSOR_CACHE
GV$SESSION_EVENT
GV$SESSION_FIX_CONTROL
GV$SESSION_LONGOPS
GV$SESSION_OBJECT_CACHE
GV$SESSION_WAIT
GV$SESSION_WAIT_CLASS
GV$SESSION_WAIT_HISTORY
GV$SESSTAT
GV$SESS_IO


GV$LOCKS_WITH_COLLISIONS
GV$LOGMNR_DICTIONARY
GV$LOGMNR_DICTIONARY_LOAD
GV$LOGMNR_REGION
GV$LOGMNR_SESSION
GV$LOGMNR_STATS
GV$LOGMNR_TRANSACTION
GV$LOGSTDBY_STATE
GV$LOGSTDBY_STATS
GV$LOGSTDBY_TRANSACTION
GV$MAP_FILE_IO_STACK
