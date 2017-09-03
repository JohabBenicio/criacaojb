column value new_val blocksize
select value from v$parameter where name = 'db_block_size';

select trunc(sum(f.blocks)*&&blocksize/1024/1024/1024) freesize,t.name 
from dba_free_space f,v$tablespace t 
where f.TABLESPACE_NAME=t.NAME group by t.name;



set lines 200 pages 200
col datafile for a60

select * from (
select distinct fs.file_id, 
d.FILE_NAME datafile, 
t.name tablespace,
trunc(sum(fs.bytes)/1024/1024) FREESIZE, 
trunc(d.bytes/1024/1024) FILESIZE
from dba_free_space fs,v$tablespace t,dba_data_files d
where fs.TABLESPACE_NAME=t.NAME and 
      fs.file_id=d.file_id      
group by d.FILE_NAME,t.name,fs.file_id,d.bytes order by FREESIZE desc) where FREESIZE>1024;



select file_id, segment_name, segment_type,SEGMENTSIZE, round(TOTAL_MB-ULTIMO_EXTENT_MB,0) LIBERA_MB
from
(
select e.file_id, e.tablespace_name, e.segment_type, e.segment_name,(max(d.bytes/1024/1024))TOTAL_MB,(max(e.block_id+e.blocks-1)*8/1024) ULTIMO_EXTENT_MB, trunc(e.BYTES/1024/1024) SEGMENTSIZE
from
dba_extents e,
dba_data_files d
where
e.file_id=d.file_id
and e.file_id='39'
group by e.file_id, e.tablespace_name, e.segment_type, e.segment_name,e.BYTES
order by 6 DESC
)
/


select e.segment_name,e.segment_type,trunc(sum(s.bytes)/1024/1024) from dba_extents e,dba_segments s 
where e.file_id='39' and e.segment_name=s.segment_name
group by e.segment_name,e.segment_type order by 3 desc;

