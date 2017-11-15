


######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################


exp \'/ as sysdba\' file=usr_monit_p4t_lock OWNER=usr_monit_p4t STATISTICS=none

scp oracle@10.201.1.171:/u02/backup/prod/logico/usr_monit_p4t_lock.* /tmp

chmod 777 /tmp/usr_monit_p4t_lock*

scp Johab@10.53.40.4:/tmp/usr_monit_p4t_lock.dmp Documents/trabalhos/

imp \'sys/oracle12c@TESTE_PDB as sysdba\' file=usr_monit_p4t_lock.dmp fromuser=usr_monit_p4t

imp \'/ as sysdba\' file=usr_monit_p4t_lock.dmp fromuser=usr_monit_p4t


-- Apagar todos objetos criados

SELECT 'DROP '||DECODE (OBJECT_TYPE,'SYNONYM','PUBLIC SYNONYM',OBJECT_TYPE)  ||' '||DECODE(OWNER,'PUBLIC',NULL,OWNER||'.')||OBJECT_NAME||DECODE (OBJECT_TYPE,'TABLE',' cascade constraints;',';') COMANDO
FROM DBA_OBJECTS
WHERE owner = 'USR_MONIT_P4T' and object_type!='INDEX';




-- Criar a tablespace mais o usuario com suas grants
create tablespace tbs_monit_p4t datafile '+DGDATA' size 128m autoextend on next 128m maxsize 16g;
create user usr_monit_p4t identified by T30r123 default tablespace tbs_monit_p4t;
grant connect,resource to usr_monit_p4t;
alter user usr_monit_p4t quota unlimited on tbs_monit_p4t;


grant select on gv_$sql to usr_monit_p4t;
grant select on gv_$instance to usr_monit_p4t;
grant select on v_$instance to usr_monit_p4t;
grant select on gv_$session to usr_monit_p4t;
grant select on gv_$lock to usr_monit_p4t;
grant select on gv_$locked_object to usr_monit_p4t;
grant select on gv_$process to usr_monit_p4t;
grant select on gv_$open_cursor to usr_monit_p4t;
grant select on dba_objects to usr_monit_p4t;
grant select on dba_cons_columns to usr_monit_p4t;
grant select on dba_constraints to usr_monit_p4t;
grant select on dba_ind_columns to usr_monit_p4t;





-- Conecte com o usuario

conn usr_monit_p4t/T30r123

sqlplus usr_monit_p4t/T30r123

USR_MONIT_P4T


-- Criar as tabelas para armazenar os dados coletados.

drop table usr_monit_p4t.tb_lock_snap cascade constraints;

create table usr_monit_p4t.tb_lock_snap (
  MNLC_ID NUMBER,
  MNLC_VDATA VARCHAR2(21)
) tablespace tbs_monit_p4t;

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
  MNBLR_SQL_ATUAL VARCHAR2(64),
  MNBLR_SQLID_HISTORY VARCHAR2(4000)
) tablespace tbs_monit_p4t;

alter table usr_monit_p4t.tb_monit_blocker add  constraint pk_monit_blocker primary key (MNBLR_ID);

alter table usr_monit_p4t.tb_monit_blocker add  constraint fk_snap_blocker
  foreign key (MNLC_ID) references usr_monit_p4t.tb_lock_snap (MNLC_ID);

drop sequence usr_monit_p4t.seq_monit_blocker;
create sequence usr_monit_p4t.seq_monit_blocker minvalue 1 maxvalue 99999999 start with 1 increment by 1 nocache cycle;



-- Criar a tabela que armazenará os dados do usuario bloqueado.

