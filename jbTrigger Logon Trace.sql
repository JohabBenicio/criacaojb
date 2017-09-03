-- -----------------------------------------------------------------------------------
-- Autor               : Giovani Marinho e Johab Benicio
-- Descrição           : Ativar geracao de trace ao conectar.
-- Nome do arquivo     : TriggerTrace.sql
-- Data de criação     : ??????????
-- Data de atualização : 05/04/2016
-- -----------------------------------------------------------------------------------

##############################################################################################################################
## Passo 0: Detalhes
##############################################################################################################################

-- Gerar o DDL da trigger.

SET LONG 99999 LINES 200 PAGES 300
SELECT DBMS_METADATA.GET_DDL('TRIGGER', 'TRG_LOGON_10046_JB', 'SYS' ) txt FROM DUAL;


-- Analisar Status da trigger.

set lines 200
col owner for a20
col TRIGGER_NAME for a30
select OWNER,TRIGGER_NAME,STATUS from dba_triggers where upper(TRIGGER_NAME) like 'TRG_LOGON%';


-- Desabilitar Trigger

alter trigger sys.trg_logon_10046_jb disable;


-- Habilitar trigger

alter trigger sys.trg_logon_10046_jb enable;





##############################################################################################################################
## Passo 1: Criar tabela
##############################################################################################################################

desc sys.traceflag_jb

drop table sys.traceflag_jb ;

create table sys.traceflag_jb
(
  flag number not null constraint ck_flag_traceflag_jb check (flag in (0, 1)),
  c_username varchar2(90),
  c_machine varchar2(90)
);


grant all on sys.traceflag_jb to public;

create public synonym traceflag_jb for sys.traceflag_jb;

grant alter session to SMOURA;



##############################################################################################################################
## Passo 2: Criar Trigger
##############################################################################################################################

create or replace trigger sys.trg_logon_10046_jb after logon on database
declare
  v_valid number;
  v_identifier varchar2(200);
begin

select flag, upper(sys_context('userenv', 'session_user')) || '_' || trim(to_char(sysdate, 'ddmmyyyy_hh24miss')) into v_valid, v_identifier from sys.traceflag_jb where flag=1 and upper(c_username) = upper(sys_context('userenv', 'session_user')) and upper(c_machine) = upper(sys_context('userenv', 'host')) and rownum=1;

if v_valid = 1 then
  execute immediate 'alter session set statistics_level = all';
  execute immediate 'alter session set timed_statistics = true';

  begin
    execute immediate 'alter session set tracefile_identifier = TEOR_' || v_identifier;
  exception
    when others then
      null;
  end;

  execute immediate 'alter session set max_dump_file_size = unlimited';
  execute immediate 'alter session set events ' || chr(39) || '10046 trace name context forever, level 12' || chr(39);
end if;

end;
/




##############################################################################################################################
## Passo 3: Configurar gatilho de trace.
##############################################################################################################################
# TIPO
0 = USERNAME
1 = OSUSER
2 = TERMINAL
3 = HOST


define flag=1
define tipo=1
define campo=bruno.santana
define descricao='Chamado 62148'



##############################################################################################################################

define valor=DATASUL
select distinct osuser,machine,username from gv$session where upper(program) like '%&&valor%';
select distinct osuser,machine,username,program from gv$session where upper(osuser) like '%&&valor%';
select distinct osuser,machine,username,program from gv$session where upper(username) like '%&&valor%';


##############################################################################################################################

col machine for a25
select distinct username,osuser,machine,program,count(*) qtd from gv$session where program not like '%(%' group by  osuser,machine,program,username order by qtd;

alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select inst_id,sid,serial#,logon_time,to_char(logon_time,'yyyymmddhh24miss') logon from gv$session where program not like '%(%' order by logon;




INFORMACOES DO BANCO DE DADOS
SID:............................. 20
SERIAL:.......................... 48523
INSTANCIA:....................... SMDB
BANCO DE DADOS:.................. SMDB

ORACLE USER:..................... SMSI
STATUS:.......................... ACTIVE
INSTANCE ID:..................... NODE 1
TEMPO DE EXECUCAO:............... 10 SEGUNDO(s)

FORMA DE CONEXAO (programa usado):
SESSION PROGRAM:.................

INFORMACOES DO SERVIDOR
O/S PID:......................... 57528
O/S USER:........................ root
SERVIDOR:........................ ARTESP_SM_SE

INFORMACOES DA ESPERA
SESSAO ESTA ESPERANDO EVENTO:.... db file sequential read
ESTADO DE ESPERA:................ WAITING

