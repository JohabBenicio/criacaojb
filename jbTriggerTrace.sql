-- ------------------------------------------------------------------------------------------------------------------------------
-- Autor               : Johab Benicio
-- Descrição           : Ativar geracao de trace ao conectar.
-- Nome do arquivo     : jbTriggerTrace.sql
-- Data de criação     : 22/02/2017
-- Data de atualização : 09/05/2017
-- ------------------------------------------------------------------------------------------------------------------------------
-- ##############################################################################################################################
-- ## Passo 1: Detalhes
-- ##############################################################################################################################


-- Gerar o DDL da trigger.

SET LONG 99999 LINES 200 PAGES 300
SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'LOGON_TRIGGER', 'RROCHA' ) txt FROM DUAL;

-- Analisar Status da trigger.

set lines 200
col owner for a20
col TRIGGER_NAME for a30
select OWNER,TRIGGER_NAME,STATUS from dba_triggers where upper(TRIGGER_NAME) like 'LOGON%';



alter trigger trg_logon_10046 disable;


-- Desabilitar Trigger

alter trigger trg_logon_10046_jb disable;


-- Habilitar trigger

alter trigger trg_logon_10046_jb enable;



-- ##############################################################################################################################
-- ## Passo 1: Apague os objetos criados nessa atividade.
-- ##############################################################################################################################



SELECT 'DROP '||DECODE (OBJECT_TYPE,'SYNONYM','PUBLIC SYNONYM',OBJECT_TYPE)  ||' '||DECODE(OWNER,'PUBLIC',NULL,OWNER||'.')||OBJECT_NAME||';' COMANDO
FROM DBA_OBJECTS
WHERE OBJECT_NAME IN ('TRG_LOGON_10046_JB','PRC_LOGON_10046_JB','PRC_DIS_TRC_10046_JB','TRACEFLAG_JB','TRACEHISTORY_JB','SEQ_TRACEFLAG_JB');


-- Apenas PL/SQL

SELECT 'DROP '||DECODE (OBJECT_TYPE,'SYNONYM','PUBLIC SYNONYM',OBJECT_TYPE)  ||' '||DECODE(OWNER,'PUBLIC',NULL,OWNER||'.')||OBJECT_NAME||';' COMANDO
FROM DBA_OBJECTS
WHERE OBJECT_NAME IN ('TRG_LOGON_10046_JB','PRC_LOGON_10046_JB','PRC_DIS_TRC_10046_JB');




-- ##############################################################################################################################
-- ## Passo 2: Criar tabela
-- ##############################################################################################################################

create table traceflag_jb
(
  flag number not null constraint ck_flag_traceflag_jb check (flag in (0, 1)),
  id_trace number,
  osuser varchar2(90),
  terminal varchar2(90),
  host varchar2(90),
  username varchar2(90),
  program varchar2(90),
  campo varchar2(7) not null
);

create table tracehistory_jb
(
  instance number,
  id_trace number,
  sid number,
  serial number,
  type_trace varchar2(10),
  horario varchar2(20),
  status varchar2(10),
  detalhes varchar2(500)
);

create sequence seq_traceflag_jb minvalue 1 maxvalue 9999999 start with 1 increment by 1 nocache cycle;

grant all on traceflag_jb to public;
create public synonym traceflag_jb for traceflag_jb;

grant all on tracehistory_jb to public;
create public synonym tracehistory_jb for tracehistory_jb;

grant all on seq_traceflag_jb to public;
create public synonym seq_traceflag_jb for seq_traceflag_jb;



-- ##############################################################################################################################
-- ## Passo 3: Previlegio "alter session"
-- ##############################################################################################################################

select distinct  privilege from dba_sys_privs where grantee='PUBLIC';

select distinct  privilege from dba_sys_privs where grantee='CORRWIN';


-- Caso não tenha a grant "alter session", então conceda para role PUBLI, mas não esqueça de revogar a mesma.
grant alter session to CORRWIN;

revoke alter session from CORRWIN;


-- ##############################################################################################################################
-- ## Passo 4: Criar Trigger e procedure
-- ##############################################################################################################################


create or replace trigger trg_logon_10046_jb after logon on database
declare
  v_count varchar2(9);
  v_identifier varchar2(64):=upper(sys_context('userenv', 'session_user')) || '_' || trim(to_char(sysdate, 'yyyymmddhh24miss'));
  v_where varchar2(2000);
  v_query varchar2(2000);
  v_instance number;
  v_id_trace number;
  v_trace    varchar2(500);
  v_insert   varchar2(500);
