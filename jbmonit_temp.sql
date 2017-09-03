

-- Criar a tablespace mais o usuario com suas grants
create tablespace tbs_monit_temp datafile '+DGDATA' size 1g autoextend on next 128m maxsize 16g;
create user usr_monit_temp_p4t identified by T30r123 default tablespace tbs_monit_temp;
grant connect,resource to usr_monit_temp_p4t;

grant select on gv_$sql to usr_monit_temp_p4t;
grant select on gv$tempseg_usage to usr_monit_temp_p4t;
grant select on v_$instance to usr_monit_temp_p4t;


-- Criar as tabelas para armazenar os dados coletados.

create table usr_monit_temp_p4t.tb_monit_temp_01 (mntm_id number, mntm_vdata varchar2(30)) tablespace tbs_monit_temp;
alter table usr_monit_temp_p4t.tb_monit_temp_01 add constraint pk_tb_monit_temp_01 primary key (mntm_id);

create table usr_monit_temp_p4t.tb_monit_temp_02 (
    MNTM_ID NUMBER,
    INST_ID NUMBER,
    USERNAME VARCHAR2(30),
    OWNER VARCHAR2(30),
    SQLHASH number,
    SQL_ID VARCHAR2(13),
    TABLESPACE VARCHAR2(31),
    CONTENTS VARCHAR2(9),
    SEGTYPE VARCHAR2(9),
    SEGFILE NUMBER,
    SEGBLK NUMBER,
    EXTENTS NUMBER,
    BLOCKS NUMBER,
    SEGRFNO NUMBER,
    SQL_FULLTEXT long
) tablespace tbs_monit_temp;

alter table usr_monit_temp_p4t.tb_monit_temp_02 add  constraint fk_monit_temp_02 foreign key (MNTM_ID) references usr_monit_temp_p4t.tb_monit_temp_01 (MNTM_ID);


-- Criar a sequencia
create sequence usr_monit_temp_p4t.seq_monit_temp minvalue 1 maxvalue 10000 start with 1 increment by 1 nocache cycle;


-- Procedure responsavel por inserir os dados nas tabelas criadas.

create or replace procedure usr_monit_temp_p4t.prc_monit_temp is
    id_line number;
    v_sqltext long;
begin

select seq_monit_temp.nextval into id_line from dual;
insert into usr_monit_temp_p4t.tb_monit_temp_01 (MNTM_ID,MNTM_VDATA) values (id_line,to_char(sysdate,'dd/mm/yyyy hh24:mi:ss'));

