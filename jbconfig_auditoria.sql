
## ####################################################################################
##  1. DESATIVAR A AUDITORIA SE ELA ESTIVER HABILITADA:
## ####################################################################################

SQL> alter system set audit_trail=none scope=spfile;

## ####################################################################################
##  2. REINICIAR O BANCO DE DADOS:
## ####################################################################################

SQL> shutdown immediate;

SQL> startup;

## ####################################################################################
##  3. CRIAR UMA NOVA TABLESPACE PARA ARMAZENAR OS OBJETOS DA AUDITORIA:
## ####################################################################################

SQL> create tablespace AUDITDB datafile '[DIRETÓRIO]' size 64m autoextend on next 64m maxsize 8g;
-- EXEMPLO
SQL> create tablespace AUDITDB datafile '/u01/app/oracle/oradata/prod/tbs_audit_01.dbf' size 64m autoextend on next 64m maxsize 8g;


## ####################################################################################
##  4. CONECTAR COMO SYS, EXECUTAR OS PASSOS ABAIXO:
## ####################################################################################

SQL> conn / as sysdba

SQL> create table system.aud$ tablespace AUDITDB as select * from aud$;

SQL> create index system.i_aud1 on system.aud$(sessionid, ses$tid) tablespace AUDITDB;

SQL> rename aud$ to aud$_temp;

SQL> create view aud$ as select * from system.aud$;


## ####################################################################################
##  5. CONECTAR COM O USUÁRIO SYSTEM E CONCEDER OS PRIVILÉGIOS ABAIXO:
## ####################################################################################

SQL> conn system/xxxxxx

SQL> grant all on aud$ to sys with grant option;  <---- EXECUTAR ESTE COMANDO COM UM USUARIO QUE NÃO SEJA O "SYS" POIS PODE GERAR O ERRO "ORA-01749"

SQL> grant delete on aud$ to delete_catalog_role;


## ####################################################################################
##  6. REATIVAR A AUDITORIA, UTILIZAR OS PASSOS ABAIXO:
## ####################################################################################
db_extended

SQL> alter system set audit_trail=DB_EXTENDED scope=spfile;


## ####################################################################################
##  2. REINICIAR O BANCO DE DADOS:
## ####################################################################################

SQL> shutdown immediate;

SQL> startup;

## ####################################################################################
##  7. RECRIAR AS VISÕES DA AUDITORIA DO DICIONÁRIO DE DADOS:
## ####################################################################################

SQL> @?/rdbms/admin/cataudit.sql

Apartir desses passos executados os objetos de auditoria serão criados na tablespace TB_AUDITORIA.

Abaixo alguns exemplos do comando AUDIT.

AUDIT ALL BY ACCESS;
AUDIT EXECUTE PROCEDURE BY ACCESS;
AUDIT UPDATE TABLE,
      SELECT TABLE,
      INSERT TABLE,
      DELETE TABLE BY ACCESS;

Os comandos acima realizam auditoria de todos os comandos que o executar no banco de dados (DDL, DML, Logon e Logoff).

Também é possível realizar auditoria de um objeto específico, independente do usuário que o acessa e também por uma sessão inteira. O comando ficaria assim:

AUDIT ALL ON [OWNER].[TABELA] BY SESSION;

Para desabilitar a auditoria de determinado objeto deve-se utilizar o comando “NOAUDIT”, conforme o exemplo abaixo:

NOAUDIT ALL ON [OWNER].[TABELA] BY SESSION;

Dica importante:  O comando “AUDIT ALL” habilita a auditoria para todo o banco e para todas as atividades. Recomenda-se analisar a real necessidade para utilização deste comando num ambiente de produção. Pois esse comando gera lentidão no banco de dados e também um volume muito grande de informação armazenada da auditoria no banco de dados.





Os dados de auditoria sao armazenados na tabela SYS.AUD$. Seu conteúdo pode ser visto diretamente ou através das seguintes exibições:
SQL> select view_name from dba_views where view_name like 'DBA%AUDIT%' order by view_name;


As 3 views principais sao:
DBA_AUDIT_TRAIL: Padrão de auditoria (a partir da AUD$).
DBA_FGA_AUDIT_TRAIL: Criadas para auditar operações DDL (de FGA_LOG$).
DBA_COMMON_AUDIT_TRAIL: Ambos os e refinado padrão de auditoria.




## ####################################################################################
##  EXEMPLOS DE AUDITORIAS
## ####################################################################################

-- NONE: DESATIVAR A AUDITORIA NO BANCO.

-- OS: AUDITORIA HABILITADA, OS REGISTROS VÃO SER GRAVADOS EM DIRETÓRIOS DO SISTEMA EM ARQUIVOS DE AUDITORIA.

-- DB OU TRUE: AUDITORIA É HABILITADA, OS REGISTROS DE AUDITORIA SERÃO ARMAZENADAS NO BANCO DE DADOS (SYS.AUD$)

-- DB_EXTENDED: TRABALHA IGUAL AO PARÂMETRO DB, MAIS AS COLUNAS SQL_BIND E SQL_TEXT SÃO PREENCHIDAS.
 
-- XML: AUDITORIA É HABILITADA, OS REGISTROS SERÃO ARMAZENADOS EM FORMATOS XML.

-- O PARAMETRO "AUDIT_SYS_OPERATIONS" HABILITA OU DESABILITA A AUDITORIA DAS OPERAÇÕES EMITIDOS POR USUÁRIOS QUE SE CONECTAM COM O SYSDBA OU PRIVILÉGIOS SYSOPER, INCLUINDO O USUÁRIO SYS.

-- QUANDO SELECIONAMOS OS MODOS OS OU XML, SÃO CRIADOS ARQUIVOS CONTENDO OS REGISTROS DO AUDITORIA NO DIRETÓRIO DEFINIDO PELO PARÂMETRO "AUDIT_FILE_DEST".
-- É TAMBÉM O LOCAL DE TODAS AS AUDITORIAS OBRIGATÓRIAS ESPECIFICADAS PELO PARAMETRO "AUDIT_SYS_OPERATIONS" CITADO LOGA ACIMA.
 alter system set audit_file_dest='[CAMINHO]'  scope=spfile;
 -- EXEMPLO
 alter system set audit_file_dest='/u01/app/oracle/admin/prod'  scope=spfile;


-- VEJAMOS UM EXEMPLO BASICO DE COMO AUDITAR OPERAÇÕES:
SQL> connect / as sysdba
SQL> audit all by audit_test by access;
SQL> audit select table, update table, insert table, delete table by audit_test by access;
SQL> audit execute procedure by audit_test by access;

-- ESTAS OPÇÕES AUDITAM TODOS OS DDL E DML, JUNTAMENTE COM ALGUNS EVENTOS DO SISTEMA.
DDL (CREATE, ALTER & DROP of objects)
DML (INSERT UPDATE, DELETE, SELECT, EXECUTE)
SYSTEM EVENTS (LOGON, LOGOFF, etc...)