drop table usr_monit_p4t.tb_monit_blocked;
create table usr_monit_p4t.tb_monit_blocked (
  MNLC_ID NUMBER,
  MNBLR_ID NUMBER,
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

alter table usr_monit_p4t.tb_monit_blocked add  constraint pk_monit_blocked primary key (MNBLD_ID);

alter table usr_monit_p4t.tb_monit_blocked add  constraint fk_snap_blocked
  foreign key (MNLC_ID) references usr_monit_p4t.tb_lock_snap (MNLC_ID);

alter table usr_monit_p4t.tb_monit_blocked add  constraint fk_blocked_blocker
  foreign key (MNBLR_ID) references usr_monit_p4t.tb_monit_blocker (MNBLR_ID);

drop sequence usr_monit_p4t.seq_monit_blocked;
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

alter table usr_monit_p4t.tb_monit_lock_table add  constraint fk_blocked_lock_table
  foreign key (MNBLR_ID) references usr_monit_p4t.tb_monit_blocker (MNBLR_ID);


-- Criar a tabela que armazenará o texto das querys

drop table usr_monit_p4t.tb_monit_query;
create table usr_monit_p4t.tb_monit_query (
  MNQR_SQLID varchar2(13),
  MNQR_FULLTEXT varchar2(4000)
) tablespace tbs_monit_p4t;




-- Criação da procedure responsavel por coletar os dados.

create or replace procedure usr_monit_p4t.prc_monit_lock (TMP_SEG_LOCK number) is
  SQLID_HIST varchar2(2000);
  ID_BLOCKER number;
  ID_BLOCKED number;
  ID_SNAP number;
  V_COUNT number;
  V_VALID_INSERT number;

BEGIN


for loop1 in (
    select distinct l1.sid,
                    l1.inst_id,
                    l1.id1,
                    l1.id2,
                    max(l2.ctime) ctime
    from gv$lock l1, gv$lock l2, gv$session s1, gv$session s2
    where l1.block>0
      and l2.block=0
      and l1.id1=l2.id1
      and l1.id2=l2.id2
      and s1.sid=l1.sid
      and s2.sid=l2.sid
      and s1.inst_id=l1.inst_id
      and s2.inst_id=l2.inst_id
      and s1.username is not null
      and s2.username is not null
    group by l1.sid,l1.inst_id,l1.id1,l1.id2
    order by ctime
) loop

  ---------------------------------------------------------------------------------------------------------
  select count(*)
  into V_VALID_INSERT
  from usr_monit_p4t.tb_lock_snap snp, usr_monit_p4t.tb_monit_blocker b1
  where b1.MNBLR_SID                    = loop1.sid
    and b1.MNBLR_INST_ID                = loop1.inst_id
    and to_char(sysdate,'yyyymmddhh24') = to_char(to_date(snp.MNLC_VDATA,'dd/mm/yyyy hh24:mi:ss'),'yyyymmddhh24') ;

  if loop1.ctime >= TMP_SEG_LOCK and V_VALID_INSERT = 0 then

    if ID_SNAP is null then
      select seq_lock_snap.nextval into ID_SNAP from dual;
      insert into usr_monit_p4t.tb_lock_snap (mnlc_id,mnlc_vdata) values (ID_SNAP,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));
    end if;

