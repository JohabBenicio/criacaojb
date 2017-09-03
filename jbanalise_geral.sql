-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Data de criação     : 01/05/2015
-- -----------------------------------------------------------------------------------



set serveroutput on
set lines 200 pages 0
BEGIN

dbms_output.put_line(chr(10)||chr(10)||chr(10)||'PROCESS com WAIT muito alto'||chr(10));

for x in (select a.username, a.program, a.osuser, a.sid, a.serial#, b.spid, a.seconds_in_wait, a.event, a.state, a.wait_class
from v$session a, v$process b
where a.sql_hash_value > 0
and a.seconds_in_wait > 500
and a.username is not null order by a.seconds_in_wait)  LOOP

	dbms_output.put_line('SID:........................... '||x.sid);
	dbms_output.put_line('SERIAL#:....................... '||x.serial#);
	dbms_output.put_line('USERNAME:...................... '||x.username);
	dbms_output.put_line('USER S.O:...................... '||x.osuser);
	dbms_output.put_line('PROGRAM:....................... '||x.program);
	dbms_output.put_line('PID:........................... '||x.spid);
	dbms_output.put_line('EVENT:......................... '||x.event);
	dbms_output.put_line('STATE:......................... '||x.state);
	dbms_output.put_line('WAIT TIME:..................... '||x.seconds_in_wait/60 ||' Min');
	dbms_output.put_line('WAIT_CLASS:.................... '||x.wait_class||chr(10));
END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/





set serveroutput on
set lines 200 pages 0
BEGIN

dbms_output.put_line(chr(10)||chr(10)||chr(10)||'PROCESS com WAIT muito alto'||chr(10));

for x in (select a.username, a.program, a.osuser, a.sid, a.serial#, b.spid, a.seconds_in_wait, a.event, a.state, a.wait_class
from v$session a, v$process b
where a.sql_hash_value > 0
and a.seconds_in_wait > 500
and a.username is not null order by a.seconds_in_wait)  LOOP

    dbms_output.put_line('SID:........................... '||x.sid);
    dbms_output.put_line('SERIAL#:....................... '||x.serial#);
    dbms_output.put_line('USERNAME:...................... '||x.username);
    dbms_output.put_line('USER S.O:...................... '||x.osuser);
    dbms_output.put_line('PROGRAM:....................... '||x.program);
    dbms_output.put_line('PID:........................... '||x.spid);
    dbms_output.put_line('EVENT:......................... '||x.event);
    dbms_output.put_line('STATE:......................... '||x.state);
    dbms_output.put_line('WAIT TIME:..................... '||x.seconds_in_wait/60 ||' Min');
    dbms_output.put_line('WAIT_CLASS:.................... '||x.wait_class||chr(10));
END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/







pro
pro
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro
pro

col machine for a30
col select for a70
select chr(10)||chr(10)||chr(10)||'Sessoes que estao execucando algo' "." from dual;
select sid,serial#,machine,osuser,sql_hash_value ,'select sql_text from v$sql where hash_value='||sql_hash_value "select"  from v$session where username is not null and sql_hash_value>0 and  audsid != userenv('SESSIONID');



pro
pro
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro
pro


-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Identificar lock e seus detalhes.
-- Nome do arquivo     : jblock.sql
-- Data de criação     : 01/07/2014
-- Data de atualização : 04/05/2015
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 500
Set pages 200
set long 999
set feedback off

declare

v_query_max_lock varchar2(20);
vloop_lock_qtd varchar2(20);
vvalid varchar2(90);
JBQB VARCHAR2(90) := CHR(13) || CHR(10);

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin

dbms_output.put_line(JBQB || JBQB );
dbms_output.put_line('#-- -----------------------------------------------------------------------------------'||chr(10)||'#-- Autor               : Johab Benicio de Oliveira.'||chr(10)||'#-- Descricao           : Identificar lock e seus detalhes.'||chr(10)||'#-- Nome do arquivo     : jblock.sql'||chr(10)||'#-- Data de criacao     : 01/07/2014'||chr(10)||'#-- Data de atualizacao : 04/05/2015'||chr(10)||'#-- -----------------------------------------------------------------------------------');
dbms_output.put_line(JBQB || JBQB );


for ljb in (
	select l1.sid,max(l2.ctime) ctime,l1.id1,l1.id2
	from gv$lock l1, gv$lock l2
	where l1.block>0 and l2.block=0 and l1.id1=l2.id1 and l1.id2=l2.id2
	group by l1.sid,l1.id1,l1.id2
	order by 2 asc
) loop

for x in (
	select inst_id,sid,prev_hash_value,sql_hash_value,username,status,osuser,machine,serial#
	from gv$session where sid=ljb.sid
) loop

	dbms_output.put_line('+++++++++++++++++++++++++ BLOQUEADOR +++++++++++++++++++++++++++++++ ');
	dbms_output.put_line('DATABASE INFORMATION:');
	dbms_output.put_line('SID:......................... ' || x.sid);
	dbms_output.put_line('SERIAL#:..................... ' || x.serial#);
	dbms_output.put_line('DATABASE USER:............... ' || x.username);
	dbms_output.put_line('STATUS:...................... ' || x.status);
	DBMS_OUTPUT.PUT_LINE('INSTANCE ID:................. ' || 'NODE ' || x.inst_id || JBQB);

	vtmpm := substr(ljb.ctime/60,1,(INSTR(ljb.ctime/60,'.'))-1);
	if vtmpm is null then
		vtmpm := substr(ljb.ctime/60,1,(INSTR(ljb.ctime/60,','))-1);
		if vtmpm is null then
			vtmpm := ljb.ctime/60;
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

	if ljb.ctime < 60 then
 		dbms_output.put_line('TIME LOCK:................... ' || ljb.ctime || ' SEGUNDO(s)' || JBQB );
 		elsif ljb.ctime < 3600 then
		dbms_output.put_line('TIME LOCK:................... ' || vtmpm || ' MINUTO(s) E ' || (ljb.ctime-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
	elsif ljb.ctime > 3600 then
		dbms_output.put_line('TIME LOCK:................... ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
	end if;

	dbms_output.put_line('S.O INFORMATION:');

   	for xy in (
   			select nvl(spid,0) spid from gv$process p, gv$session s
   			where p.addr = s.paddr and s.sid = x.sid
   	) loop
   		if xy.spid <> 0 then
			dbms_output.put_line('PID:......................... ' || xy.spid);
		end if;
	end loop;

	dbms_output.put_line('S/O USER:.................... ' || x.osuser);
	dbms_output.put_line('MACHINE:..................... ' || x.machine || JBQB);
	dbms_output.put_line('KILL SESSION:');
	dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||''' immediate;' || JBQB);

	dbms_output.put_line('LOCK INFORMATION:');
	if x.sql_hash_value <> 0 then
	dbms_output.put_line('HASH VALUE ATUAL:............ ' || x.sql_hash_value);
	dbms_output.put_line('QUERY TEXT:.................. select sql_text from v$sql where HASH_VALUE=' || x.sql_hash_value || ';' || JBQB);
	else
	dbms_output.put_line('ULTIMO HASH VALUE:........... ' || x.prev_hash_value);
	dbms_output.put_line('QUERY TEXT:.................. select sql_text from v$sql where HASH_VALUE=' || x.prev_hash_value || ';' || JBQB);
	end if;

-- Mostra o tipo do objeto e a quantidade em lock

	for tab_z in
	(
		SELECT distinct O.OBJECT_TYPE FROM gv$locked_object l, DBA_OBJECTS O, gv$session s
		where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
	) loop
		vloop_lock_qtd:=0;

		for tab_y in
		(
			SELECT O.OBJECT_TYPE FROM gv$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
		) loop
			if tab_y.OBJECT_TYPE = tab_z.OBJECT_TYPE then vloop_lock_qtd:= vloop_lock_qtd + 1; end if;
		end loop;
		dbms_output.put_line('QTD DE OBJETOS EM LOCK:...... ' || vloop_lock_qtd || ' ' || tab_z.OBJECT_TYPE || JBQB);

	end loop;

	for tab_z in
	(
		SELECT distinct O.OBJECT_TYPE FROM gv$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
	) loop
		dbms_output.put_line(tab_z.OBJECT_TYPE || '(s) EM LOCK:::::::::::::' );

		for tab_x in
		(
			SELECT O.OBJECT_NAME,O.OWNER FROM gv$locked_object l, DBA_OBJECTS O
			WHERE L.OBJECT_ID = O.OBJECT_ID AND  O.OBJECT_TYPE=tab_z.OBJECT_TYPE AND L.SESSION_ID = x.sid
		) loop
			dbms_output.put_line(tab_x.OWNER || '.' || tab_x.OBJECT_NAME );
		end loop;
	end loop;
	dbms_output.put_line(JBQB || '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ');



	dbms_output.put_line('============================ BLOQUEADO ====================== ');
	for v_block in (
		select s.sid,s.serial#,s.sql_hash_value from gv$session s, gv$lock l
		where s.sid=l.sid and request>0 and l.id1=ljb.id1 and l.id2=ljb.id2
	) loop

		dbms_output.put_line('.... SID:......................... ' || v_block.sid || ' | SERIAL#:... ' || v_block.serial#);
		dbms_output.put_line('.... QUERY TEXT:.................. select sql_text from v$sql where HASH_VALUE=' || v_block.sql_hash_value || ';');
		dbms_output.put_line(JBQB);
	end loop;

end loop;

end loop;


select count(1) into vvalid
from gv$lock l1, gv$lock l2
where l1.block>0 and l1.id1=l2.id1 and l1.id2=l2.id2 order by l2.ctime asc;

if vvalid = 0 then
	dbms_output.put_line( JBQB || JBQB );
	dbms_output.put_line('- ------------------------------------------ -');
	dbms_output.put_line('- NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO -');
	dbms_output.put_line('- ------------------------------------------ -');
	dbms_output.put_line( JBQB || JBQB );
end if;

end;
/





pro
pro
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro
pro



#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuarios que estao usando a tabela informada e seus detalhes
#-- Nome do arquivo     : jbusing_table.sql
#-- Data de criação     : 19/11/2014
#-- ---------------------------------------------------------------------------------------------------------#

set lines 100
set serveroutput on
set echo off
set feedback off

declare

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;
vpid varchar2(2000);

begin

  dbms_output.put_line(chr(10)||chr(10)||'LOCK EM TABELAS'||chr(10));

select upper(instance_name) into vinstance from v$instance;
select upper(name) into vdatabase from v$database;

  dbms_output.put_line(JBQB||JBQB||JBQB);

for x in (
   SELECT s.sid, s.last_call_et, s.WAIT_CLASS, s.status, s.username, s.osuser, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine,o.object_name,DECODE ( l.locked_mode, 0, 'None', 1, 'NoLock', 2, 'Row-Share (SS)', 3, 'Row-Exclusive (SX)', 4, 'Share-Table', 5, 'Share-Row-Exclusive (SSX)', 6, 'Exclusive','[Nothing]')   LOCKED_MODE,o.owner,o.object_type,s.serial# serial
   FROM gv$process p, gv$session s,gv$locked_object l, dba_objects o
   WHERE s.username is not null and l.session_id=s.sid and l.object_id=o.object_id
   group by s.sid, s.serial# , s.WAIT_CLASS,s.last_call_et, s.status, s.username, s.osuser, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine,o.object_name,l.locked_mode,o.owner,o.object_type
   ORDER BY s.last_call_et asc
)loop


  for y in ( SELECT p.spid from gv$process p, gv$session s where s.sid=x.sid and s.serial#=x.serial and p.addr = s.paddr and p.spid is not null) LOOP

    if vpid is not null then
      vpid:=y.spid ||', '|| vpid;
      null;
    else
      vpid:=y.spid;
    end if;
  END LOOP;


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
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpm
      	|| ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmph
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
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd
        	|| ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd
      	|| ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd
      	|| ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  end if;

  dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
  dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);

  dbms_output.put_line('INFORMACOES DA TABELA');
  dbms_output.put_line('DONO DA TABELA:.................. ' || x.owner );
  dbms_output.put_line('NOME DA TABELA:.................. ' || x.object_name || JBQB );

  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S PID:......................... ' || vpid);
  dbms_output.put_line('O/S USER:........................ ' || x.osuser);
  dbms_output.put_line('SERVIDOR:........................ ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state);
  dbms_output.put_line('CLASSE DE ESPERA:................ ' || x.WAIT_CLASS);
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




pro
pro
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro
pro

#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuario(s) ativos e seu tempo de atividade junto com detalhes de sua sessão
#-- Nome do arquivo     : jblast_query.sql
#-- Data de criação     : 28/08/2014
#-- Data de atualização : 05/03/2015
#-- ---------------------------------------------------------------------------------------------------------#

set lines 200
set serveroutput on
set echo off

declare

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);
vnumquery numeric(3):='100';
vretorn varchar2(3):='y';
vpe varchar2(10):='n';

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin

select upper(instance_name) into vinstance from v$instance;
select upper(name) into vdatabase from v$database;

if vnumquery is null then
vnumquery:=10;
end if;

dbms_output.put_line(JBQB||JBQB||JBQB);

for x in (
 select * from (
  SELECT s.sid, s.serial# serial, s.last_call_et, s.sql_id, s.status, s.username, s.osuser, p.spid, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine
  FROM gv$process p, gv$session s
  WHERE p.addr = s.paddr and s.sql_hash_value != 0  and s.username is not null /*and s.status = 'ACTIVE'*/ and audsid != userenv('SESSIONID')
  ORDER BY s.last_call_et desc ) where rownum <vnumquery ORDER BY last_call_et asc
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
  dbms_output.put_line('MAQUINA:......................... ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state || JBQB);

  if x.sql_hash_value <> 0 then
    dbms_output.put_line('SQL HASH VALUE:.................. ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v$sql where HASH_VALUE=' || x.sql_hash_value || ';'||JBQB);

      if upper(vretorn)='Y' then
        for query_loop in (select sql_text from v$sql where HASH_VALUE=x.sql_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_text||chr(10));
        end loop;
        dbms_output.put_line(chr(10));
      end if;

      if upper(vpe)='Y' then
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


    dbms_output.put_line(JBQB||'=============================================================================================='||JBQB);
  end if;

end loop;

SELECT nvl(count(sid),0) into vvalid FROM gv$process p, gv$session s
WHERE p.addr =  s.paddr and s.sql_hash_value is not null and s.sql_hash_value <> 0  and s.username is not null and audsid != userenv('SESSIONID');

if vvalid = 0 then
  dbms_output.put_line(JBQB);
  dbms_output.put_line('NESTE MOMENTO NAO HA USUARIOS EXECUTANDO PROCESSOS NO BANCO DE DADOS.');
  dbms_output.put_line(JBQB);
end if;


end;
/






pro
pro
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro ==================================================================================================================================================
pro
pro

pro =====================
pro JOBs EM EXECUCAO
pro =====================

-- -----------------------------------------------------------------------------------
-- Autor               : johab benicio de oliveira.
-- Descrição           : analisar jobs no banco de dados que estão em execucao
-- Nome do arquivo     : jbdetail_job.sql
-- Data de criação     : 20/05/2015
-- -----------------------------------------------------------------------------------


SET LINES 200;
SET LONG 999;
SET SERVEROUTPUT ON;
SET FEEDBACK OFF;
BEGIN
	DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||CHR(10));

	for y in (select * from dba_jobs_running) loop
	FOR X IN (SELECT JOB,LOG_USER,TO_CHAR(LAST_DATE,'DD/MM/YYYY HH24:MI:SS') LAST_DATE,TO_CHAR(NEXT_DATE,'DD/MM/YYYY HH24:MI:SS') NEXT_DATE,WHAT,FAILURES,BROKEN FROM DBA_JOBS
	where   JOB=y.JOB ORDER BY BROKEN,JOB)  LOOP
		DBMS_OUTPUT.PUT_LINE(CHR(10)||CHR(10)||'=================================================================');
		DBMS_OUTPUT.PUT_LINE('NUMERO DO JOB:.............. '||X.JOB);
		DBMS_OUTPUT.PUT_LINE('USUARIO DONO:............... '||X.LOG_USER);
		DBMS_OUTPUT.PUT_LINE('PROCEDIMENTO EXECUTADO:..... '||X.WHAT);
		DBMS_OUTPUT.PUT_LINE('BLOQUEADO:.................. '||X.BROKEN);
		DBMS_OUTPUT.PUT_LINE('QUANTIDADE DE FALHAS:....... '||X.FAILURES);
		DBMS_OUTPUT.PUT_LINE('ULTIMA EXECUCAO:............ '||X.LAST_DATE);
		DBMS_OUTPUT.PUT_LINE('PROXIMA EXECUCAO:........... '||X.NEXT_DATE||CHR(10));
		DBMS_OUTPUT.PUT_LINE('ACOES:');
		DBMS_OUTPUT.PUT_LINE('EXECUTAR JOB:............... EXEC DBMS_JOB.RUN('||X.JOB||');');
		DBMS_OUTPUT.PUT_LINE('APAGAR JOB:................. EXEC DBMS_JOB.REMOVE('||X.JOB||');');
		IF X.BROKEN = 'N' THEN
			DBMS_OUTPUT.PUT_LINE('DESABILITAR JOB:............ EXEC DBMS_JOB.BROKEN('||X.JOB||', TRUE);');
		ELSE
			DBMS_OUTPUT.PUT_LINE('HABILITAR JOB:.............. EXEC DBMS_JOB.BROKEN('||X.JOB||', FALSE);');
		END IF;
		DBMS_OUTPUT.PUT_LINE('ALTERAR INTERVALO:.......... DBMS_JOB.INTERVAL('||X.JOB||', [INTERVALO])');
	END LOOP;
END LOOP;


END;
/