SQL HASH VALUE ATUAL:............ 975841225
QUERY TEXT:...................... select sql_fulltext from v$sql where HASH_VALUE=975841225;
==============================================================================================



INFORMACOES DO BANCO DE DADOS
SID:............................. 20
SERIAL:.......................... 48523
INSTANCIA:....................... SMDB
BANCO DE DADOS:.................. SMDB

ORACLE USER:..................... SMSI
STATUS:.......................... ACTIVE
INSTANCE ID:..................... NODE 1
TEMPO DE EXECUCAO:............... 10 SEGUNDO(s)

FORMA DE CONEXAO (programa usado):
SESSION PROGRAM:.................

INFORMACOES DO SERVIDOR
O/S PID:......................... 57528
O/S USER:........................ root
SERVIDOR:........................ ARTESP_SM_SE

INFORMACOES DA ESPERA
SESSAO ESTA ESPERANDO EVENTO:.... db file sequential read
ESTADO DE ESPERA:................ WAITING

SQL HASH VALUE ATUAL:............ 975841225
QUERY TEXT:...................... select sql_fulltext from v$sql where HASH_VALUE=975841225;
==============================================================================================



select sql_id from v$sql where HASH_VALUE=975841225;
87frbj8x2n9y9


select sql_id


INFORMACOES DO BANCO DE DADOS
SID:............................. 1173
SERIAL:.......................... 52543
INSTANCIA:....................... SMDB
BANCO DE DADOS:.................. SMDB

ORACLE USER:..................... SMSI
STATUS:.......................... INACTIVE
INSTANCE ID:..................... NODE 1
TEMPO DE EXECUCAO:............... 8 SEGUNDO(s)

FORMA DE CONEXAO (programa usado):
SESSION PROGRAM:................. SQL Developer

INFORMACOES DO SERVIDOR
O/S PID:......................... 41595
O/S USER:........................ bruno.santana
SERVIDOR:........................ CVIASSIS05

INFORMACOES DA ESPERA
SESSAO ESTA ESPERANDO EVENTO:.... SQL*Net message from client
ESTADO DE ESPERA:................ WAITING

SQL HASH VALUE ANTIGO:........... 3275389020
QUERY TEXT:...................... select sql_fulltext from v$sql where HASH_VALUE=3275389020;





select 'EXEC DBMS_MONITOR.SESSION_TRACE_ENABLE('||SID||','||SERIAL#||',TRUE,TRUE);' comando from v$session where username='SYS_TOUCH';

select 'EXEC DBMS_MONITOR.SESSION_TRACE_DISABLE('||SID||','||SERIAL#||');' comando from v$session where username='SYS_TOUCH';



-- Inserindo dados de usuario que vai ser rastreado.

delete sys.traceflag_jb ;
commit;


insert into sys.traceflag_jb (flag,tipo,campo,descricao) values (&&flag,&&tipo,'&&campo','&&descricao');
commit;





select sid,serial#,inst_id,osuser,machine,terminal,program from gv$session where osuser='GR156300';


-- Ativando o rastreamento

update sys.traceflag_jb set flag=1 where campo='&&campo' and flag=0 and descricao='&&descricao';
commit;

-- Desativar o rastreamento

update sys.traceflag_jb set flag=0 where campo='&&campo' and flag=1 and descricao='&&descricao';
commit;


set lines 200
select * from sys.traceflag_jb;






col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 9999999
set lines 300 pages 300
select s.username,s.machine,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,spid,TRACEFILE
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5;




col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 9999999
set lines 300 pages 300
select distinct s.username,s.machine,s.sid,s.serial#,s.osuser,s.inst_id,s.status,TRACEFILE
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5;




##############################################################################################################################
## Passo 4: Identificar sessão no banco de dados
##############################################################################################################################



set lines 200
set serveroutput on
declare
vpid varchar2(200);
vdump_dir varchar2(300);
vtrace varchar2(2000);
vtrace1 varchar2(2000);

begin
dbms_output.put_line(chr(10)||chr(10)||chr(10));

for v1 in (select * from sys.traceflag_jb where flag=1)LOOP

for x in (select distinct s.sql_id,s.username,s.program,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,s.LOGON_TIME,s.status,s.EVENT, i.instance_name,i.host_name,s.paddr
from gv$session s,gv$instance i
where (upper(s.osuser)=upper(v1.campo) or upper(s.username)=upper(v1.campo) or upper(s.terminal)=upper(v1.campo) or upper(s.machine)=upper(v1.campo))
and s.inst_id=i.inst_id
order by 5) LOOP