-- Coleta dos dados do bloqueador.

    for blocker in (
        select sid,
               serial#,
               status,
               nvl(sql_id,prev_sql_id) sql_id,
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


        -- Inserir o historico de execucoes.

        for oc in (
          select sql_id
          from gv$open_cursor
          where sid=blocker.sid
            and user_name=blocker.username
            and inst_id=loop1.inst_id
        ) loop

          for ot in (select distinct sql_id from gv$sql where
            (
              (
                 upper(SQL_FULLTEXT) like upper('UPDATE %')
              or upper(SQL_FULLTEXT) like upper('% UPDATE %')
              )
            or
              (
                 upper(SQL_FULLTEXT) like upper('DELETE %')
              or upper(SQL_FULLTEXT) like upper('% DELETE %')
              )
            or
              (
                 upper(SQL_FULLTEXT) like upper('LOCK TABLE%')
              or upper(SQL_FULLTEXT) like upper('% LOCK TABLE %')
              )
            )
            and sql_id=oc.sql_id
            and upper(SQL_FULLTEXT) not like upper('%USER$%')
          ) loop

            if SQLID_HIST is null then
              SQLID_HIST:=ot.sql_id;
            else
              SQLID_HIST:=SQLID_HIST||', '||ot.sql_id;
            end if;

            select count(MNQR_SQLID) into V_COUNT from usr_monit_p4t.tb_monit_query where MNQR_SQLID=ot.sql_id;

            if V_COUNT = 0 then
              insert into usr_monit_p4t.tb_monit_query
                (
                  MNQR_SQLID,
                  MNQR_FULLTEXT
                ) select sql_id,sql_fulltext from gv$sql where sql_id=ot.sql_id;
              commit;
            end if;

          end loop;
        end loop;

        -- Inserir os dados do BLOQUEADOR.

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
           ,MNBLR_SQL_ATUAL
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
            blocker.sql_id,
            SQLID_HIST
          );
        commit;


        -- Inserir os dados das TABELAS bloqueadas.

        for tab in
        (
          select
            o.object_name,
            o.owner,
            Decode(l.LOCKED_MODE, 0, 'None'
                                , 1, 'Null (NULL)'
                                , 2, 'Row-S (SS)'
                                , 3, 'Row-X (SX)'
                                , 4, 'Share (S)'
                                , 5, 'S/Row-X (SSX)'
                                , 6, 'Exclusive (X)'
                                , l.locked_mode
                  ) locked_mode
          from gv$locked_object l, dba_objects o
          where l.object_id  = o.object_id
            and l.session_id = loop1.sid
            and l.inst_id    = loop1.inst_id
        ) loop
          insert into usr_monit_p4t.tb_monit_lock_table
            ( MNLC_ID,
              MNBLR_ID,
              MNLCTB_OWNER_OBJ,
              MNLCTB_OBJECT_NAME,
              MNLCTB_TYPE_LOCK
            )
            values
            ( ID_SNAP,
              ID_BLOCKER,
              tab.owner,
              tab.OBJECT_NAME,
              tab.LOCKED_MODE
            );
        end loop;
        commit;

    end loop;

    -- Coletar os dados dos USUARIOS BLOQUEADOS.

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
        (  MNLC_ID
          ,MNBLR_ID
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
          ID_BLOCKER,
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

        select count(MNQR_SQLID) into V_COUNT from usr_monit_p4t.tb_monit_query where MNQR_SQLID=blocked.sql_id;

        if V_COUNT = 0 then
          insert into usr_monit_p4t.tb_monit_query
            (
              MNQR_SQLID,
              MNQR_FULLTEXT
            ) select sql_id,sql_fulltext from gv$sql where sql_id=blocked.sql_id;
          commit;
        end if;

        commit;
      end loop;
    end loop;

  elsif loop1.ctime >= TMP_SEG_LOCK and V_VALID_INSERT > 0 then

    -- Atualiza o TEMPO DE LOCK das sessoes bloqueadas

    for upd_b in (
      select b1.MNLC_ID, b1.MNBLR_ID, b1.MNBLR_SID, b1.MNBLR_SERIAL, b1.MNBLR_INST_ID
      into V_VALID_INSERT
      from usr_monit_p4t.tb_lock_snap snp, usr_monit_p4t.tb_monit_blocker b1
      where b1.MNBLR_SID                    = loop1.sid
        and b1.MNBLR_INST_ID                = loop1.inst_id
        and to_char(sysdate,'yyyymmddhh24') = to_char(to_date(snp.MNLC_VDATA,'dd/mm/yyyy hh24:mi:ss'),'yyyymmddhh24')
    ) loop

      for loop2 in (
        select l2.sid,
               l2.inst_id,
               l2.ctime,
               b.MNBLD_ID
        from gv$lock l1, gv$lock l2, gv$session s, usr_monit_p4t.tb_monit_blocked b
        where l1.block>0
          and l2.block=0
          and l2.id1=loop1.id1
          and l2.id2=loop1.id2
          and l1.sid=loop1.sid
          and s.sid=l2.sid
          and s.inst_id=l2.inst_id
          and upd_b.MNBLR_INST_ID=L1.INST_ID
          and upd_b.MNBLR_SID=L1.SID
          and b.MNBLD_SID=s.sid
          and b.MNBLD_SERIAL=s.serial#
          and b.MNBLD_INST_ID=s.inst_id
        order by 3 asc
      ) loop

        update usr_monit_p4t.tb_monit_blocked set MNBLD_TIME_LOCK=loop2.ctime where MNBLD_ID=loop2.MNBLD_ID;
        commit;

      end loop;
    end loop;

  end if;

end loop;


-- Purge do histórico.




end;
/












exec prc_monit_lock(30);


-- Conecte com o usuario

conn usr_monit_p4t/T30r123

sqlplus usr_monit_p4t/T30r123


sqlplus usr_monit_p4t/T30r123@teste_pdb


exec prc_monit_lock(30);




-- JOB responsavel por disparar a execução da procedure Every 5 Minutes Starting at the Next 5 Minute Interval

    variable jobno number;
    variable instno number;
    BEGIN
      SELECT instance_number INTO :instno FROM v$instance;
      DBMS_JOB.SUBMIT(:jobno, 'prc_monit_lock(300);', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/5)+1)*5)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/5)+1)*5)/(24*60)', TRUE, :instno);
      COMMIT;
    END;
    /