for x in (select inst_id,username,user,sqlhash,sql_id,tablespace,contents,segtype,segfile#,segblk#,extents,blocks,segrfno# from gv$tempseg_usage) loop

    for y in (select sql_fulltext from gv$sql where sql_id=x.sql_id) loop
        v_sqltext:=y.sql_fulltext;
    end loop;

    insert into usr_monit_temp_p4t.tb_monit_temp_02 (MNTM_ID,INST_ID,USERNAME,OWNER,SQLHASH,SQL_ID,TABLESPACE,CONTENTS,SEGTYPE,SEGFILE,SEGBLK,EXTENTS,BLOCKS,SEGRFNO,SQL_FULLTEXT) values (id_line,x.INST_ID,x.USERNAME,x.USER,x.SQLHASH,x.SQL_ID,x.TABLESPACE,x.CONTENTS,x.SEGTYPE,x.SEGFILE#,x.SEGBLK#,x.EXTENTS,x.BLOCKS,x.SEGRFNO#,v_sqltext);

end loop;

commit;


end;
/



-- Conecte com o usuario

conn usr_monit_temp_p4t/T30r123

sqlplus usr_monit_temp_p4t/T30r123


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
select * from usr_monit_temp_p4t.tb_monit_temp_01 order by 1;
select * from usr_monit_temp_p4t.tb_monit_temp_02 order by 1;




set lines 300 pages 2000 long 99999
select * from usr_monit_temp_p4t.tb_monit_temp_01 order by 1;
col username for a10
select MNTM_ID,INST_ID,USERNAME,OWNER,SQLHASH,SQL_ID,TABLESPACE,CONTENTS,SEGTYPE,SEGFILE,SEGBLK,EXTENTS,BLOCKS,SEGRFNO
from usr_monit_temp_p4t.tb_monit_temp_02 order by 1;




MNTM_ID,INST_ID,USERNAME,OWNER,SQLHASH,SQL_ID,TABLESPACE,CONTENTS,SEGTYPE,SEGFILE,SEGBLK,EXTENTS,BLOCKS,SEGRFNO








   MNTM_ID    INST_ID USERNAME   OWNER                             SQLHASH SQL_ID        TABLESPACE                      CONTENTS  SEGTYPE      SEGFILE     SEGBLK    EXTENTS     BLOCKS    SEGRFNO
---------- ---------- ---------- ------------------------------ ---------- ------------- ------------------------------- --------- --------- ---------- ---------- ---------- ---------- ----------
         5          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    4171520        305      19520          1
         6          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    4171520        305      19520          1
        23          2 EMS2MULT   USR_MONIT_TEMP_P4T             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        23          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        23          2 EMS2MULT   USR_MONIT_TEMP_P4T             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        24          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        24          2 EMS2MULT   USR_MONIT_TEMP_P4T             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        24          2 EMS2MULT   USR_MONIT_TEMP_P4T             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        25          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        25          2 EMS2MULT   USR_MONIT_TEMP_P4T             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        25          2 EMS2MULT   USR_MONIT_TEMP_P4T             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        26          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        26          2 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        26          2 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        27          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        27          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        27          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        28          1 EMS2MULT   USR_MONIT_TEMP_P4T             1828684283 3h5av6tqgz0gv TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        28          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4170304         35       2240          1
        28          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4175168         35       2240          1
        30          1 EMS2MULT   USR_MONIT_TEMP_P4T             2041802459 djug9wxwv6vqv TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        31          1 EMS2MULT   USR_MONIT_TEMP_P4T              810974967 8xapx6ns5czrr TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        32          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        33          1 EMS2MULT   USR_MONIT_TEMP_P4T             1828684283 3h5av6tqgz0gv TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        34          1 EMS2MULT   USR_MONIT_TEMP_P4T             2060937343 1s8fprtxdfu3z TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        35          1 EMS2MULT   USR_MONIT_TEMP_P4T             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        36          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        37          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        38          1 EMS2MULT   USR_MONIT_TEMP_P4T             4195316567 9vhzmw3x0ywur TEMP                            TEMPORARY SORT             129    2154304        291      18624          1
        67          1 SYS        USR_MONIT_TEMP_P4T              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY LOB_DATA         129    2151232          2        128          1
        67          1 SYS        USR_MONIT_TEMP_P4T              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY DATA             129    2081088          1         64          1
        67          1 SYS        USR_MONIT_TEMP_P4T              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY DATA             129    3235904          5        320          1
        67          1 SYS        USR_MONIT_TEMP_P4T              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY INDEX            129    2518528          6        384          1
        67          1 SYS        USR_MONIT_TEMP_P4T              829320316 cvnwa70sqwv3w TEMP                            TEMPORARY LOB_INDEX        129    2112128          1         64          1
        68          1 SYS        USR_MONIT_TEMP_P4T              693605571 1at2aksnpg563 TEMP                            TEMPORARY LOB_DATA         129    2151232         37       2368          1
        68          1 SYS        USR_MONIT_TEMP_P4T              693605571 1at2aksnpg563 TEMP                            TEMPORARY DATA             129    2081088          1         64          1
        68          1 SYS        USR_MONIT_TEMP_P4T              693605571 1at2aksnpg563 TEMP                            TEMPORARY DATA             129    3235904          5        320          1
        68          1 SYS        USR_MONIT_TEMP_P4T              693605571 1at2aksnpg563 TEMP                            TEMPORARY INDEX            129    2518528          6        384          1
        68          1 SYS        USR_MONIT_TEMP_P4T              693605571 1at2aksnpg563 TEMP                            TEMPORARY LOB_INDEX        129    2112128          1         64          1
        97          1 EMS2MULT   USR_MONIT_TEMP_P4T              286253278 133xy8w8hzs6y TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
        98          1 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
        99          1 EMS2MULT   USR_MONIT_TEMP_P4T             1516274623 0790y65d610xz TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       100          1 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       101          1 EMS2MULT   USR_MONIT_TEMP_P4T              912560578 a2csg7sv694f2 TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       102          1 EMS2MULT   USR_MONIT_TEMP_P4T             1643330295 801zsndhz6frr TEMP                            TEMPORARY SORT             129    2112128        249      15936          1
       102          1 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       103          1 EMS2MULT   USR_MONIT_TEMP_P4T             2041802459 djug9wxwv6vqv TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       103          1 EMS2MULT   USR_MONIT_TEMP_P4T             1415274977 717rgq9a5qsg1 TEMP                            TEMPORARY SORT             129    2717952        306      19584          1
       104          1 EMS2MULT   USR_MONIT_TEMP_P4T              824472302 4c4wy5csk8wrf TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       104          1 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    2717952        306      19584          1
       105          1 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       105          1 EMS2MULT   USR_MONIT_TEMP_P4T             4223328215 0q24h07xvpryr TEMP                            TEMPORARY SORT             129    2717952        306      19584          1
       106          1 EMS2MULT   USR_MONIT_TEMP_P4T              912560578 a2csg7sv694f2 TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       107          1 EMS2MULT   USR_MONIT_TEMP_P4T             1516274623 0790y65d610xz TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       108          1 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       109          1 EMS2MULT   USR_MONIT_TEMP_P4T              912560578 a2csg7sv694f2 TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       110          1 EMS2MULT   USR_MONIT_TEMP_P4T             1828684283 3h5av6tqgz0gv TEMP                            TEMPORARY SORT             129    2122304        109       6976          1
       116          2 EMS2MULT   USR_MONIT_TEMP_P4T             1457512466 b6ddyn5bdzs0k TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       117          2 EMS2MULT   USR_MONIT_TEMP_P4T             2870744801 91bz7afpjs5r1 TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       117          2 EMS2MULT   USR_MONIT_TEMP_P4T             1457512466 b6ddyn5bdzs0k TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       118          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       118          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       119          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       119          2 EMS2MULT   USR_MONIT_TEMP_P4T              824472302 4c4wy5csk8wrf TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       120          2 EMS2MULT   USR_MONIT_TEMP_P4T             2414186525 bfhu2ry7yb40x TEMP                            TEMPORARY SORT             129    4193472        191      12224          1
       120          2 EMS2MULT   USR_MONIT_TEMP_P4T             1516274623 0790y65d610xz TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       121          2 EMS2MULT   USR_MONIT_TEMP_P4T             1460694784 acpj9mdbj0vs0 TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       122          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       123          2 EMS2MULT   USR_MONIT_TEMP_P4T             1446099387 1yqmn9jb33fdv TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       124          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       3968         35       2240          4
       124          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             129       3520         35       2240          1
       124          1 EMS2MULT   USR_MONIT_TEMP_P4T              824472302 4c4wy5csk8wrf TEMP                            TEMPORARY SORT             131       1152        306      19584          3
       124          2 EMS2MULT   USR_MONIT_TEMP_P4T             1133241548 1u2j51j1srt6c TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       124          2 EMS2MULT   USR_MONIT_TEMP_P4T             1446099387 1yqmn9jb33fdv TEMP                            TEMPORARY SORT             131       3968        306      19584          3
       125          2 EMS2MULT   USR_MONIT_TEMP_P4T             3567691983 9yxshngaada6g TEMP                            TEMPORARY SORT             132       3968         35       2240          4
       125          2 EMS2MULT   USR_MONIT_TEMP_P4T              286253278 133xy8w8hzs6y TEMP                            TEMPORARY SORT             131       3968        306      19584          3
       125          2 EMS2MULT   USR_MONIT_TEMP_P4T             2449444025 d4984b68zz35t TEMP                            TEMPORARY SORT             132       4032        191      12224          4
       125          2 EMS2MULT   USR_MONIT_TEMP_P4T             3567691983 9yxshngaada6g TEMP                            TEMPORARY SORT             129       3520         35       2240          1
       125          1 EMS2MULT   USR_MONIT_TEMP_P4T             1415274977 717rgq9a5qsg1 TEMP                            TEMPORARY SORT             131       1216        307      19648          3