begin

select sys_context('userenv','instance') into v_instance from dual;

for trg in (
  select
    paddr, sid, upper(osuser) osuser, upper(terminal) terminal, upper(machine) machine, upper(username) username,
    upper(module) module, upper(program) program, serial# serial, to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') v_horario
  from v$session where sid=userenv('sid')
  ) loop

for x in (select * from traceflag_jb where flag=1 and campo is not null) loop

  if x.campo like '%O%' then
    v_where:=' and upper(osuser) = '||chr(39)||trg.osuser||chr(39);
  end if;

  if x.campo like '%T%' then
    v_where:=v_where||' and upper(terminal) = '||chr(39)||trg.terminal||chr(39);
  end if;

  if x.campo like '%H%' then
    v_where:=v_where||' and upper(host) = '||chr(39)||trg.machine||chr(39);
  end if;

  if x.campo like '%U%' then
    v_where:=v_where||' and upper(username) = '||chr(39)||trg.username||chr(39);
  end if;

  if x.campo like '%P%' then
    v_where:=v_where||' and (upper(program) = '||chr(39)||trg.module||chr(39)||' or upper(program) = '||chr(39)||trg.program||chr(39)||')';
  end if;

  v_query:='select count(*),id_trace from traceflag_jb where flag=1 '||v_where||' group by id_trace';
    begin
      execute immediate v_query into v_count,v_id_trace;
    exception
      when others then
        --RAISE_APPLICATION_ERROR(-20001,'Comando executado: '||v_query,true);
        null;
    end;

  exit when v_count>0;
end loop;

if v_count > 0 then
  begin
    execute immediate 'alter session set tracefile_identifier = P4T_' || v_identifier;
  exception
    when others then
      null;
  end;
  execute immediate 'alter session set max_dump_file_size = unlimited';
  execute immediate 'alter session set events ' || chr(39) || '10046 trace name context forever, level 12' || chr(39);


  select a.value||'/'||lower(b.instance_name)||'_ora_'||c.spid||'*.trc' into v_trace
  from v$parameter a, v$instance b, v$process c
  where a.name like '%user_dump_dest%' and c.addr=trg.paddr;

  v_insert:='insert into tracehistory_jb (id_trace,instance,sid,serial,type_trace,horario,status,detalhes) values ('||v_id_trace||','||v_instance||','||trg.sid||','||trg.serial||','||chr(39)||'TRIGGER'||chr(39)||','||chr(39)||trg.v_horario||chr(39)||','||chr(39)||'ON'||chr(39)||','||chr(39)||v_trace||chr(39)||')';

  execute immediate v_insert;
  commit;

end if;

end loop;

END;
/












-- ############################################################################################################################################
-- ## Procedure de apoio


create or replace procedure prc_logon_10046_jb (osuser_in in varchar2, terminal_in in varchar2, host_in in varchar2, username_in in varchar2, program_in in varchar2, active_in in varchar2, currents_in in varchar2 ) is
  TYPE CurTyp  IS REF CURSOR;
  v_cursor    CurTyp;
  v_values varchar2(2000);
  v_where varchar2(2000);
  v_query varchar2(2000);
  v_insert_tr varchar2(2000);
  v_insert_his varchar2(2000);
  v_trace varchar2(500);
  v_campo varchar2(30);
  v_column varchar2(200);
  v_horario varchar2(90);
  v_active number;
  v_sid number;
  v_serial number;
  v_instance number;
  v_id_trace number;
  v_paddr varchar2(90);
BEGIN

if active_in is null or upper(active_in)='Y' or upper(active_in)='S' or upper(active_in)='YES' or upper(active_in)='SIM' then
    v_active:=1;
else
    v_active:=0;
end if;

if osuser_in is not null and osuser_in != '*' then
  v_values:=','||chr(39)||upper(osuser_in)||chr(39);
  v_campo:='O';
  v_column:=',osuser';
  v_where:=' and upper(osuser) = upper('||chr(39)||osuser_in||chr(39)||') ';
else
  v_column:=',osuser';
  v_values:=','||chr(39)||'*'||chr(39);
end if;