-- JOB responsavel por disparar a execução da procedure Every 10 Minutes Starting at the Next 5 Minute Interval

    variable jobno number;
    variable instno number;
    BEGIN
      SELECT instance_number INTO :instno FROM v$instance;
      DBMS_JOB.SUBMIT(:jobno, 'prc_monit_lock(300);', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/10)+1)*10)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/10)+1)*10)/(24*60)', TRUE, :instno);
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
























select to_char(to_date(MNLC_VDATA,'dd/mm/yyyy hh24:mi:ss'),'yyyymmddhh24') from tb_lock_snap;





################################################################################################
################################################################################################
################################################################################################

Tabelas:
TB_LOCK_SNAP
 * Conterá os horários dos locks. (Coluna MNLC_ID se encontra em todas as tabelas)

TB_MONIT_BLOCKER
 * Conterá os dados do usuário bloqueador.

TB_MONIT_BLOCKED
 * Conterá os dados do usuário bloqueado.

TB_MONIT_LOCK_TABLE
 * Conterá os dados das tabelas bloqueadas pelo usuário.

TB_MONIT_QUERY
 * Conterá o corpo das querys utilizadas.

################################################################################################
################################################################################################
################################################################################################


-- Buscar os dados do usuario bloqueador

select distinct
       b1.MNBLR_ID            "ID DO BLOQUEADOR"                                  ,
       snp.MNLC_VDATA         "DATA"                                              ,
       b1.MNBLR_USERNAME      "USUARIO NO BANCO"                                  ,
       rpad(b1.MNBLR_SID,6,' ')||' | '||lpad(b1.MNBLR_SERIAL,6,' ')  "SID E SERIAL"                         ,
       b1.MNBLR_OSUSER        "USUARIO NO S.O."                                   ,
       decode(b1.MNBLR_PROGRAM,null,'unknown',b1.MNBLR_PROGRAM)        "PROGRAMA" ,
       decode(b1.MNBLR_MODULE,null,'unknown', b1.MNBLR_MODULE)         "MODULO"   ,
       b1.MNBLR_STATUS        "STATUS"                                            ,
       b1.MNBLR_LAST_CALL_ET  "TEMPO COM STATUS"                                  ,
       nvl(b1.MNBLR_SQL_ATUAL,'none')           "SQL EXECUTADO NO MOMENTO/ULTIMA EXECUCAO"
--       , b1.MNBLR_SQLID_HISTORY "HISTORICO DE EXECUCOES"
from tb_lock_snap snp, tb_monit_blocker b1
where snp.MNLC_ID=b1.MNLC_ID
order by b1.MNBLR_ID;


