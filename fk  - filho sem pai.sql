
select <COLUMN_NAME> from <CHILD_TABLE> a where not exists (select <COLUMN_NAME> from
<PARENT_TABLE> where primary_key = a.<KEY_VALUE>);

SQL> select CODCOLIGADA ,IDMOV from RM.TMOVRATCCU a where not exists
(select CODCOLIGADA from RM.TMOV where CODCOLIGADA = a.CODCOLIGADA and IDMOV=a.I

CODCOLIGADA IDMOV
----------- ----------
1 3829965

sirio -> pegerdury

11:50

eric
hospital igesp




SELECT
  'ALTER TABLE "'
    || a.table_name ||
  '" DISABLE CONSTRAINT "'
    || a.constraint_name ||
  '";'
    AS "DISABLE FOREIGN KEY"
FROM
  all_constraints a
WHERE
  a.constraint_type = 'R'
AND
  a.owner = Upper('USIDAD');


SELECT a.table_name, a.column_name, a.constraint_name, c.owner,
       -- referenced pk
       c.r_owner, c_pk.table_name r_table_name, c_pk.constraint_name r_pk
  FROM all_cons_columns a
  JOIN all_constraints c ON a.owner = c.owner
                        AND a.constraint_name = c.constraint_name
  JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                           AND c.r_constraint_name = c_pk.constraint_name
 WHERE c.constraint_type = 'R'
   AND a.table_name = 'TSCCLIGER';