if terminal_in is not null and terminal_in != '*' then
  v_values:=v_values||','||chr(39)||upper(terminal_in)||chr(39);
  v_campo:='T'||v_campo;
  v_column:=v_column||',terminal';
  v_where:=v_where||' and upper(terminal) = upper('||chr(39)||terminal_in||chr(39)||') ';
else
  v_column:=v_column||',terminal';
  v_values:=v_values||','||chr(39)||'*'||chr(39);
end if;

if host_in is not null and host_in != '*' then
  v_values:=v_values||','||chr(39)||upper(host_in)||chr(39);
  v_campo:='H'||v_campo;
  v_column:=v_column||',host';
  v_where:=v_where||' and upper(machine) = upper('||chr(39)||host_in||chr(39)||') ';
else
  v_column:=v_column||',host';
  v_values:=v_values||','||chr(39)||'*'||chr(39);
end if;

if username_in is not null and username_in != '*' then
  v_values:=v_values||','||chr(39)||upper(username_in)||chr(39);
  v_campo:='U'||v_campo;
  v_column:=v_column||',username';
  v_where:=v_where||' and upper(username) = upper('||chr(39)||username_in||chr(39)||') ';
else
  v_column:=v_column||',username';
  v_values:=v_values||','||chr(39)||'*'||chr(39);
end if;

if program_in is not null and program_in != '*' then
  v_values:=v_values||','||chr(39)||upper(program_in)||chr(39);
  v_campo:='P'||v_campo;
  v_column:=v_column||',program';
  v_where:=v_where||' and upper(program) = upper('||chr(39)||program_in||chr(39)||') ';
else
  v_column:=v_column||',program';
  v_values:=v_values||','||chr(39)||'*'||chr(39);
end if;

if v_campo is null then
v_campo:='null';
end if;

select seq_traceflag_jb.nextval into v_id_trace from dual;

if v_values is not null then
  v_insert_tr:='insert into traceflag_jb (id_trace,flag'||v_column||',campo) values ('||v_id_trace||','||v_active||v_values||','||chr(39)||v_campo||chr(39)||')';
  execute immediate v_insert_tr;
  commit;

if upper(currents_in) = 'Y' or upper(currents_in) = 'S' then

        v_query:='select distinct sid,serial#,paddr from v$session s where username is not null and program not like '||chr(39)||'%(J0%'||chr(39)||v_where;
        open v_cursor for v_query;

        loop
          fetch v_cursor into v_sid,v_serial,v_paddr;
          exit when v_cursor%notfound;

          begin
              dbms_monitor.session_trace_enable(v_sid,v_serial,true,true);
              select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into v_horario from dual;
              select sys_context('userenv','INSTANCE') into v_instance from dual;

              select a.value||'/'||lower(b.instance_name)||'_ora_'||c.spid||'*.trc' into v_trace
              from v$parameter a, v$instance b, v$process c
              where a.name like '%user_dump_dest%' and c.addr=v_paddr;

              v_insert_his:='insert into tracehistory_jb (id_trace,instance,sid,serial,type_trace,horario,status,detalhes) values ('||v_id_trace||','||v_instance||','||v_sid||','||v_serial||','||chr(39)||'PROCEDURE'||chr(39)||','||chr(39)||v_horario||chr(39)||','||chr(39)||'ON'||chr(39)||','||chr(39)||v_trace||chr(39)||')';
              execute immediate v_insert_his;
              commit;
          exception
            when others then
               -- raise_application_error(-20001,'Comando executado: Falha ao ativar o trace para a sessao SID='||v_sid||'and serial#='||v_serial, FALSE);
               null;
          end;

        end loop;

        close v_cursor;
end if;

end if;
EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Comando executado: '||v_insert_tr, FALSE);
END;
/




-- ############################################################################################################################################
-- ## Procedure de apoio





create or replace procedure prc_dis_trc_10046_jb (id_trace_in in number, action_in in varchar2) is
  type curtyp  is ref cursor;
  v_cursor     curtyp;
  v_sid        number;
  v_serial     number;
  v_valid      number;
  v_paddr      varchar2(40);
  v_horario    varchar2(40);
  v_value      varchar2(200);
  v_where      varchar2(200);
  v_insert_his varchar2(500);
  v_query      varchar2(500);
  v_trace      varchar2(500);
  v_instance   varchar2(8);
  v_valid_1    number:=0;
begin

select sys_context('userenv','instance') into v_instance from dual;

