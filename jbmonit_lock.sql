

teste_pdb =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = TCP)(HOST = 127.0.0.1)(PORT = 1521))
    (CONNECT_DATA =
      (SERVER = DEDICATED)
      (SERVICE_NAME = teste_pdb)
    )
  )


create user teste identified by oracle;
alter user teste quota unlimited on users;
grant connect,resource to teste;


create user teste_1 identified by oracle;
alter user teste_1 quota unlimited on users;
grant connect,resource to teste_1;


create table teste1 (id number);



COLUMN PDB_NAME FORMAT A15
 
SELECT PDB_ID, PDB_NAME, STATUS FROM DBA_PDBS ORDER BY PDB_ID;

COLUMN NAME FORMAT A15
COLUMN RESTRICTED FORMAT A10
COLUMN OPEN_TIME FORMAT A30
 
SELECT NAME, OPEN_MODE, RESTRICTED, OPEN_TIME FROM V$PDBS;


SQL> alter pluggable database teste_pdb open read write;



sqlplus teste1/oracle@teste_pdb



conn usr_monit_p4t/T30r123@teste_pdb

usr_monit_p4t.tb_monit_lock_table


######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################
######################################################################################################################################################




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
create table usr_monit_p4t.tb_lock_snap (MNLC_ID NUMBER, MNLC_VDATA VARCHAR2(21)) tablespace tbs_monit_p4t;
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
    order by 3 asc
) loop

  if loop1.ctime >= TMP_SEG_LOCK then

    if ID_SNAP is null then
      select seq_lock_snap.nextval into ID_SNAP from dual;
      insert into usr_monit_p4t.tb_lock_snap (mnlc_id,mnlc_vdata) values (ID_SNAP,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));
    end if;

    select seq_monit_blocker.nextval into ID_BLOCKER from dual;

-- Coleta dos dados do bloqueador.

    for blocker in (
        select sid,
               serial#,
               status,
               sql_id,
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

        for tab in
        (
            select o.object_name,o.owner,
            Decode(l.LOCKED_MODE, 0, 'None',1, 'Null (NULL)',2, 'Row-S (SS)',3, 'Row-X (SX)',4, 'Share (S)',5, 'S/Row-X (SSX)',6, 'Exclusive (X)',l.locked_mode) locked_mode from gv$locked_object l, dba_objects o
            where l.object_id = o.object_id and l.session_id = loop1.sid and l.inst_id=loop1.inst_id
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


sqlplus usr_monit_p4t/T30r123@teste_pdb


exec prc_monit_lock(30);


-- JOB responsavel por disparar a execução da procedure Every 5 Minutes Starting at the Next 5 Minute Interval

    variable jobno number;
    variable instno number;
    BEGIN
      SELECT instance_number INTO :instno FROM v$instance;
      DBMS_JOB.SUBMIT(:jobno, 'prc_monit_lock(30);', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/5)+1)*5)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/5)+1)*5)/(24*60)', TRUE, :instno);
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




select distinct a,MNBLR_INST_ID,
                a.MNBLR_SID,
                a.MNBLR_SERIAL,
                a.MNBLR_USERNAME,
                a.MNBLR_OSUSER,
                a.MNBLR_MACHINE,
                a.MNBLR_PROGRAM,
                a.MNBLR_MODULE,
                a.MNBLR_SQLID_HISTORY
                b.
from usr_monit_p4t.tb_monit_blocker a, usr_monit_p4t.tb_lock_snap b;




select * from usr_monit_p4t.tb_lock_snap order by 1;


















select owner, table_name, constraint_name,
       cname1 || nvl2(cname2,','||cname2,null) ||
       nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) ||
       nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) ||
       nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null)
              columns
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
             from (select substr(table_name,1,30) table_name,
                          substr(constraint_name,1,30) constraint_name,
                          substr(column_name,1,30) column_name,
                          position
                     from dba_cons_columns ) a, dba_constraints b, usr_monit_p4t.tb_monit_lock_table c
           where  a.constraint_name = b.constraint_name
              and b.constraint_type = 'R'
              and b.owner=c.MNLCTB_OWNER_OBJ
              and b.table_name=c.MNLCTB_OBJECT_NAME
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
           and owner not in ('SYS','SYSTEM','OUTLN','SCOTT','ADAMS','JONES','CLARK','BLAKE','HR','OE','SH','DEMO','ANONYMOUS','AURORA$ORB$UNAUTHENTICATED','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','PERFSTAT','TRACESVR','TSMSYS','XDB','SYSMAN','WKSYS','WKPROXY','OLAPSYS','OWBSYS','MGMT_VIEW','SI_INFORMTN_SCHEMA','WMSYS')
           order by owner,table_name;






select to_char(to_date(MNLC_VDATA),'yyyymmddhh24') from tb_lock_snap;


select to_char(to_date(MNLC_VDATA,'dd/mm/yyyy hh24:mi:ss'),'yyyymmddhh24') from tb_lock_snap;


select distinct 
       b1.MNBLR_ID            "ID DO BLOQUEADOR"                                  ,
       snp.MNLC_VDATA         "DATA"                                              ,
       b1.MNBLR_USERNAME      "USUARIO NO BANCO"                                  ,
       b1.MNBLR_OSUSER        "USUARIO NO S.O."                                   ,
       decode(b1.MNBLR_PROGRAM,null,'unknown',b1.MNBLR_PROGRAM)        "PROGRAMA" ,
       decode(b1.MNBLR_MODULE,null,'unknown', b1.MNBLR_MODULE)         "MODULO"   ,
       b1.MNBLR_STATUS        "STATUS"                                            ,
       b1.MNBLR_LAST_CALL_ET  "TEMPO COM STATUS"                                  ,
       nvl(b1.MNBLR_SQL_ATUAL,'none')           "SQL EXECUTADO NO MOMENTO"        ,
       b1.MNBLR_SQLID_HISTORY "HISTORICO DE EXECUCOES"
from tb_lock_snap snp, tb_monit_blocker b1
where snp.MNLC_ID=b1.MNLC_ID
order by b1.MNBLR_ID;



select distinct 
       b1.MNBLR_ID              "ID DO BLOQUEADOR"       ,
       snp.MNLC_VDATA           "DATA"                   ,
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





select distinct b1.MNLC_ID   "ID DO BLOQUEADOR",
       t.MNLCTB_OWNER_OBJ    "USUARIO DONO DA TABELA",
       t.MNLCTB_OBJECT_NAME  "TABELA ENVOLVIDA",
       t.MNLCTB_TYPE_LOCK    "TIPO DE LOCK"
from tb_monit_blocker b1, tb_monit_lock_table t
where b1.MNLC_ID=t.MNLC_ID
  and b1.MNBLR_ID=t.MNBLR_ID
order by b1.MNLC_ID;




select distinct
       t.MNLCTB_OWNER_OBJ    "USUARIO DONO DA TABELA",
       t.MNLCTB_OBJECT_NAME  "TABELA ENVOLVIDA"
from tb_monit_blocker b1, tb_monit_lock_table t
where b1.MNLC_ID=t.MNLC_ID
order by 1,2;





