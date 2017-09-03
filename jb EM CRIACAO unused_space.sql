

set lines 200 pages 200 long 999
set serveroutput on
set feedback off
set verify off

declare 
  v_total_blocks              NUMBER;
  v_total_bytes               NUMBER;
  v_unused_blocks             NUMBER;
  v_unused_bytes              NUMBER;
  v_last_used_extent_file_id  NUMBER;
  v_last_used_extent_block_id NUMBER;
  v_last_used_block           NUMBER;
  v_partition_name            varchar2(90);
v_size varchar2(20);


begin
  dbms_output.put_line(chr(10)||chr(10)||chr(10));

  for x in (select segment_name, sum(bytes) v_sum, owner,segment_type from dba_segments where segment_type in ('INDEX','TABLE')   group by segment_name,owner,segment_type order by segment_type) loop

DBMS_SPACE.UNUSED_SPACE (segment_owner                => x.owner,
                         segment_name                 => x.segment_name,
                         segment_type                 => x.segment_type,
                         total_blocks                 => v_total_blocks,
                         total_bytes                  => v_total_bytes,
                         unused_blocks                => v_unused_blocks,
                         unused_bytes                 => v_unused_bytes,
                         last_used_extent_file_id     => v_last_used_extent_file_id,
                         last_used_extent_block_id    => v_last_used_extent_block_id,
                         last_used_block              => v_last_used_block,
                         partition_name               => v_partition_name);

v_size:=substr(v_unused_bytes /1024/1024,1,(instr(v_unused_bytes /1024/1024,'.'))-1);
v_size:=rtrim( ltrim( v_size ) );

if v_size > 15 and v_size is not null  then

  DBMS_OUTPUT.PUT_LINE('Nome do Segmento:.............. ' || x.owner||'.'||x.segment_name);
  DBMS_OUTPUT.PUT_LINE('Tipo do Segmento:.............. ' || x.segment_type||chr(10));
  DBMS_OUTPUT.PUT_LINE('Total de blocos:............... ' || v_total_blocks);
  DBMS_OUTPUT.PUT_LINE('Total de bytes:................ ' || v_total_bytes || chr(10));
  DBMS_OUTPUT.PUT_LINE('Blocos Livres:................. ' || v_unused_blocks);
  DBMS_OUTPUT.PUT_LINE('Bytes Livres:.................. ' || v_size || ' Mb'||chr(10));
  DBMS_OUTPUT.PUT_LINE('v_last_used_extent_file_id:.... ' || v_last_used_extent_file_id);
  DBMS_OUTPUT.PUT_LINE('v_last_used_extent_block_id:... ' || v_last_used_extent_block_id);
  DBMS_OUTPUT.PUT_LINE('v_last_used_block:............. ' || v_last_used_block );
  DBMS_OUTPUT.PUT_LINE('partition_name:................ ' || v_partition_name );

  DBMS_OUTPUT.PUT_LINE(chr(10) || chr(10)|| '====================================================='|| chr(10) );


end if; 

  end loop;
  dbms_output.put_line(chr(10)||chr(10)||chr(10));

end;
/

