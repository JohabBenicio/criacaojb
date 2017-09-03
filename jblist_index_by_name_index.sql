break on index_name skip page
break on table_owner skip page
break on table_name skip page

col COLUMN_NAME for a20
col OWNER for a11
col DEGREE for 99
col INDEX_TYPE for a8
col INDEX_NAME for a10
set lines 200 pages 2000
select ic.index_name,
       ic.column_position,
       ic.descend,
       ic.table_owner,
       ic.table_name,
       ic.column_name,
       ai.index_type,
       ai.blevel,
       ai.status,
       ai.LAST_ANALYZED,
       ai.PARTITIONED,
       ai.NUM_ROWS,
       ai.CLUSTERING_FACTOR
from all_ind_columns ic, all_indexes ai
where ic.index_name = 'ID_LOG_002'
and ic.table_owner=ai.owner
      and ic.index_name = ai.index_name
order by 1,2;
