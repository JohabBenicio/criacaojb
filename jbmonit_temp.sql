
-- Apagar o usuario e tablespace.

drop user usr_monit_p4t cascade;
drop tablespace tbs_monit_temp including contents and datafiles;

-- Criar a tablespace mais o usuario com suas grants
create tablespace tbs_monit_temp datafile '+DGDATA' size 1g autoextend on next 128m maxsize 16g;
create user usr_monit_p4t identified by T30r123 default tablespace tbs_monit_temp;
grant connect,resource to usr_monit_p4t;

grant select on gv_$sql to usr_monit_p4t;
grant select on gv$tempseg_usage to usr_monit_p4t;
grant select on v_$instance to usr_monit_p4t;
grant select on gv_$session to usr_monit_p4t;


-- Criar as tabelas para armazenar os dados coletados.

create table usr_monit_p4t.tb_temp_snap (mntm_id number, mntm_vdata varchar2(21)) tablespace tbs_monit_temp;
alter table usr_monit_p4t.tb_temp_snap add constraint pk_tb_temp_snap primary key (mntm_id);

create table usr_monit_p4t.tb_monit_temp (
    mntm_id number,
    mntm_id_upd number,
    inst_id number,
    sid number,
    serial# number,
    username varchar2(30),
    owner varchar2(30),
    sqlhash number,
    sql_id varchar2(13),
    tablespace varchar2(31),
    contents varchar2(9),
    segtype varchar2(9),
    segfile number,
    segblk number,
    extents number,
    blocks number,
    segrfno number
) tablespace tbs_monit_temp;

alter table usr_monit_p4t.tb_monit_temp add  constraint fk_monit_temp_02 foreign key (MNTM_ID) references usr_monit_p4t.tb_temp_snap (MNTM_ID);


-- Criar a sequencia
create sequence usr_monit_p4t.seq_monit_temp minvalue 1 maxvalue 10000 start with 1 increment by 1 nocache cycle;


-- Criar a tabela que armazenará o texto das querys

drop table usr_monit_p4t.tb_monit_query;
create table usr_monit_p4t.tb_monit_query (
  sqlid varchar2(13),
  fulltext varchar2(4000)
) tablespace tbs_monit_temp;

-- Procedure responsavel por inserir os dados nas tabelas criadas.

create or replace procedure usr_monit_p4t.prc_monit_temp is
    id_line number;
    v_sqltext long;
    valid number;
    V_VALID_INSERT number;
begin

  select count(*) into valid from gv$tempseg_usage;
  
  if valid > 0 then
  
    select seq_monit_temp.nextval into id_line from dual;
    insert into usr_monit_p4t.tb_temp_snap (MNTM_ID,MNTM_VDATA) values (id_line,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));
    
    for x in (
        select 
          t.inst_id,
          t.username,
          t.user,
          t.sqlhash,
          t.sql_id,
          t.tablespace,
          t.contents,
          t.segtype,
          t.segfile#,
          t.segblk#,
          t.extents,
          t.blocks,
          t.segrfno#,
          s.sid,
          s.serial#
        from gv$tempseg_usage t, gv$session s 
        where  s.saddr=t.session_addr and s.inst_id=t.inst_id
      ) loop
    
      -- Consulta para validar se os dados ja foram inseridos
      select count(*)
        into V_VALID_INSERT
        from usr_monit_p4t.tb_temp_snap snp, usr_monit_p4t.tb_monit_temp b1
        where b1.mntm_id                    = snp.mntm_id
          and b1.inst_id                    = x.inst_id
          and b1.sid                        = x.sid 
          and b1.serial#                    = x.serial#
          and b1.blocks                     < x.blocks
          and to_char(sysdate,'yyyymmddhh24') = to_char(to_date(snp.mntm_vdata,'dd/mm/yyyy hh24:mi:ss'),'yyyymmddhh24') ;
  
      BEGIN
        select count(*) into valid from usr_monit_p4t.tb_monit_query where sqlid=x.sql_id;
        if valid = 0 then
          for y in (select sql_fulltext from gv$sql where sql_id=x.sql_id) loop
            v_sqltext:=y.sql_fulltext;
          end loop;
          insert into usr_monit_p4t.tb_monit_query (sqlid,fulltext) values (x.sql_id,v_sqltext);
          commit;
        end if;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      
      if V_VALID_INSERT > 0 then
        update usr_monit_p4t.tb_monit_temp set blocks=x.blocks, mntm_id_upd=id_line where inst_id = x.inst_id and sid = x.sid and serial# = x.serial#;
        commit;
      else
    
        insert into usr_monit_p4t.tb_monit_temp 
          ( mntm_id,
            mntm_id_upd,
            inst_id,
            username,
            owner,
            sqlhash,
            sql_id,
            tablespace,
            contents,
            segtype,
            segfile,
            segblk,
            extents,
            blocks,
            segrfno
          ) values 
          ( id_line,
            0,
            x.inst_id,
            x.username,
            x.user,
            x.sqlhash,
            x.sql_id,
            x.tablespace,
            x.contents,
            x.segtype,
            x.segfile#,
            x.segblk#,
            x.extents,
            x.blocks,
            x.segrfno#
          );  
  
      end if;
    end loop;
    
    commit;
    
  end if;