CASE upper(action_in)
  WHEN 'REFRESH'   THEN
    for y in (select * from tracehistory_jb where status='ON') loop
      select count(*) into v_valid from gv$session where sid=y.sid and serial#=y.serial and inst_id=y.instance;
        if v_valid = 0 then
          update tracehistory_jb set status='OFF' where sid=y.sid and serial=y.serial and instance=y.instance and status='ON';
        end if;
    end loop;
  WHEN 'STOP_TRACE'       THEN
    for x in (
          select t.sid,t.serial,t.type_trace
          from v$session s, tracehistory_jb t
          where t.sid=s.sid
          and t.serial=s.serial#
          and t.status='ON'
          and t.id_trace= id_trace_in
      ) loop
      CASE x.type_trace
        WHEN 'PROCEDURE' THEN
          dbms_monitor.session_trace_disable(x.sid,x.serial);
          update tracehistory_jb set status='OFF' where sid=x.sid and serial=x.serial and instance=v_instance and status='ON';
        WHEN 'TRIGGER' THEN
          DBMS_SYSTEM.SET_EV(x.sid,x.serial,10046,0,'');
          update tracehistory_jb set status='OFF' where sid=x.sid and serial=x.serial and instance=v_instance and status='ON';
      END CASE;
    end loop;
  WHEN 'DESACTIVE_TRIGGER' THEN
    execute immediate 'update traceflag_jb set flag=0 where ID_TRACE='||id_trace_in;
  WHEN 'ACTIVE_TRIGGER' THEN
    execute immediate 'update traceflag_jb set flag=1 where ID_TRACE='||id_trace_in;
  WHEN 'ACTIVE_TRACE' THEN
    for x in (select * from traceflag_jb where id_trace=id_trace_in and campo is not null) loop

    if x.campo like '%O%' then
      v_where:=' and upper(osuser) = '||chr(39)||x.osuser||chr(39);
    end if;
    if x.campo like '%T%' then
      v_where:=v_where||' and upper(terminal) = '||chr(39)||x.terminal||chr(39);
    end if;
    if x.campo like '%H%' then
      v_where:=v_where||' and upper(machine) = '||chr(39)||x.host||chr(39);
    end if;
    if x.campo like '%U%' then
      v_where:=v_where||' and upper(username) = '||chr(39)||x.username||chr(39);
    end if;
    if x.campo like '%P%' then
      v_where:=v_where||' and (upper(module) = '||chr(39)||x.program||chr(39)||' or upper(program) = '||chr(39)||x.program||chr(39)||')';
    end if;


    v_query:='select distinct sid,serial#,paddr from v$session s where username is not null and program not like '||chr(39)||'%(J0%'||chr(39)||v_where;
    open v_cursor for v_query;
    loop
      fetch v_cursor into v_sid,v_serial,v_paddr;
      exit when v_cursor%notfound;
      begin
          dbms_monitor.session_trace_enable(v_sid,v_serial,true,true);
          select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into v_horario from dual;
          select sys_context('userenv','INSTANCE') into v_instance from dual;

          select a.value||'/'||lower(b.instance_name)||'_ora_'||c.spid||'*.trc' into v_trace
          from v$parameter a, v$instance b, v$process c
          where a.name like '%user_dump_dest%' and c.addr=v_paddr;

          v_insert_his:='insert into tracehistory_jb (id_trace,instance,sid,serial,type_trace,horario,status,detalhes) values ('||id_trace_in||','||v_instance||','||v_sid||','||v_serial||','||chr(39)||'PROCEDURE'||chr(39)||','||chr(39)||v_horario||chr(39)||','||chr(39)||'ON'||chr(39)||','||chr(39)||v_trace||chr(39)||')';
          execute immediate v_insert_his;
          commit;
      exception
        when others then
           -- raise_application_error(-20001,'Comando executado: Falha ao ativar o trace para a sessao SID='||v_sid||'and serial#='||v_serial, FALSE);
           null;
      end;
    end loop;
    close v_cursor;
    end loop;

END CASE;

commit;
end;
/




-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################
-- ##############################################################################################################################



-- ##############################################################################################################################
-- ## Passo 6: Remover os objetos criados no atendimento do chamado.
-- ##############################################################################################################################


delete traceflag_jb;
commit;

delete tracehistory_jb;
commit;





-- ##############################################################################################################################
-- ## Passo 7: Query para ajudar na identificação do usuario.
-- ##############################################################################################################################



define campo=CORRWIN

