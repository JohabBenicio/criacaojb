

-- Apagar todos objetos criados

SELECT 'DROP '||DECODE (OBJECT_TYPE,'SYNONYM','PUBLIC SYNONYM',OBJECT_TYPE)  ||' '||DECODE(OWNER,'PUBLIC',NULL,OWNER||'.')||OBJECT_NAME||DECODE (OBJECT_TYPE,'TABLE',' cascade constraints;',';') COMANDO
FROM DBA_OBJECTS
WHERE owner = 'USR_MONIT_P4T' and object_type!='INDEX';




-- Criar a tablespace mais o usuario com suas grants
create tablespace tbs_monit_p4t datafile '+DGDATA' size 128m autoextend on next 128m maxsize 16g;
create user usr_monit_p4t identified by T30r123 default tablespace tbs_monit_p4t;
grant connect,resource to usr_monit_p4t;

grant select on gv_$sql to usr_monit_p4t;
grant select on gv_$instance to usr_monit_p4t;
grant select on v_$instance to usr_monit_p4t;
grant select on gv_$session to usr_monit_p4t;
grant select on gv_$lock to usr_monit_p4t;
grant select on gv_$locked_object to usr_monit_p4t;
grant select on gv_$process to usr_monit_p4t;
grant select on gv_$open_cursor to usr_monit_p4t;
grant select on dba_objects to usr_monit_p4t;




-- Conecte com o usuario

conn usr_monit_p4t/T30r123

sqlplus usr_monit_p4t/T30r123




-- Criar as tabelas para armazenar os dados coletados.

drop table usr_monit_p4t.tb_lock_snap;
create table usr_monit_p4t.tb_lock_snap (mnlc_id number, mnlc_vdata date) tablespace tbs_monit_p4t;
alter table usr_monit_p4t.tb_lock_snap add constraint pk_tb_lock_snap primary key (mnlc_id);

-- Criar a sequencia
create sequence usr_monit_p4t.seq_lock_snap minvalue 1 maxvalue 99999999 start with 1 increment by 1 nocache cycle;


-- Criar a tabela que armazenará os dados do usuario bloqueador.


drop table usr_monit_p4t.tb_monit_blocker;
create table usr_monit_p4t.tb_monit_blocker (
    MNLC_ID NUMBER,
    MNBLR_ID NUMBER,
    MNBLR_INST_ID NUMBER,
    MNBLR_SID NUMBER,
    MNBLR_SERIAL NUMBER,
    MNBLR_STATUS VARCHAR2(10),
    MNBLR_LAST_CALL_ET NUMBER,
    MNBLR_USERNAME VARCHAR2(30),
    MNBLR_OSUSER VARCHAR2(30),
    MNBLR_MACHINE VARCHAR2(64),
    MNBLR_PROGRAM VARCHAR2(48),
    MNBLR_MODULE VARCHAR2(64),
    MNBLR_SQLID_HISTORY VARCHAR2(4000)
) tablespace tbs_monit_p4t;

alter table usr_monit_p4t.tb_monit_blocker add  constraint pk_monit_blocker primary key (MNLC_ID,MNBLR_ID);
alter table usr_monit_p4t.tb_monit_blocker add  constraint fk_snap_blocker foreign key (MNLC_ID) references usr_monit_p4t.tb_lock_snap (MNLC_ID);
create sequence usr_monit_p4t.seq_monit_blocker minvalue 1 maxvalue 99999999 start with 1 increment by 1 nocache cycle;



-- Criar a tabela que armazenará os dados do usuario bloqueado.

drop table usr_monit_p4t.tb_monit_blocked;
create table usr_monit_p4t.tb_monit_blocked (
    MNLC_ID NUMBER,
    MNBLD_ID NUMBER,
    MNBLD_INST_ID NUMBER,
    MNBLD_SID NUMBER,
    MNBLD_SERIAL NUMBER,
    MNBLD_STATUS VARCHAR2(10),
    MNBLD_LAST_CALL_ET NUMBER,
    MNBLD_USERNAME VARCHAR2(30),
    MNBLD_OSUSER VARCHAR2(30),
    MNBLD_TIME_LOCK number,
    MNBLD_MACHINE VARCHAR2(64),
    MNBLD_PROGRAM VARCHAR2(48),
    MNBLD_MODULE VARCHAR2(64),
    MNBLD_SQLID VARCHAR2(13)
) tablespace tbs_monit_p4t;

