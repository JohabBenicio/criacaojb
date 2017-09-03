-- ------------------------------------------------------------------------------------------------------------------------------
-- Autor               : Johab Benicio
-- Descrição           : Ativar geracao de trace ao conectar.
-- Nome do arquivo     : jbTriggerTrace.sql
-- Data de criação     : 22/02/2017
-- Data de atualização : 25/04/2017
-- ------------------------------------------------------------------------------------------------------------------------------
-- ##############################################################################################################################
-- ## Passo 1: Detalhes
-- ##############################################################################################################################


-- Gerar o DDL da trigger.

SET LONG 99999 LINES 200 PAGES 300
SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_LOGON_10046', 'SYS' ) txt FROM DUAL;

-- Analisar Status da trigger.

set lines 200
col owner for a20
col TRIGGER_NAME for a30
select OWNER,TRIGGER_NAME,STATUS from dba_triggers where upper(TRIGGER_NAME) like 'TRG_LOGON%';



alter trigger trg_logon_10046 disable;


-- Desabilitar Trigger

alter trigger trg_logon_10046_jb disable;


-- Habilitar trigger

alter trigger trg_logon_10046_jb enable;




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
  campo varchar2(4) not null
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
  observacao varchar2(200)
);

create sequence seq_traceflag_jb minvalue 1 maxvalue 10000 start with 1 increment by 1 nocache cycle;

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

select distinct  privilege from dba_sys_privs where grantee='LUIZ';


-- Caso não tenha a grant "alter session", então conceda para role PUBLI, mas não esqueça de revogar a mesma.
grant alter session to public;

revoke alter session from public;


-- ##############################################################################################################################
-- ## Passo 4: Criar Trigger e procedure
-- ##############################################################################################################################


create or replace trigger trg_logon_10046_jb after logon on database
declare
  v_count varchar2(9);
  v_identifier varchar2(64):=upper(sys_context('userenv', 'session_user')) || '_' || trim(to_char(sysdate, 'yyyymmddhh24miss'));
  v_where varchar2(2000);
  v_query varchar2(2000);
  v_sid number;
  v_serial number;
  v_instance number;
  v_horario varchar2(90);
  v_id_trace number;
begin

for x in (select osuser ,terminal ,host ,username ,campo from traceflag_jb where flag=1 and campo is not null) loop

if x.campo like '%O%' then
  v_where:='and upper(osuser) = upper(sys_context('||chr(39)||'userenv'||chr(39)||', '||chr(39)||'os_user'||chr(39)||')) ';
end if;

if x.campo like '%T%' then
  v_where:=v_where||'and upper(terminal) = upper(sys_context('||chr(39)||'userenv'||chr(39)||', '||chr(39)||'terminal'||chr(39)||')) ';
end if;

if x.campo like '%H%' then
  v_where:=v_where||'and upper(host) = upper(sys_context('||chr(39)||'userenv'||chr(39)||', '||chr(39)||'host'||chr(39)||')) ';
end if;

if x.campo like '%U%' then
  v_where:=v_where||'and upper(username) = upper(sys_context('||chr(39)||'userenv'||chr(39)||', '||chr(39)||'session_user'||chr(39)||')) ';
end if;


v_query:='select count(*),id_trace from traceflag_jb where flag=1 '||v_where||' group by id_trace';

execute immediate v_query into v_count,v_id_trace;

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

  select sys_context('userenv','INSTANCE') into v_instance from dual;
  select sys_context('userenv','SID') into v_sid from dual;
  select serial# into v_serial from v$session where sid=v_sid;
  select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into v_horario from dual;

  execute immediate 'insert into tracehistory_jb (id_trace,instance,sid,serial,type_trace,horario,status) values ('||v_id_trace||','||v_instance||','||v_sid||','||v_serial||','||chr(39)||'TRIGGER'||chr(39)||','||chr(39)||v_horario||chr(39)||','||chr(39)||'ON'||chr(39)||')';
  commit;

end if;

EXCEPTION
  WHEN OTHERS THEN
      RAISE_APPLICATION_ERROR(-20001,'Comando executado: '||v_query, FALSE);
END;
/





-- ############################################################################################################################################
-- ## Procedure de apoio


create or replace procedure prc_logon_10046_jb (osuser_in in varchar2, terminal_in in varchar2, host_in in varchar2, username_in in varchar2, active_in in varchar2, currents_in in varchar2 ) is
  TYPE CurTyp  IS REF CURSOR;
  v_cursor    CurTyp;
  v_values varchar2(2000);
  v_where varchar2(2000);
  v_query varchar2(2000);
  v_insert_tr varchar2(2000);
  v_insert_his varchar2(2000);
  v_campo varchar2(30);
  v_column varchar2(200);
  v_horario varchar2(90);
  v_active number;
  v_sid number;
  v_serial number;
  v_instance number;
  v_id_trace number;
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

if v_campo is null then
v_campo:='null';
end if;

select seq_traceflag_jb.nextval into v_id_trace from dual;

if v_values is not null then
  v_insert_tr:='insert into traceflag_jb (id_trace,flag'||v_column||',campo) values ('||v_id_trace||','||v_active||v_values||','||chr(39)||v_campo||chr(39)||')';
  execute immediate v_insert_tr;
  commit;

