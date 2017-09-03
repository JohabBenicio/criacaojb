define schema_owner=SIS
define table_name="'TAB_MED_GEMP_TP','TAB_TRANSF_PLANO'"



set pagesize 5000
set linesize 350
column status format a10
column table_name format a30
column fk_name format a30
column fk_columns format a30
column index_name format a30
column index_columns format a30

select
        case
          when b.table_name is null then
            'unindexed'
          else
            'indexed'
        end               as status
       ,a.table_name      as table_name
       ,a.fk_columns      as fk_columns
       ,a.constraint_name as fk_name
       ,c.TABLE_NAME      as PAI
--       ,b.index_name      as index_name
--       ,b.index_columns   as index_columns
from
    (
      select a.table_name
            ,a.constraint_name
            ,listagg(a.column_name, ',') within
             group (order by a.position) fk_columns
      from
             dba_cons_columns   a
            ,dba_constraints    b
      where
             a.constraint_name  = b.constraint_name
      and    b.constraint_type  = 'R'
      and    a.owner            = '&&schema_owner'
      and    a.owner            = b.owner
      group by a.table_name, a.constraint_name
    ) a
   ,(
      select table_name
            ,index_name
            ,listagg(c.column_name, ',') within
             group (order by c.column_position) index_columns
      from
             dba_ind_columns  c
      where  c.index_owner    = '&&schema_owner'
      group BY table_name, index_name
    ) b
   ,
(select c2.CONSTRAINT_NAME,c1.TABLE_NAME from dba_constraints c1, dba_constraints c2
where c2.R_OWNER=c1.OWNER and c2.R_CONSTRAINT_NAME=c1.CONSTRAINT_NAME
and c1.owner='&&schema_owner' and (c1.TABLE_NAME in (&&table_name) or c2.TABLE_NAME in (&&table_name))) c
where
      a.table_name        =     b.table_name(+)
and   b.index_columns(+)  like  a.fk_columns || '%'
and c.CONSTRAINT_NAME=a.constraint_name
and b.table_name is null
order by 1 desc, 2;