select VALUE into vdump_dir from gv$parameter where NAME like '%user_dump_dest%' and inst_id=x.inst_id;

dbms_output.put_line(rpad('+',40,'+')||' SESSAO '||rpad('+',40,'+')||chr(10));
    dbms_output.put_line('DATABASE INFORMATION:');
    dbms_output.put_line(rpad('USUARIO DATABASE:',29,'.')||chr(32)||lpad(x.username,10,' ')||chr(32)||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
    dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,10,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
    dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,10,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name||chr(10) );

    dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
    dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || chr(10));

    dbms_output.put_line('S.O INFORMATION:');

  for y in (SELECT distinct i.instance_name,p.spid from gv$process p, gv$instance i where i.inst_id=p.inst_id and  addr = x.paddr and spid is not null) LOOP

if v1.tipo = 1 then

  if vpid is not null then
    vpid:=y.spid ||', '|| vpid;
    vtrace:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '.trc'||chr(10)||vtrace;
    vtrace1:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.osuser || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc'||chr(10)||vtrace1;
  else
    vpid:=y.spid;
    vtrace:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '.trc';
    vtrace1:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.osuser || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc';
  end if;

else

  if vpid is not null then
    vpid:=y.spid ||', '|| vpid;
    vtrace:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '.trc'||chr(10)||vtrace;
    vtrace1:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.username || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc'||chr(10)||vtrace1;
  else
    vpid:=y.spid;
    vtrace:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '.trc';
    vtrace1:=vdump_dir || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.username || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc';
  end if;

end if;
END LOOP;

    dbms_output.put_line('PID:......................... ' || vpid);

    dbms_output.put_line('S/O USER:.................... ' || x.osuser);
    dbms_output.put_line('MACHINE:..................... ' || x.machine || chr(10));
    dbms_output.put_line('KILL SESSION:');
    dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||',@'||x.inst_id||''' immediate;' || chr(10));


if x.sql_id is not null then
    dbms_output.put_line('QUERY INFORMATION:');
    dbms_output.put_line('SQL_ID ATUAL:....... ' || nvl(x.sql_id,'NONE'));
    dbms_output.put_line('QUERY TEXT:'||chr(10)||'select sql_fulltext from gv$sql where sql_id=''' || x.sql_id || ''';' || chr(10));
else
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('NESTE MOMENTO O SQL_ID ESTA NULO');
end if;

DBMS_OUTPUT.PUT_LINE('NOME DO TRACE:' || chr(10) || vtrace || chr(10)||'OU'||chr(10)||vtrace1);


END LOOP;
END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(chr(10)||chr(10)||chr(10)||'Tabela traceflag_jb não encontrada.'||chr(10)||chr(10)||chr(10));

end;
/















########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################

                                                    OUTRO

########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################




col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 9999999
set lines 300 pages 300
select s.username,s.machine,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,spid,TRACEFILE
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5;




set lines 400 pages 20000
set serveroutput on
declare
vpid varchar2(200);
vdump_dir varchar2(300);
vtrace varchar2(2000);
vtrace1 varchar2(2000);

begin
dbms_output.put_line(chr(10)||chr(10)||chr(10));

for v1 in (select * from sys.traceflag where flag=1)LOOP

for x in (select distinct s.sql_id,s.username,s.program,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,s.LOGON_TIME,s.status,s.EVENT, i.instance_name,i.host_name,s.paddr
from gv$session s,gv$instance i
where (upper(s.osuser)=upper(v1.osuser) or upper(s.username)=upper(v1.username))
and s.inst_id=i.inst_id
order by 5) LOOP



dbms_output.put_line(rpad('+',40,'+')||' SESSAO '||rpad('+',40,'+')||chr(10));
    dbms_output.put_line('DATABASE INFORMATION:');
    dbms_output.put_line(rpad('USUARIO DATABASE:',29,'.')||chr(32)||lpad(x.username,10,' ')||chr(32)||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
    dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,10,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
    dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,10,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name||chr(10) );

    dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
    dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || chr(10));

    dbms_output.put_line('S.O INFORMATION:');

  for y in ( SELECT distinct i.instance_name,p.spid,pa.value from gv$process p, gv$instance i, gv$parameter pa where pa.NAME like '%user_dump_dest%' and i.inst_id=p.inst_id and i.inst_id=pa.inst_id and  addr = x.paddr and spid is not null order by 1) LOOP

  if vpid is not null then
    vpid:=y.spid ||', '|| vpid;
    vtrace:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '.trc'||chr(10)||vtrace;
    vtrace1:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.username || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc'||chr(10)||vtrace1;
  else
    vpid:=y.spid;
    vtrace:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '.trc';
    vtrace1:=y.value || '/' || y.instance_name || '_ora_' || y.spid || '_TEOR_' || x.username || '_' || trim(to_char(x.LOGON_TIME, 'yyyymmddhh24miss')) || '.trc';
  end if;

END LOOP;

    dbms_output.put_line('PID:......................... ' || vpid);

    dbms_output.put_line('S/O USER:.................... ' || x.osuser);
    dbms_output.put_line('MACHINE:..................... ' || x.machine || chr(10));
    dbms_output.put_line('KILL SESSION:');
    dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||',@'||x.inst_id||''' immediate;' || chr(10));