-- Buscar os dados do usuario bloqueado

select distinct
       b1.MNBLR_ID              "ID DO BLOQUEADOR"       ,
       snp.MNLC_VDATA           "DATA"                   ,
       rpad(b2.MNBLD_SID,6,' ')||' | '||lpad(b2.MNBLD_SERIAL,6,' ')  "SID E SERIAL"                         ,
       b2.MNBLD_USERNAME        "USUARIO NO BANCO"       ,
       b2.MNBLD_OSUSER          "USUARIO NO S.O."        ,
       b2.MNBLD_MACHINE         "MAQUINA"                ,
       decode(b2.MNBLD_PROGRAM,null,'unknown',b2.MNBLD_PROGRAM)        "PROGRAMA"               ,
       decode(b2.MNBLD_MODULE,null,'unknown',b2.MNBLD_MODULE)         "MODULO"                 ,
       b2.MNBLD_STATUS         "STATUS"                 ,
       b2.MNBLD_SQLID          "SQL BLOQUEADO"
from tb_monit_blocker b1, tb_monit_blocked b2, tb_lock_snap snp
where snp.MNLC_ID=b2.MNLC_ID
  and b1.MNBLR_ID=b2.MNBLR_ID
order by b1.MNBLR_ID;



-- Listar as querys

select distinct MNQR_SQLID SQL_ID, MNQR_FULLTEXT "CORPO DA QUERY" from usr_monit_p4t.tb_monit_query;


-- Listar as tabelas bloqueadas por bloqueador.

select distinct t.MNBLR_ID   "ID DO BLOQUEADOR",
       t.MNLCTB_OWNER_OBJ    "USUARIO DONO DA TABELA",
       t.MNLCTB_OBJECT_NAME  "TABELA ENVOLVIDA",
       t.MNLCTB_TYPE_LOCK    "TIPO DE LOCK"
from tb_monit_blocker b1, tb_monit_lock_table t
where b1.MNLC_ID=t.MNLC_ID
  and b1.MNBLR_ID=t.MNBLR_ID
order by t.MNBLR_ID;






-- Listar as FKs sem indices nas tabelas bloqueadas.


set lines 200 pages 999
col COLUMNS for a90
set colsep ';'



select distinct owner "USUARIO DONO DA TABELA", table_name "NOME DA TABELA", constraint_name "NOME DA CONTRAINST FK",
       cname1 || nvl2(cname2,','||cname2,null) ||
       nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) ||
       nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) ||
       nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null)
              "COLUNAS DO FK"
    from ( select b.owner,
                  b.table_name,
                  b.constraint_name,
                  max(decode( position, 1, column_name, null )) cname1,
                  max(decode( position, 2, column_name, null )) cname2,
                  max(decode( position, 3, column_name, null )) cname3,
                  max(decode( position, 4, column_name, null )) cname4,
                  max(decode( position, 5, column_name, null )) cname5,
                  max(decode( position, 6, column_name, null )) cname6,
                  max(decode( position, 7, column_name, null )) cname7,
                  max(decode( position, 8, column_name, null )) cname8,
                  count(*) col_cnt
             from dba_cons_columns a, dba_constraints b, usr_monit_p4t.tb_monit_lock_table c
           where  a.constraint_name = b.constraint_name
              and b.constraint_type = 'R'
              and a.owner=c.MNLCTB_OWNER_OBJ
              and a.table_name=c.MNLCTB_OBJECT_NAME
            group by b.owner, b.table_name, b.constraint_name
         ) cons
   where col_cnt > ALL
           ( select count(*)
               from dba_ind_columns i
              where i.table_name = cons.table_name
                and i.column_name in (cname1, cname2, cname3, cname4,
                                      cname5, cname6, cname7, cname8 )
                and i.column_position <= cons.col_cnt
             group by i.index_name
           )
           order by owner,table_name;



















