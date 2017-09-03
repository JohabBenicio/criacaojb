-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Dados de loks de sessoes
-- Nome do arquivo     : jblock.sql
-- Data de criação     : 01/07/2014
-- Data de atualização : 08/08/2017
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 200 pages 2000 long 999999
col sql_fulltext for a200

declare
    v_query_max_lock varchar2(20);
    vloop_lock_qtd   varchar2(20);
    vvalid           varchar2(90);
    jbqb             varchar2(90):= chr(13) || chr(10);
    vtmps            varchar2(90):=0;
    vtmpm            varchar2(90):=0;
    vtmph            varchar2(90):=0;
    vtmpd            varchar2(90):=0;
    v_hist           varchar2(20):='&HISTORICO_EXEC_S_N';
    v_tables         varchar2(20):='&MOSTRAR_TABELAS_BLOQU_S_N';
    v_killsess       varchar2(20):='&MOSTRAR_KILL_SESSION';
    l_sid            number; l_osuser number;
    l_serial         number; l_type   number;
    l_username       number; l_sqlid  number;
    v_version_db     number;
begin
if v_hist is null then
    v_hist:='N';
end if;
if v_tables is null then
    v_tables:='N';
end if;

select count(*) into v_version_db from v$version where upper(BANNER) like '%DATABASE%' and (upper(BANNER) like '%11G%' or upper(BANNER) like '%12C%');

dbms_output.put_line(JBQB || JBQB );
dbms_output.put_line('#-- '||rpad('-',88,'-'));
dbms_output.put_line('#-- Autor               : Johab Benicio de Oliveira.'||chr(10)||'#-- Descricao           : Dados de loks de sessoes. ');
dbms_output.put_line('#-- Nome do arquivo     : jblock.sql'||chr(10)||'#-- Data de criacao     : 01/07/2014'||chr(10)||'#-- Data de atualizacao : 09/05/2017');
dbms_output.put_line('#-- '||rpad('-',88,'-')||chr(10));

for ljb in (
    select l1.sid,max(l2.ctime) ctime,l1.id1,l1.id2,l1.TYPE,l1.inst_id
    from gv$lock l1, gv$lock l2
    where l1.block>0 and l2.block=0 and l1.id1=l2.id1 and l1.id2=l2.id2
    group by l1.sid,l1.id1,l1.id2,l1.TYPE,l1.inst_id
    order by 2 asc
) loop

for x in (
    select s.last_call_et,s.saddr,s.sid,s.prev_hash_value,s.sql_hash_value,s.username,s.status,s.osuser,s.machine,s.program,s.serial#,i.instance_name,i.host_name,s.sql_id,s.inst_id,to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time
    from gv$session s, gv$instance i where sid=ljb.sid and s.inst_id=i.inst_id and s.inst_id=ljb.inst_id and username is not null
) loop
vvalid:= x.username;


    dbms_output.put_line(rpad('+',40,'+')||' BLOQUEADOR '||rpad('+',40,'+')||chr(10));
    dbms_output.put_line('DATABASE INFORMATION:');
    dbms_output.put_line(rpad('USUARIO BLOQUEADOR:',29,'.')||chr(32)||lpad(x.username,25,' ')||chr(32)||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
    dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,25,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
    dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,25,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name||chr(10) );
    dbms_output.put_line('LOGON TIME:.................. '||x.logon_time);

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

-- Forma de acesso

    dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
    dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);

-- Dados SO

    dbms_output.put_line('S.O INFORMATION:');

    for xy in (
            select nvl(spid,0) spid from gv$process p, gv$session s
            where p.addr = s.paddr and s.sid = x.sid and p.inst_id=s.inst_id and s.inst_id=x.inst_id
    ) loop
        if xy.spid <> 0 then
            dbms_output.put_line('PID:......................... ' || xy.spid);
        end if;
    end loop;

    dbms_output.put_line('S/O USER:.................... ' || x.osuser);
    dbms_output.put_line('MACHINE:..................... ' || x.machine || JBQB);

-- Dados do lock