end;
/



-- Conecte com o usuario

conn usr_monit_p4t/T30r123

sqlplus usr_monit_p4t/T30r123


-- JOB responsavel por disparar a execução da procedure.


variable jobno number;
variable instno number;
BEGIN
  SELECT instance_number INTO :instno FROM v$instance;
  DBMS_JOB.SUBMIT(:jobno, 'prc_monit_temp;', trunc(sysdate,'HH24')+((floor(to_number(to_char(sysdate,'MI'))/15)+1)*15)/(24*60), 'trunc(sysdate,''HH24'')+((floor(to_number(to_char(sysdate,''MI''))/15)+1)*15)/(24*60)', TRUE, :instno);
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
select * from usr_monit_p4t.tb_temp_snap order by 1;
select * from usr_monit_p4t.tb_monit_temp order by 1;




set lines 300 pages 2000 long 99999
select * from usr_monit_p4t.tb_temp_snap order by 1;
col username for a10
select MNTM_ID,INST_ID,USERNAME,OWNER,SQLHASH,SQL_ID,TABLESPACE,CONTENTS,SEGTYPE,SEGFILE,SEGBLK,EXTENTS,BLOCKS,SEGRFNO
from usr_monit_p4t.tb_monit_temp order by 1;




MNTM_ID,INST_ID,USERNAME,OWNER,SQLHASH,SQL_ID,TABLESPACE,CONTENTS,SEGTYPE,SEGFILE,SEGBLK,EXTENTS,BLOCKS,SEGRFNO








   MNTM_ID    INST_ID USERNAME   OWNER                             SQLHASH SQL_ID        TABLESPACE                      CONTENTS  SEGTYPE      SEGFILE     SEGBLK    EXTENTS     BLOCKS    SEGRFNO