alter table usr_monit_p4t.tb_monit_blocked add  constraint pk_monit_blocked primary key (MNLC_ID,MNBLD_ID);
alter table usr_monit_p4t.tb_monit_blocked add  constraint fk_snap_blocked foreign key (MNLC_ID) references usr_monit_p4t.tb_lock_snap (MNLC_ID);
create sequence usr_monit_p4t.seq_monit_blocked minvalue 1 maxvalue 99999999 start with 1 increment by 1 nocache cycle;



-- Criar a tabela que armazenará os dados dos objetos bloqueados.

drop table usr_monit_p4t.tb_monit_lock_table;
create table usr_monit_p4t.tb_monit_lock_table (
    MNLC_ID NUMBER,
    MNBLR_ID NUMBER,
    MNLCTB_OWNER_OBJ varchar2(30),
    MNLCTB_OBJECT_NAME varchar2(128),
    MNLCTB_TYPE_LOCK varchar2(20)
) tablespace tbs_monit_p4t;

alter table usr_monit_p4t.tb_monit_lock_table add  constraint fk_blocked_lock_table foreign key (MNLC_ID,MNBLR_ID) references usr_monit_p4t.tb_monit_blocker (MNLC_ID,MNBLR_ID);


-- Criar a tabela que armazenará o texto das querys

drop table usr_monit_p4t.tb_monit_query;
create table usr_monit_p4t.tb_monit_query (
    MNQR_SQLID varchar2(13),
    MNQR_FULLTEXT long
) tablespace tbs_monit_p4t;






-- Criação da procedure responsavel por coletar os dados.


create or replace procedure usr_monit_p4t.prc_monit_lock is
  TMP_SEG_LOCK number:=900;
  SQLID_HIST varchar2(2000);
  ID_BLOCKER number;
  ID_BLOCKED number;
  ID_SNAP number;
  V_COUNT number;

BEGIN


for loop1 in (
    select distinct l1.sid,
                    l1.inst_id,
                    l1.id1,
                    l1.id2,
                    max(l2.ctime) ctime
    from gv$lock l1, gv$lock l2
    where l1.block>0
      and l2.block=0
      and l1.id1=l2.id1
      and l1.id2=l2.id2
    group by l1.sid,l1.inst_id,l1.id1,l1.id2
    order by 3 asc
) loop


  if loop1.ctime >= TMP_SEG_LOCK then

  select seq_lock_snap.nextval into ID_SNAP from dual;


  insert into usr_monit_p4t.tb_lock_snap (mnlc_id,mnlc_vdata) values (ID_SNAP,to_date(sysdate,'dd/mm/yyyy hh24:mi:ss'));
