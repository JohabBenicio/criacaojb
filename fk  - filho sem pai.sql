
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



