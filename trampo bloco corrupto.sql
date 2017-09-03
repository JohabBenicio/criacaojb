select * from v$database_block_corruption;

     FILE#     BLOCK#     BLOCKS CORRUPTION_CHANGE# CORRUPTIO
---------- ---------- ---------- ------------------ ---------
         7    1299474          1                  0 FRACTURED

col OBJ_CORROMP for a50

select segment_type,owner||'.'||segment_name "OBJ_CORROMP" from dba_extents where file_id = 4 and 27427 between block_id and block_id+blocks -1;



select segment_type,owner||'.'||segment_name "OBJ_CORROMP" from dba_extents where file_id = 7 and 1299474 between block_id and block_id+blocks -1;



SEGMENT_TYPE       OBJ_CORROMP
------------------ --------------------------------------------------
INDEX              APOLO.FK_MOV_ESTQ#1


ALTER INDEX APOLO.FK_MOV_ESTQ#1 REBUILD ONLINE;



 select dbms_metadata.get_ddl('INDEX','FK_MOV_ESTQ#1','APOLO') from dual;



 CREATE INDEX "APOLO"."FK_MOV_ESTQ#1" ON "APOLO"."MOV_ESTQ" ("TIPOLANCCOD")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  STORAGE(INITIAL 65536 NEXT 1048576 MINEXTENTS 1 MAXEXTENTS 2147483645
  PCTINCREASE 0 FREELISTS 1 FREELIST GROUPS 1 BUFFER_POOL DEFAULT)
  TABLESPACE "APOLO_INDEX";


set lines 200

select OWNER,OBJECT_NAME,OBJECT_TYPE from dba_objects where  OBJECT_NAME='FK_MOV_ESTQ#1' and OBJECT_TYPE='INDEX';


col SEGMENT_NAME for a30
select OWNER,SEGMENT_NAME,SEGMENT_TYPE,TABLESPACE_NAME,BYTES/1024/1024 from dba_segments where SEGMENT_NAME='FK_MOV_ESTQ#1' and SEGMENT_TYPE='INDEX';


PURGE RECYCLEBIN;




select FILE#,BLOCK#,BLOCKS,CORRUPTION_CHANGE#,CORRUPTIO from v$database_block_corruption;

     FILE#     BLOCK#     BLOCKS CORRUPTION_CHANGE# CORRUPTIO
---------- ---------- ---------- ------------------ ---------
         7    1299474          1                  0 FRACTURED



 7 block 1297087



 select segment_type,owner||'.'||segment_name "OBJ_CORROMP" from dba_extents where file_id = 7 and 1297087 between block_id and block_id+blocks -1;





set serveroutput on

declare
	vowner varchar2(90);
	vtype varchar2(90);
	vname varchar2(90);

BEGIN

for x in (select file#,block#,blocks,corruption_change#,CORRUPTION_TYPE from v$database_block_corruption) loop

select segment_type,owner,segment_name into vtype,vowner,vname from dba_extents where file_id = x.file# and x.block# between block_id and block_id+blocks -1;

dbms_output.put_line('DADOS DO BLOCO CORROMPIDO:');
dbms_output.put_line('DONO DO OBJETO:............... '||vowner);
dbms_output.put_line('NOME DO OBJETO:............... '||vname);
dbms_output.put_line('TIPO DO OBJETO:............... '||vtype);

dbms_output.put_line('AÇOES A SER EXECUTADAS');
if vtype = 'INDEX' then
	dbms_output.put_line('PRIMEIRO TENTE REBUILD:........ ALTER INDEX '||vowner||'.'||vname||' REBUILD ONLINE;');
	dbms_output.put_line('SEGUNDO TENTE RECRIAR:......... select dbms_metadata.get_ddl(''INDEX'','||vname||','||vowner||') from dual;');
end if;

END LOOP;


END;
/






select file#,block#,blocks,corruption_change#,CORRUPTION_TYPE from dba_corruptions;





col SEGMENT_NAME for a30
col OWNER for a20
set linesize 200
set pagesize 200
SELECT e.owner, e.segment_type, e.segment_name, e.partition_name, c.file#
, greatest(e.block_id, c.block#) corr_start_block#
, least(e.block_id+e.blocks-1, c.block#+c.blocks-1) corr_end_block#
, least(e.block_id+e.blocks-1, c.block#+c.blocks-1)
- greatest(e.block_id, c.block#) + 1 blocks_corrupted
, null description
FROM dba_extents e, v$database_block_corruption c
WHERE e.file_id = c.file#
AND e.block_id <= c.block# + c.blocks - 1
AND e.block_id + e.blocks - 1 >= c.block#
UNION
SELECT s.owner, s.segment_type, s.segment_name, s.partition_name, c.file#
, header_block corr_start_block#
, header_block corr_end_block#
, 1 blocks_corrupted
, 'Segment Header' description
FROM dba_segments s, v$database_block_corruption c
WHERE s.header_file = c.file#
AND s.header_block between c.block# and c.block# + c.blocks - 1
UNION
SELECT null owner, null segment_type, null segment_name, null partition_name, c.file#
, greatest(f.block_id, c.block#) corr_start_block#
, least(f.block_id+f.blocks-1, c.block#+c.blocks-1) corr_end_block#
, least(f.block_id+f.blocks-1, c.block#+c.blocks-1)
- greatest(f.block_id, c.block#) + 1 blocks_corrupted
, 'Free Block' description
FROM dba_free_space f, v$database_block_corruption c
WHERE f.file_id = c.file#
AND f.block_id <= c.block# + c.blocks - 1
AND f.block_id + f.blocks - 1 >= c.block#
order by file#, corr_start_block#;










cat /u01/app/oracle/admin/orcl/bdump/alert_orcl.log | grep -i "Doing block recovery" | awk {"print select segment_type,owner||'.'||segment_name  from dba_extents where file_id = $6 and $NF between block_id and block_id+blocks -1;"}

Doing block recovery for file 7 block 1297087





dbms.repare