-- Coleta dos dados do bloqueador.

    for blocker in (
        select sid,
               serial#,
               status,
               last_call_et,
               username,
               osuser,
               machine,
               program,
               module
        from gv$session
        where sid=loop1.sid
          and inst_id=loop1.inst_id
          and username is not null
    ) loop

      select seq_monit_blocker.nextval into ID_BLOCKER from dual;

      for oc in (select sql_id from gv$open_cursor where sid=blocker.sid and user_name=blocker.username and inst_id=loop1.inst_id )
      loop
          for ot in (select distinct sql_id from gv$sql where
              ((upper(SQL_FULLTEXT) like upper('UPDATE %') or upper(SQL_FULLTEXT) like upper('% UPDATE %'))
            or (upper(SQL_FULLTEXT) like upper('DELETE %') or upper(SQL_FULLTEXT) like upper('% DELETE %'))
            or (upper(SQL_FULLTEXT) like upper('LOCK TABLE%') or upper(SQL_FULLTEXT) like upper('% LOCK TABLE %'))) and sql_id=oc.sql_id)
          loop

            if SQLID_HIST is null then
              SQLID_HIST:=ot.sql_id;
            else
              SQLID_HIST:=SQLID_HIST||', '||ot.sql_id;
            end if;

            select count(MNQR_SQLID) into V_COUNT from usr_monit_p4t.tb_monit_query where MNQR_SQLID=ot.sql_id;

            if V_COUNT = 0 then
              insert into usr_monit_p4t.tb_monit_query (MNQR_SQLID,MNQR_FULLTEXT) select sql_id,sql_fulltext from gv$sql where sql_id=ot.sql_id;
              commit;
            end if;


          end loop;
      end loop;

      insert into usr_monit_p4t.tb_monit_blocker
        ( MNLC_ID
         ,MNBLR_ID
         ,MNBLR_INST_ID
         ,MNBLR_SID
         ,MNBLR_SERIAL
         ,MNBLR_STATUS
         ,MNBLR_LAST_CALL_ET
         ,MNBLR_USERNAME
         ,MNBLR_OSUSER
         ,MNBLR_MACHINE
         ,MNBLR_PROGRAM
         ,MNBLR_MODULE
         ,MNBLR_SQLID_HISTORY
        )
      values
        ( ID_SNAP,
          ID_BLOCKER,
          loop1.inst_id,
          blocker.sid,
          blocker.serial#,
          blocker.status,
          blocker.last_call_et,
          blocker.username,
          blocker.osuser,
          blocker.machine,
          blocker.program,
          blocker.module,
          SQLID_HIST
        );

        for tab in
        (
            select o.object_name,o.owner,
            Decode(l.LOCKED_MODE, 0, 'None',1, 'Null (NULL)',2, 'Row-S (SS)',3, 'Row-X (SX)',4, 'Share (S)',5, 'S/Row-X (SSX)',6, 'Exclusive (X)',l.locked_mode) locked_mode from gv$locked_object l, dba_objects o
            where l.object_id = o.object_id and l.session_id = loop1.sid and l.inst_id=loop1.inst_id
        ) loop
          insert into usr_monit_p4t.tb_monit_lock_table (MNLC_ID,MNBLR_ID,MNLCTB_OWNER_OBJ,MNLCTB_OBJECT_NAME,MNLCTB_TYPE_LOCK)
            values (ID_SNAP,ID_BLOCKER,tab.owner,tab.OBJECT_NAME,tab.LOCKED_MODE);
        end loop;

        commit;
    end loop;

-- Coletar os dados dos usuarios bloqueados.

  for loop2 in (
      select l2.sid,
             l2.inst_id,
             l2.ctime
      from gv$lock l1, gv$lock l2
      where l1.block>0
        and l2.block=0
        and l2.id1=loop1.id1
        and l2.id2=loop1.id2
        and l1.sid=loop1.sid
      order by 3 asc
  ) loop
      for blocked in (
          select sid,
                 serial#,
                 status,
                 last_call_et,
                 username,
                 osuser,
                 machine,
                 program,
                 module,
                 sql_id
          from gv$session
          where sid=loop2.sid
            and inst_id=loop2.inst_id
            and username is not null
      ) loop

        select seq_monit_blocked.nextval into ID_BLOCKED from dual;

        insert into usr_monit_p4t.tb_monit_blocked
          ( MNLC_ID
           ,MNBLD_ID
           ,MNBLD_INST_ID
           ,MNBLD_SID
           ,MNBLD_SERIAL
           ,MNBLD_STATUS
           ,MNBLD_LAST_CALL_ET
           ,MNBLD_USERNAME
           ,MNBLD_OSUSER
           ,MNBLD_TIME_LOCK
           ,MNBLD_MACHINE
           ,MNBLD_PROGRAM
           ,MNBLD_MODULE
           ,MNBLD_SQLID
          )
        values
          ( ID_SNAP,
            ID_BLOCKED,
            loop2.inst_id,
            blocked.sid,
            blocked.serial#,
            blocked.status,
            blocked.last_call_et,
            blocked.username,
            blocked.osuser,
            loop2.ctime,
            blocked.machine,
            blocked.program,
            blocked.module,
            blocked.sql_id
          );
          commit;
      end loop;
    end loop;
  end if;
