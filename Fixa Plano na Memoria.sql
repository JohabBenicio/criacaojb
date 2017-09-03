set linesize 1024;
set pagesize 512;
set autotrace traceonly explain statistics;
select * from op.test2 a where object_id = 238;
set autotrace off;

Como resolver?

1 - Garantir que todas as sessões estejam com o parâmetro use_stored_outlines = true;

-- Apenas para a sua sessão
alter session set use_stored_outlines = true;

-- Para todo o banco de dados
create or replace trigger sys.trg_logon_params after logon on database
begin
execute immediate 'alter session set use_stored_outlines = true';
end;
/

2 - Coletar um outline para o comando no seu formato original. Para tal, vc precisará descobrir o SQL_ID do comando e, na v$sql, pegar o valor das colunas HASH_VALUE e CHILD_NUMBER

select sql_id,child_number,sql_text from v$sql where sql_fulltext like '%TEOR_07_11%';

select 'execute dbms_outln.create_outline (hash_value => ' || to_char (hash_value) || ', child_number => ' || to_char (child_number) || ');' from v$sql where sql_id = '79sqj8pb1zudn';


3 - Obtenha o nome do outline criado com:

col NAME for A35
col OWNER for A15
col CATEGORY for A10
col USED for A10
col TIMESTAMP for A20
col ENABLED for A10
col FORMAT for A8
select NAME, OWNER, CATEGORY, USED, TIMESTAMP, COMPATIBLE, ENABLED, FORMAT from dba_outlines;


4 - Execute a query com a hint ajustada, ou sem ela, se for o caso.
5 - Repita os passos 2 e 3 com a nova query

Substitua os valores das variáveis no trecho de código abaixo e execute.


define worse_outline_name = XXXXXXXXXXXXX;
define better_outline_name = YYYYYYYYYYYYYYYYYY;
define sql_id = annphpu6w3vfq;


delete
from outln.ol$hints
where ol_name = '&&worse_outline_name';

update outln.ol$hints
set ol_name = '&&worse_outline_name'
where ol_name = '&&better_outline_name';

delete
from outln.ol$nodes
where ol_name = '&&worse_outline_name';

update outln.ol$nodes
set ol_name = '&&worse_outline_name'
where ol_name = '&&better_outline_name';

commit;

alter outline &&worse_outline_name rename to teor_&&sql_id; -- ALTER ANY OUTLINE privilege is required for this operation

delete
from outln.ol$hints
where ol_name = '&&better_outline_name';

delete
from outln.ol$nodes
where ol_name = '&&better_outline_name';

delete
from outln.ol$
where ol_name = '&&better_outline_name';

commit;