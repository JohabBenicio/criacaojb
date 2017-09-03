Criar um Banco de dados chamado "$ORACLE_SID"

adump : arquivos de auditoria.
bdump : arquivo de arlet mais dumps de memória gerados na execução.
cdump : Arquivos de erros.
udump : gerar os traces de sessão.


--INICIALMENTE NÓS VAMOS CRIAR OS DIRETÓRIOS PARA O ARMAZENAMENTO DO BANCO DE DADOS.

mkdir $ORALE_BASE/admin/$ORACLE_SID/adump
mkdir $ORALE_BASE/admin/$ORACLE_SID/bdump
mkdir $ORALE_BASE/admin/$ORACLE_SID/cdump
mkdir $ORALE_BASE/admin/$ORACLE_SID/dpdump
mkdir $ORALE_BASE/admin/$ORACLE_SID/udump
mkdir $ORACLE_BASE/oradata/$ORACLE_SID

--CRIAÇÃO DAS VARIAVEIS DE AMBIENTE

set ORACLE_SID=$ORACLE_SID

--CRIAÇÃO DOS SERVIÇOS DE INSTANCIA
--APENAS NO WINDOWS
--ELE TEM QUE ESTAR INICIADO ANTES DA CRIAÇÃO

--CRIAR UM ARQUIVO COM O NOME "init$ORACLE_SID.ora"
--SALVAR O ARQUIVO NO DIRETÓRIO "$ORACLE_HOME/dbs"


##############################################################################
# Copyright (c) 1991, 2001, 2002 by Oracle Corporation
##############################################################################
 
###########################################
# Archive
###########################################
log_archive_format=ARC%S_%R.%T
 
###########################################
# Cursors and Library Cache
###########################################
open_cursors=300
 
###########################################
# Cache and I/O
###########################################
db_block_size=8192
db_file_multiblock_read_count=16
 
###########################################
# Sort, Hash Joins, Bitmap Indexes
###########################################
pga_aggregate_target=200m
 
###########################################
# File Configuration
###########################################
control_files=("$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl", "$ORACLE_BASE/oradata/$ORACLE_SID/control02.ctl")

###########################################
# Diagnostics and Statistics
###########################################
background_dump_dest=$ORALE_BASE/admin/$ORACLE_SID/bdump
core_dump_dest=$ORALE_BASE/admin/$ORACLE_SID/cdump
user_dump_dest=$ORALE_BASE/admin/$ORACLE_SID/udump
 
###########################################
# Miscellaneous
###########################################
compatible=10.2.0.1
 
###########################################
# Job Queues
###########################################
job_queue_processes=10
 
###########################################
# Database Identification
###########################################
db_domain=""
db_name=$ORACLE_SID
 
###########################################
# SGA Memory 276MB
###########################################
sga_target=289406976
 
###########################################
# Processes and Sessions
###########################################
processes=150
 
###########################################
# System Managed Undo and Rollback Segments
###########################################
undo_management=AUTO
undo_tablespace=UNDOTBS1
 
###########################################
# Security and Auditing
###########################################
audit_file_dest=$ORALE_BASE/admin/$ORACLE_SID/adump
remote_login_passwordfile=EXCLUSIVE
 
###########################################
# Shared Server
###########################################
dispatchers="(PROTOCOL=TCP) (SERVICE=$ORACLE_SID\XDB)"

--CRIAÇÃO DOS PARAMENTROS
-- 1) CONTROL_FILES
-- 2) Back Ground_dump_dest
-- 3) CORE_DUMP_DEST
-- 4) USER_DUMP_DEST
-- 5) DB_NAME
-- 6) AUDIT_DUMP_DEST
-- 7) SGA_TARGET
-- 8) NLS_LANGUAGE
-- 9) NLS_TERRITORY



-- COMEÇANDO A CRIAÇÃO DA BASE – INICIALIZANDO A BASE SEM OS CONTROL FILES
-- NO PRONPT DE COMANDO DO WINDOWS EXECUTAR

sqlplus / as sysdba

create spfile from pfile;

