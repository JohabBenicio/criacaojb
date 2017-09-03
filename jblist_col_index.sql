
set serveroutput on lines 200 pages 2000
declare
  v_full   varchar2(90):='APP_SYSCARE.L$LOGTABELA';
  v_ind_ddl varchar2(10):=upper('Y');
  v_ddl    varchar2(2000);
  v_ddlT    varchar2(200);
  v_ddlP    varchar2(112);
  v_pont   number;
  v_owner varchar2(30);
  v_table varchar2(30);
  v_column varchar2(90);
  v_expression varchar2(2000);
  v_expressionT varchar2(200);
  v_expressionP varchar2(200);
  v_column_rep varchar2(90):='ok';


begin

v_pont := instr( v_full, '.' );
v_owner := upper(rtrim( ltrim( substr( v_full, 1, v_pont-1))));
v_table := upper(rtrim( ltrim( substr( v_full, v_pont+1))));

v_expressionT:=chr(32)||chr(32)||chr(32)||rpad('Ind. Bas. Func',30,' ');
v_expressionP:=chr(32)||chr(32)||chr(32)||rpad(' ',15,'-');


if v_owner is not null and v_table is not null then

dbms_output.put_line(chr(10)||chr(10)||chr(10)||'= =============================================================================================================');
dbms_output.put_line('= COLUNAS COM INDICE => '||v_owner||'.'||v_table);
dbms_output.put_line('= ============================================================================================================='||chr(10));


for y in (select distinct ai.index_name
         , ai.index_type
         , ai.blevel
    from all_ind_columns ic
       , all_indexes ai
    where ic.table_owner = v_owner
      and ic.table_name = v_table
      and ic.index_name = ai.index_name
      and ai.table_owner = v_owner) loop

if y.index_name is not null then

dbms_output.put_line(rpad('Nome da coluna',20,' ')||chr(32)||rpad('Nome do Indice',30,' ')||chr(32)||rpad('Tipo do Indice',17,' ')||chr(32)||rpad('BLevel',7,' ')||chr(32)||chr(32)||chr(32)||rpad('Ordem',6,' ')||v_expressionT);

dbms_output.put_line(rpad(' ',20,'-')||chr(32)||rpad(' ',30,'-')||chr(32)||rpad(' ',17,'-')||chr(32)||rpad(' ',7,'-')||chr(32)||chr(32)||chr(32)||rpad(' ',6,'-')||v_expressionP);
end if;

for x in (select ic.descend
         , ic.column_name
         , ie.column_expression
    from all_ind_columns ic
       , all_ind_expressions ie
    where ic.table_owner = v_owner
      and ic.table_name = v_table
      and y.index_name = ie.index_name(+)
      and ie.table_owner(+) = v_owner
      and ic.index_name = y.index_name
    order by ic.column_name
) loop

if x.column_expression is not null then
v_expression:=chr(32)||chr(32)||chr(32)||rpad(x.column_expression,30,' ');
else
v_expression:='NONE';
end if;

if v_column_rep = 'no' then
dbms_output.put_line(rpad(x.column_name,20,' ')||chr(32)||rpad(y.index_name,30,' ')||chr(32)||rpad(y.index_type,17,' ')||chr(32)||rpad(y.blevel,7,' ')||chr(32)||chr(32)||chr(32)||rpad(x.descend,6,' ')||v_expression );
v_column_rep:=x.column_name;
else
dbms_output.put_line(rpad(x.column_name,20,' '));
end if;


end loop;

dbms_output.put_line(chr(10));
if v_ind_ddl = 'Y' then
select dbms_metadata.get_ddl( 'INDEX' , y.index_name,v_owner ) into v_ddl from dual;
v_ddlT:='DDL do INDICE';
v_ddlP:=rpad(' ',112,'-');
else
v_ddl:=null;
v_ddlT:=null;
v_ddlP:=null;
end if;



dbms_output.put_line(v_ddlT);
dbms_output.put_line(v_ddlP);
dbms_output.put_line(rtrim(ltrim(replace(trim(v_ddl),chr(10),' '))) || ' ;' || chr(10) || chr(10) );


end loop;
else
  dbms_output.put_line(chr(10)||'= =============================================================================================================');
  dbms_output.put_line('= COLUNAS COM INDICE => '||v_owner||'.'||v_table);
  dbms_output.put_line('= =============================================================================================================');
  dbms_output.put_line(chr(10)||'OBJETO NAO ENCONTRADO'||chr(10));
end if;

end;
/