end loop;



-- Purge do histórico.


end;
/















-- Conecte com o usuario

conn usr_monit_p4t/T30r123

sqlplus usr_monit_p4t/T30r123



-- JOB responsavel por disparar a execução da procedure Every 5 Minutes Starting at the Next 5 Minute Interval

    variable jobno number;
    variable instno number;
    BEGIN
      SELECT instance_number INTO :instno FROM v$instance;
      DBMS_JOB.SUBMIT(:jobno, 'prc_monit_lock;', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/5)+1)*5)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/5)+1)*5)/(24*60)', TRUE, :instno);
      COMMIT;
    END;
    /


-- JOB responsavel por disparar a execução da procedure Every 15 Minutes Starting at the Next 15 Minute Interval

    variable jobno number;
    variable instno number;
    BEGIN
      SELECT instance_number INTO :instno FROM v$instance;
      DBMS_JOB.SUBMIT(:jobno, 'prc_monit_lock;', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/15)+1)*15)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/15)+1)*15)/(24*60)', TRUE, :instno);
      COMMIT;
    END;
    /


-- JOB responsavel por disparar a execução da procedure Every 30 Minutes Starting at the Next 30 Minute Interval

    variable jobno number;
    variable instno number;
    BEGIN
      SELECT instance_number INTO :instno FROM v$instance;
      DBMS_JOB.SUBMIT(:jobno, 'prc_monit_lock;', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/30)+1)*30)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/30)+1)*30)/(24*60)', TRUE, :instno);
      COMMIT;
    END;
    /





-- Consulta para ajudar na identificação do job validar a execução do mesmo.

set lines 300 pages 2000
col what for a20
select job,what,instance,LAST_DATE,NEXT_DATE from user_jobs;


exec DBMS_JOB.RUN(6);



-- Validar os dados inseridos

set lines 300 pages 2000 long 99999

select * from usr_monit_p4t.tb_monit_blocker order by 1;
select * from usr_monit_p4t.tb_monit_blocked order by 1;
select * from usr_monit_p4t.tb_lock_snap order by 1;
select * from usr_monit_p4t.tb_monit_query order by 1;
select * from usr_monit_p4t.tb_monit_lock_table order by 1;




desc usr_monit_p4t.tb_monit_blocker





SYS@mat12 > desc usr_monit_p4t.tb_monit_blocker
 Name                                                                                   Null?    Type
 -------------------------------------------------------------------------------------- -------- ----------------------------------------------------------
 MNLC_ID                                                                                NOT NULL NUMBER
 MNBLR_ID                                                                               NOT NULL NUMBER
 MNBLR_INST_ID                                                                                   NUMBER
 MNBLR_SID                                                                                       NUMBER
 MNBLR_SERIAL                                                                                    NUMBER
 MNBLR_STATUS                                                                                    VARCHAR2(10)
 MNBLR_LAST_CALL_ET                                                                              NUMBER
 MNBLR_USERNAME                                                                                  VARCHAR2(30)
 MNBLR_OSUSER                                                                                    VARCHAR2(30)
 MNBLR_MACHINE                                                                                   VARCHAR2(64)
 MNBLR_PROGRAM                                                                                   VARCHAR2(48)
 MNBLR_MODULE                                                                                    VARCHAR2(64)
 MNBLR_SQLID_HISTORY                                                                             VARCHAR2(4000)




select distinct MNBLR_INST_ID,MNBLR_SID,MNBLR_SERIAL,MNBLR_USERNAME,MNBLR_OSUSER,MNBLR_MACHINE,MNBLR_PROGRAM,MNBLR_MODULE,MNBLR_SQLID_HISTORY from usr_monit_p4t.tb_monit_blocker;








