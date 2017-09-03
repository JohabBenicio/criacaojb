-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Identificar lock e seus detalhes.
-- Nome do arquivo     : jblock.sql
-- Data de criação     : 01/07/2014
-- Data de atualização : 23/09/2014
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 200 
Set pages 200
set long 999
set feedback off

declare

v_query_max_lock varchar2(20);
vloop_lock_qtd varchar2(20);
vvalid numeric(3);
JBQB VARCHAR2(2) := CHR(13) || CHR(10);

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin

dbms_output.put_line(JBQB || JBQB || JBQB || JBQB);

for x in (
	select s.inst_id,s.sid,s.serial#,s.prev_hash_value,s.sql_hash_value,s.username,s.status, s.osuser,s.machine,
	l.ctime,l.id1,l.id2
	from gv$session s,gv$lock l where s.sid=l.sid and l.block>0 order by l.ctime asc
) loop
	

	dbms_output.put_line('+++++++++++++++++++++++++ BLOQUEADOR +++++++++++++++++++++++++++++++ ');
	dbms_output.put_line('DATABASE INFORMATION:');
	dbms_output.put_line('SID:......................... ' || x.sid);
	dbms_output.put_line('SERIAL#:..................... ' || x.serial#);
	dbms_output.put_line('DATABASE USER:............... ' || x.username);
	dbms_output.put_line('STATUS:...................... ' || x.status);
	DBMS_OUTPUT.PUT_LINE('INSTANCE ID:................. ' || 'NODE ' || x.inst_id || JBQB);
	
	vtmpm := substr(x.ctime/60,1,(INSTR(x.ctime/60,'.'))-1);
	if vtmpm is null then
		vtmpm := substr(x.ctime/60,1,(INSTR(x.ctime/60,','))-1);
		if vtmpm is null then
			vtmpm := x.ctime/60;
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

	if x.ctime < 60 then
 		dbms_output.put_line('TIME LOCK:................... ' || x.ctime || ' SEGUNDO(s)' || JBQB );
 		elsif x.ctime < 3600 then
		dbms_output.put_line('TIME LOCK:................... ' || vtmpm || ' MINUTO(s) E ' || (x.ctime-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
	elsif x.ctime > 3600 then
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
		where s.sid=l.sid and request>0 and l.id1=x.id1 and l.id2=x.id2
	) loop	

		dbms_output.put_line('.... SID:......................... ' || v_block.sid || ' | SERIAL#:... ' || v_block.serial#);
		dbms_output.put_line('.... QUERY TEXT:.................. select sql_text from v$sql where HASH_VALUE=' || v_block.sql_hash_value || ';');
		dbms_output.put_line(JBQB);
	end loop;
	
end loop;


select nvl(count(s1.sid),0) into vvalid
from  gv$lock l1,  gv$session s1,  gv$lock l2,  gv$session s2 
where s1.sid=l1.sid and s2.sid=l2.sid and l1.BLOCK=1 and l2.request > 0 and l1.id1 = l2.id1 and l2.id2 = l2.id2;
	
if vvalid = 0 then
	dbms_output.put_line( JBQB || JBQB );
	dbms_output.put_line('- ------------------------------------------ -');
	dbms_output.put_line('- NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO -');
	dbms_output.put_line('- ------------------------------------------ -');
	dbms_output.put_line( JBQB || JBQB );
end if;

end;
/