---------- ---------- ---------- ------------------------------ ---------- ------------- ------------------------------- --------- --------- ---------- ---------- ---------- ---------- ----------
         5          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    4171520        305      19520          1
         6          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    4171520        305      19520          1
        23          2 EMS2MULT   usr_monit_p4t             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        23          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        23          2 EMS2MULT   usr_monit_p4t             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        24          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        24          2 EMS2MULT   usr_monit_p4t             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        24          2 EMS2MULT   usr_monit_p4t             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        25          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        25          2 EMS2MULT   usr_monit_p4t             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        25          2 EMS2MULT   usr_monit_p4t             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        26          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        26          2 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        26          2 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        27          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        27          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        27          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        28          1 EMS2MULT   usr_monit_p4t             1828684283 3h5av6tqgz0gv TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        28          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        28          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        30          1 EMS2MULT   usr_monit_p4t             2041802459 djug9wxwv6vqv TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        31          1 EMS2MULT   usr_monit_p4t              810974967 8xapx6ns5czrr TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        32          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        33          1 EMS2MULT   usr_monit_p4t             1828684283 3h5av6tqgz0gv TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        34          1 EMS2MULT   usr_monit_p4t             2060937343 1s8fprtxdfu3z TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        35          1 EMS2MULT   usr_monit_p4t             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        36          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        37          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        38          1 EMS2MULT   usr_monit_p4t             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        67          1 SYS        usr_monit_p4t              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY LOB_DATA         129    2151232          2        128          1
        67          1 SYS        usr_monit_p4t              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY DATA             129    2081088          1         64          1
        67          1 SYS        usr_monit_p4t              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY DATA             129    3235904          5        320          1
        67          1 SYS        usr_monit_p4t              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY INDEX            129    2518528          6        384          1
        67          1 SYS        usr_monit_p4t              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY LOB_INDEX        129    2112128          1         64          1
        68          1 SYS        usr_monit_p4t              693605571 1at2aksnpg563 TEMP                            TEMPORARY LOB_DATA         129    2151232         37       2368          1
        68          1 SYS        usr_monit_p4t              693605571 1at2aksnpg563 TEMP                            TEMPORARY DATA             129    2081088          1         64          1
        68          1 SYS        usr_monit_p4t              693605571 1at2aksnpg563 TEMP                            TEMPORARY DATA             129    3235904          5        320          1
        68          1 SYS        usr_monit_p4t              693605571 1at2aksnpg563 TEMP                            TEMPORARY INDEX            129    2518528          6        384          1
        68          1 SYS        usr_monit_p4t              693605571 1at2aksnpg563 TEMP                            TEMPORARY LOB_INDEX        129    2112128          1         64          1
        97          1 EMS2MULT   usr_monit_p4t              286253278 133xy8w8hzs6y TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
        98          1 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
        99          1 EMS2MULT   usr_monit_p4t             1516274623 0790y65d610xz TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       100          1 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       101          1 EMS2MULT   usr_monit_p4t              912560578 a2csg7sv694f2 TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       102          1 EMS2MULT   usr_monit_p4t             1643330295 801zsndhz6frr TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       102          1 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       103          1 EMS2MULT   usr_monit_p4t             2041802459 djug9wxwv6vqv TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       103          1 EMS2MULT   usr_monit_p4t             1415274977 717rgq9a5qsg1 TEMP                            TEMPORARY SORT             129    2717952        306      19584          1
       104          1 EMS2MULT   usr_monit_p4t              824472302 4c4wy5csk8wrf TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       104          1 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    2717952        306      19584          1
       105          1 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       105          1 EMS2MULT   usr_monit_p4t             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    2717952        306      19584          1
       106          1 EMS2MULT   usr_monit_p4t              912560578 a2csg7sv694f2 TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       107          1 EMS2MULT   usr_monit_p4t             1516274623 0790y65d610xz TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       108          1 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       109          1 EMS2MULT   usr_monit_p4t              912560578 a2csg7sv694f2 TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       110          1 EMS2MULT   usr_monit_p4t             1828684283 3h5av6tqgz0gv TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       116          2 EMS2MULT   usr_monit_p4t             1457512466 b6ddyn5bdzs0k TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       117          2 EMS2MULT   usr_monit_p4t             2870744801 91bz7afpjs5r1 TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       117          2 EMS2MULT   usr_monit_p4t             1457512466 b6ddyn5bdzs0k TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       118          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       118          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       119          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       119          2 EMS2MULT   usr_monit_p4t              824472302 4c4wy5csk8wrf TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       120          2 EMS2MULT   usr_monit_p4t             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       120          2 EMS2MULT   usr_monit_p4t             1516274623 0790y65d610xz TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       121          2 EMS2MULT   usr_monit_p4t             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       122          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       123          2 EMS2MULT   usr_monit_p4t             1446099387 1yqmn9jb33fdv TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       124          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       3968         35       2240          4
       124          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129       3520         35       2240          1
       124          1 EMS2MULT   usr_monit_p4t              824472302 4c4wy5csk8wrf TEMP                            TEMPORARY SORT             131       1152        306      19584          3
       124          2 EMS2MULT   usr_monit_p4t             1133241548 1u2j51j1srt6c TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       124          2 EMS2MULT   usr_monit_p4t             1446099387 1yqmn9jb33fdv TEMP                            TEMPORARY SORT             131       3968        306      19584          3
       125          2 EMS2MULT   usr_monit_p4t             3567691983 9yxshngaada6g TEMP                            TEMPORARY SORT             132       3968         35       2240          4
       125          2 EMS2MULT   usr_monit_p4t              286253278 133xy8w8hzs6y TEMP                            TEMPORARY SORT             131       3968        306      19584          3
       125          2 EMS2MULT   usr_monit_p4t             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       125          2 EMS2MULT   usr_monit_p4t             3567691983 9yxshngaada6g TEMP                            TEMPORARY SORT             129       3520         35       2240          1
       125          1 EMS2MULT   usr_monit_p4t             1415274977 717rgq9a5qsg1 TEMP                            TEMPORARY SORT             131       1216        307      19648          3