select distinct sid,serial#,username,machine,osuser,terminal,program,status from gv$session
where upper(username) like '%&&campo%' or upper(osuser) like upper('%&&campo%') or upper(terminal) like '%&&campo%';


set lines 200 pages 999
col program for a60
col machine for a30
select distinct username,machine,osuser,terminal,program from gv$session where username is not null order by 1;


set lines 200 pages 999
col program for a60
col machine for a30
select distinct username,machine,osuser,terminal,program from gv$session where upper(program) like '%HSS%';



-- #####################################

define campo=CORRWIN

col logon_time for a20
col machine for a30
col username for a20
col osuser for a20
col terminal for a15
col kill_session for a55
col tracefile for a100
col program for a30
col spid for 99999
set lines 300 pages 300
select distinct s.username,s.machine,s.osuser,s.terminal,s.sid,s.serial#,s.inst_id,s.status,s.sql_id,s.program
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by s.sid;


####### Ativar com base nas sessoes ativadas na tabela


col logon_time for a20
col machine for a30
col username for a20
col osuser for a20
col terminal for a15
col kill_session for a55
col tracefile for a100
col program for a30
col spid for 99999
set lines 300 pages 300
select distinct s.username,s.machine,s.osuser,s.terminal,s.sid,s.serial#,s.inst_id,s.status,s.sql_id,s.program
from gv$session s, gv$process p
where (
    upper(s.username) in (select username from traceflag_jb where FLAG=1)
 or upper(s.osuser) in (select osuser from traceflag_jb where FLAG=1)
 or upper(s.terminal) in (select terminal from traceflag_jb where FLAG=1)
 or upper(s.machine) in (select host from traceflag_jb where FLAG=1)
 or upper(s.program) in (select program from traceflag_jb where FLAG=1)
 ) -- and s.status='ACTIVE'
and p.addr = s.paddr
order by s.sid;





-- ##############################################################################################################################
-- ## Passo 8: Configurar gatilho de trace.
-- ##############################################################################################################################


exec prc_logon_10046_jb(username_in => 'CORRWIN', -
host_in => 'COIN\COIN-2034', -
osuser_in => '*', -
terminal_in => '*', -
program_in => '*', -
active_in => 'Y', -
currents_in => 'N');




-- ##############################################################################################################################
-- ## Passo 5: Remover os objetos criados no atendimento do chamado.
-- ##############################################################################################################################


set lines 200
col OSUSER for a30
col TERMINAL for a30
col USERNAME for a30
col HOST for a30
col module for a20
col detalhes for a76
col program for a10
select * from traceflag_jb;
select * from tracehistory_jb order by 6;



-- ##############################################################################################################################
-- ## Passo 9: Desativar/ativar trace
-- ##############################################################################################################################

-- Desativar o trace de todas as sessoes do usuario X na tabela traceflag_jb.
exec prc_dis_trc_10046_jb (id_trace_in => 1, action_in => 'STOP_TRACE');

-- Atualizar a tabela de historico. <Traces que foram desativados>
exec prc_dis_trc_10046_jb (id_trace_in => 1, action_in => 'REFRESH');

-- Desativar o trigger do trace da sessao do usuario X na tabela traceflag_jb.
exec prc_dis_trc_10046_jb (id_trace_in => 1, action_in => 'DESACTIVE_TRIGGER');

-- Ativar o trigger do trace da sessao do usuario X na tabela traceflag_jb.
exec prc_dis_trc_10046_jb (id_trace_in => 1, action_in => 'ACTIVE_TRIGGER');

-- Ativar o trace para todas as sessoes do usuario X na tabela traceflag_jb na instancia atual.
exec prc_dis_trc_10046_jb (id_trace_in => 1, action_in => 'ACTIVE_TRACE');








-- ##############################################################################################################################
-- ## Teste comm trigger de logon
-- ##############################################################################################################################


grant connect,alter session to teste_user_connect identified by oracle;

drop user teste_user_connect;



sqlplus teste_user_connect/oracle

select sys_context('userenv','module') from dual;





function connect_teste (){
sqlplus teste_user_connect/oracle <<EOF
set lines 200
col OSUSER for a30
col TERMINAL for a30
col USERNAME for a30
col HOST for a30
col module for a20
select * from traceflag_jb;
select * from tracehistory_jb order by 6;
quit;
EOF

}

connect_teste



delete tracehistory_jb;
commit;