if upper(currents_in) = 'Y' or upper(currents_in) = 'S' then

        v_query:='select distinct sid,serial# from v$session s where username is not null and program not like '||chr(39)||'%(J0%'||chr(39)||v_where;
        open v_cursor for v_query;

        loop
          fetch v_cursor into v_sid,v_serial;
          exit when v_cursor%notfound;

          begin
              dbms_monitor.session_trace_enable(v_sid,v_serial,true,true);
              select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') into v_horario from dual;
              select sys_context('userenv','INSTANCE') into v_instance from dual;
              v_insert_his:='insert into tracehistory_jb (id_trace,instance,sid,serial,type_trace,horario,status) values ('||v_id_trace||','||v_instance||','||v_sid||','||v_serial||','||chr(39)||'PROCEDURE'||chr(39)||','||chr(39)||v_horario||chr(39)||','||chr(39)||'ON'||chr(39)||')';
              execute immediate v_insert_his;
              commit;
          exception
            when others then
                raise_application_error(-20001,'Comando executado: Falha ao ativar o trace para a sessao SID='||v_sid||'and serial#='||v_serial, FALSE);
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


create or replace procedure prc_dis_trc_10046_jb (id_trace_in in number, type_in in varchar2) is
  v_sid number;
  v_serial number;
  v_valid number;
begin

  for x in (select t.sid,t.serial,t.type_trace,t.instance from gv$session s, tracehistory_jb t where t.sid=s.sid and t.serial=s.serial# and t.instance=s.inst_id and t.status='ON' and t.id_trace= id_trace_in and upper(t.type_trace) = upper(type_in)) loop

    if upper(type_in) = 'PROCEDURE' then
      dbms_monitor.session_trace_disable(x.sid,x.serial);
      update tracehistory_jb set status='OFF' where sid=x.sid and serial=x.serial and instance=x.instance and status='ON';

    else
      DBMS_SYSTEM.SET_EV(x.sid,x.serial,10046,12,'');
      update tracehistory_jb set status='OFF' where sid=x.sid and serial=x.serial and instance=x.instance and status='ON';

    end if;
  end loop;

  for y in (select * from tracehistory_jb where status='ON') loop
    select count(*) into v_valid from gv$session where sid=y.sid and serial#=y.serial and inst_id=y.instance;
    if v_valid > 0 then
      update tracehistory_jb set status='OFF' where sid=y.sid and serial=y.serial and instance=y.instance and status='ON';

    end if;
  end loop;

commit;
end;
/


select t.sid,t.serial,t.type_trace,t.instance from gv$session s, tracehistory_jb t where t.sid=s.sid and t.serial=s.serial# and t.instance=s.inst_id and t.status='ON' and t.id_trace= 1 and upper(t.type_trace) = upper('procedure');


-- ##############################################################################################################################
-- ## Passo 5: Configurar gatilho de trace.
-- ##############################################################################################################################


exec prc_logon_10046_jb(username_in => 'luiz', -
host_in => '*', -
osuser_in => '*', -
terminal_in => '*', -
active_in => 'Y', -
currents_in => 'Y');


-- ##############################################################################################################################
-- ## Passo 5: Configurar gatilho de trace.
-- ##############################################################################################################################


exec prc_dis_trc_10046_jb (id_trace_in => '1', type_in => 'procedure');




-- ##############################################################################################################################
-- ## Passo 6: Remover os objetos criados no atendimento do chamado.
-- ##############################################################################################################################


set lines 200
col OSUSER for a30
col TERMINAL for a30
col USERNAME for a30
col HOST for a30
select * from traceflag_jb;
select * from tracehistory_jb order by 6;



-- ##############################################################################################################################
-- ## Passo 6: Remover os objetos criados no atendimento do chamado.
-- ##############################################################################################################################


delete traceflag_jb;
delete tracehistory_jb;
commit;




-- ##############################################################################################################################
-- ## Passo 7: Query para ajudar na identificação do usuario.
-- ##############################################################################################################################
-- # Oracle 11g

define campo=LUIZ

col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 99999
set lines 300 pages 300
select s.username,s.machine,s.osuser,s.terminal,s.sid,s.serial#,s.inst_id,s.status,s.sql_id,p.tracefile --,p.spid
-- ,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5;



-- # Oracle 10g

define campo=ccaremoto.ctv

col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 99999
set lines 300 pages 300
select s.username,s.machine,s.osuser,s.terminal,s.sid,s.serial#,s.inst_id,s.status,s.sql_id --,p.spid
-- ,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5;





-- ##############################################################################################################################

define campo=M

select distinct username,machine,osuser,terminal,program from gv$session
where upper(username) like '%&&campo%' or upper(osuser) like '%&&campo%' or upper(terminal) like '%&&campo%';




set lines 200 pages 999
col program for a60
col machine for a30
select distinct username,machine,osuser,terminal,program from gv$session where username is not null;




##############################################################################################################################
## Passo 8: Identificar os traces no S.O.
##############################################################################################################################


set serveroutput on
declare
x varchar2(300);
begin
dbms_output.put_line(chr(10)||chr(10)||chr(10));
select value into x from v$parameter where name='user_dump_dest';
dbms_output.put_line('!ls -lthr '||x||'/*P4T* | tail -10');
end;
/




-- ##############################################################################################################################
-- ## Passo 9: Apague os objetos criados nessa atividade.
-- ##############################################################################################################################

select 'drop '||OBJECT_TYPE||' '||OWNER||'.'||OBJECT_NAME||';' COMANDO from dba_objects where OBJECT_NAME in ('TRG_LOGON_10046_JB','PRC_LOGON_10046_JB','TRACEFLAG_JB','TRACEHISTORY_JB','SEQ_TRACEFLAG_JB') and OBJECT_TYPE!='SYNONYM';


drop public synonym seq_traceflag_jb;
drop public synonym traceflag_jb;
drop public synonym tracehistory_jb;