startup nomount;

-- DEFINER UMA SENHA PARA O SYS E SYSTEM
-- EXECUTAR NO SQLPLUS

PROMPT -- ESPECIFIQUE A SENHA PARA USUARIO SYS COMO PARAMETRO 1
DEFINE sysPassword = Oracle10g

PROMPT -- ESPECIFIQUE A SENHA PARA USUARIO SYS COMO PARAMETRO 2
DEFINE systemPassword = Oracle10g

-- EXEXUTAR O BINARIO "orapwd.exe"
-- CRIAÇÃO DO ARQUIVO DE SENHA
-- VERIFICAR SE O DOCUMENTO "PWD$ORACLE_SID.ora" FOI CRIADO

host orapwd file=$ORACLE_HOME/dba/orapw$ORACLE_SID password=&&sysPassword force=y

-- CRIAÇÃO DO BANCO DE DADOS

CREATE DATABASE $ORACLE_SID
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
DATAFILE '$ORACLE_BASE/oradata/system01.dbf' SIZE 300M REUSE AUTOEXTEND ON NEXT  10240K MAXSIZE UNLIMITED
EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '$ORACLE_BASE/oradata/sysaux01.dbf' SIZE 120M REUSE AUTOEXTEND ON NEXT  10240K MAXSIZE UNLIMITED
SMALLFILE DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '$ORACLE_BASE/oradata/temp01.dbf' SIZE 20M REUSE AUTOEXTEND ON NEXT  640K MAXSIZE UNLIMITED
SMALLFILE UNDO TABLESPACE "UNDOTBS1" DATAFILE '$ORACLE_BASE/oradata/undotbs01.dbf' SIZE 200M REUSE AUTOEXTEND ON NEXT  5120K MAXSIZE UNLIMITED
CHARACTER SET WE8MSWIN1252
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1 ('$ORACLE_BASE/oradata/redo01.log') SIZE 51200K,
GROUP 2 ('$ORACLE_BASE/oradata/redo02.log') SIZE 51200K,
GROUP 3 ('$ORACLE_BASE/oradata/redo03.log') SIZE 51200K
USER SYS IDENTIFIED BY "&&sysPassword" USER SYSTEM IDENTIFIED BY "&&systemPassword";


CREATE SMALLFILE TABLESPACE "USERS" LOGGING DATAFILE '$ORACLE_BASE/oradata/users01.dbf' SIZE 5M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;
ALTER DATABASE DEFAULT TABLESPACE "USERS";


-- LOCALIZAÇÃO DO ALERT "show parameter dump"


set ORACLE_SID=$ORACLE_SID

-- CRIANDO O CATALOGO (MUDAR SE NECESSARIO O DIRETORIO DOS SCRIPTS)
-- CONECTAR COMO SYS

conn sys as sysdba -- NÃO TEM SENHA

-- STARTAR O BANCO ESPECIFICANDO O CAMINHO DO "init"

startup nomount pfile;

set echo on
 
--SCRIPT DE CRIAÇÃO DO CATÁLOGO
-- EXECUTAR OS DIRETÓRIOS ABAIXO
@?/rdbms/admin\catalog.sql;
@?/rdbms/admin\catblock.sql;
@?/rdbms/admin\catproc.sql;


-- ESSES DOIS SÃO OPCIONAIS
@?/rdbms/admin\catoctk.sql;
@?/rdbms/admin\owminst.plb;

set echo on

--PÓS CRIAÇÃO
shutdown immediate;

conn sys as sysdba;

-- ATIVANDO O ARCHIVE
startup mount;

-- COLOCANDO O BANCO NO MODO ARCHIVELOG
alter database archivelog;   

-- O BANCO DEVERÁ ABRIR, CASO NÃO ABRA, ALGO ERRADO FOI FEITO 
alter database open;	      

set echo on
  
shutdown immediate;

conn sys as sysdba

--INICIALIZANDO USANDO O SPFILE
startup;

spool F:\PosCriacao$ORACLE_SID.log

select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
Spool off
exit;