if x.sql_id is not null then
    dbms_output.put_line('QUERY INFORMATION:');
    dbms_output.put_line('SQL_ID ATUAL:....... ' || nvl(x.sql_id,'NONE'));
    dbms_output.put_line('QUERY TEXT:'||chr(10)||'select sql_fulltext from gv$sql where sql_id=''' || x.sql_id || ''';' || chr(10));
else
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('NESTE MOMENTO O SQL_ID ESTA NULO');
end if;

DBMS_OUTPUT.PUT_LINE('NOME DO TRACE:' || chr(10) || vtrace || chr(10)||'OU'||chr(10)||vtrace1);


END LOOP;
END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    dbms_output.put_line(chr(10)||chr(10)||chr(10)||'Tabela traceflag não encontrada.'||chr(10)||chr(10)||chr(10));

end;
/























define campo=smoura

col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a15
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a200
col event for a30
set lines 300 pages 300
select distinct s.sql_id,s.username,s.program,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,round(s.last_call_et/60) TimeMin ,s.EVENT
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
and s.program='PSipAns.exe'
order by 5;






col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a15
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a200
col event for a30
set lines 300 pages 300
select distinct s.sql_id,s.username,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,round(s.last_call_et/60) TimeMin,s.EVENT, 'alter system kill session '''||s.sid||','||s.serial#||',@'||s.inst_id||''' immediate;' KILL_SESSION
from gv$session s, gv$process p
where s.sid=1528
order by 5;



campo
col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 9999999
set lines 300 pages 300
select s.username,s.machine,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,spid,TRACEFILE
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5;




col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a20
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a100
col spid for 9999999
set lines 300 pages 300

begin

for x in (select s.username,s.machine,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,spid,TRACEFILE
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr
order by 5) loop

end loop;
dbms_output.put_line

end;
/









##############################################################################################################################
## Encontrar sessão do cliente no banco de dados
##############################################################################################################################

define campo=oracle


col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a15
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a200
col event for a30
set lines 300 pages 300
select s.sql_id,s.username,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,round(s.last_call_et/60) TimeMin,p.spid,s.EVENT, 'alter system kill session '''||s.sid||','||s.serial#||',@'||s.inst_id||''' immediate;' KILL_SESSION
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr and s.username is not null
order by 5;




col LOGON_TIME for a20
col machine for a30
col username for a15
col osuser for a15
col terminal for a15
col KILL_SESSION for a55
col TRACEFILE for a200
col event for a30
set lines 300 pages 300
select s.sql_id,s.username,s.machine,s.terminal,s.sid,s.serial#,s.osuser,s.inst_id,to_char(s.LOGON_TIME,'dd/mm/yyyy hh24:mi') LOGON_TIME,s.status,round(s.last_call_et/60) TimeMin,p.spid,s.EVENT, 'alter system kill session '''||s.sid||','||s.serial#||',@'||s.inst_id||''' immediate;' KILL_SESSION
from gv$session s, gv$process p
where (upper(s.osuser)=upper('&&campo') or upper(s.username)=upper('&&campo') or upper(s.terminal)=upper('&&campo') or upper(machine)=upper('&&campo'))
and p.addr = s.paddr and s.username is not null
order by 5;







##############################################################################################################################
## Passo 5: Identificar os traces no S.O.
##############################################################################################################################

find $ORACLE_BASE -name "*TEOR*" -mmin -60 -exec ls -lh {} \;

find  -name *TEOR* -mmin +60 -exec ls -lh {} \;

find  -name "*USR_PROCESS*" -mmin +60 -exec ls -lh {} \;
find  -name "*usr_process*" -mmin +60 -exec ls -lh {} \;