if x.sql_hash_value > 0 then
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('TIPO DO LOCK:..... ' || ljb.TYPE);
    dbms_output.put_line('HASH ATUAL:....... ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT: '||chr(10)||' select sql_fulltext from gv$sql where sql_id=''' || x.sql_id || ''';' || JBQB);
else
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('Sessao inativa ha '||x.last_call_et||' segundos.');
end if;

if upper(v_hist) = 'S' or upper(v_hist) = 'Y' then
    dbms_output.put_line(chr(10)||'HISTORICO DE EXECUCAO: ');
    dbms_output.put_line('QUERY TEXT');

        for oc in (select SQL_ID from gv$open_cursor where sid=x.sid and user_name=x.username )
        LOOP
            for ot in (select distinct sql_text from v$sql where
                   ((upper(SQL_FULLTEXT) like upper('UPDATE %') or upper(SQL_FULLTEXT) like upper('% UPDATE %'))
                or (upper(SQL_FULLTEXT) like upper('DELETE %') or upper(SQL_FULLTEXT) like upper('% DELETE %'))
                or (upper(SQL_FULLTEXT) like upper('LOCK TABLE%') or upper(SQL_FULLTEXT) like upper('% LOCK TABLE %'))) and SQL_ID=oc.SQL_ID)
            LOOP
                    dbms_output.put_line('select sql_fulltext from v$sql where SQL_ID='|| chr(39) || oc.SQL_ID || chr(39) || ';');
            END LOOP;

        END LOOP;
end if;

-- Mostra o tipo do objeto e a quantidade em lock

    for tab_z in
    (
        SELECT distinct O.OBJECT_TYPE FROM gv$locked_object l, DBA_OBJECTS O, gv$session s
        where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid and s.inst_id=x.inst_id
    ) loop
        vloop_lock_qtd:=0;

        for tab_y in
        (
            SELECT O.OBJECT_TYPE FROM gv$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
        ) loop
            if tab_y.OBJECT_TYPE = tab_z.OBJECT_TYPE then vloop_lock_qtd:= vloop_lock_qtd + 1; end if;
        end loop;
        dbms_output.put_line(chr(10)||'QTD DE OBJETOS EM LOCK:...... ' || vloop_lock_qtd || ' ' || tab_z.OBJECT_TYPE || JBQB);

    end loop;

if upper(v_tables) = 'S' or upper(v_tables) = 'Y' then
    for tab_z in
    (
        SELECT distinct O.OBJECT_TYPE FROM gv$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
    ) loop

        dbms_output.put_line(tab_z.OBJECT_TYPE || '(s) EM LOCK:::::::::::::' );
        for tab_x in
        (
            SELECT O.OBJECT_NAME,O.OWNER,
            Decode(l.LOCKED_MODE, 0, 'None',1, 'Null (NULL)',2, 'Row-S (SS)',3, 'Row-X (SX)',4, 'Share (S)',5, 'S/Row-X (SSX)',6, 'Exclusive (X)',l.LOCKED_MODE) LOCKED_MODE FROM gv$locked_object l, DBA_OBJECTS O
            WHERE L.OBJECT_ID = O.OBJECT_ID AND  O.OBJECT_TYPE=tab_z.OBJECT_TYPE AND L.SESSION_ID = x.sid
        ) loop
            dbms_output.put_line(rpad(tab_x.OWNER || '.' || tab_x.OBJECT_NAME||chr(32),50,'-') || '> ' || tab_x.LOCKED_MODE);
        end loop;
    end loop;
end if;

if upper(v_killsess) = 'S' or upper(v_killsess) = 'Y' then
    dbms_output.put_line(chr(10)||'KILL SESSION:');
    if v_version_db = 0 then
        dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||''' immediate;' || JBQB);
    else
        dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||',@'||x.inst_id||''' immediate;' || JBQB);
    end if;
end if;

    dbms_output.put_line(chr(10)||rpad('+',92,'+')||chr(10));

select max(length(s.sid)) ,max(length(s.serial#)) ,max(length(s.username)) ,max(length(s.osuser)), max(length(l.type)),max(length(s.sql_id))
into l_sid, l_serial, l_username, l_osuser, l_type, l_sqlid from gv$session s, gv$lock l
where s.sid=l.sid and l.id1=ljb.id1 and l.id2=ljb.id2 and l.block=0 and s.username is not null;

    dbms_output.put_line('============================ BLOQUEADO ============================ ');
    for v_block in (
        select s.inst_id,s.sid,s.serial#,s.sql_id,l.type,s.username,s.osuser,l.ctime from gv$session s, gv$lock l
        where s.sid=l.sid and l.id1=ljb.id1 and l.id2=ljb.id2 and l.block=0 and s.username is not null order by l.ctime desc
    ) loop

        dbms_output.put_line('.... SID: ' || rpad(v_block.sid,l_sid,' ') || ' | SERIAL#: ' || rpad(v_block.serial#,l_serial,' ') || ' | Tipo do Lock: '||rpad(v_block.type,l_type,' ')||' | S/O USER: '||rpad(v_block.osuser,l_osuser,' ') || ' | USER DB: '||  rpad(nvl(v_block.username,'- - - - - - - -'),l_username,' ')|| ' | SQL_ID: '||rpad(nvl(v_block.sql_id,'- - - - - - - '),l_sqlid,' ')||' | INSTANCIA: '||v_block.inst_id||' | TEMPO DE LOCK: '||v_block.ctime||' seg.');
    end loop;
dbms_output.put_line(JBQB || JBQB );
end loop;

end loop;


if vvalid is null then
    dbms_output.put_line('- ------------------------------------------ -');
    dbms_output.put_line('- NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO -');
    dbms_output.put_line('- ------------------------------------------ -');
    dbms_output.put_line( JBQB || JBQB );
end if;

end;
/
