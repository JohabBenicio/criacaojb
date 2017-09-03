

rm -f jbcreate_dbfs.sh

vi jbcreate_dbfs.sh
i

#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Criar banco de dados em FS via create database.
#-- Nome do arquivo     : jbcreate_dbfs.sh
#-- Data de criação     : 12/11/2014
#-- -----------------------------------------------------------------------------------

if [ "$USER" != "oracle" ]; then
	echo "Conecte com usuario oracle!"
	exit
fi

. /home/oracle/.bash_profile

if [ -z "$1" ]; then
	echo "Digite: sh  $0 <SID> <SENHA SYS> <ARCHIVELOG OU NOARCHIVELOG> <QTD DE MEMORIA EM MG> <WE8ISO8859P1>"
	exit
fi
if [ -z "$2" ]; then
	echo "Digite: sh  $0 $1 <SENHA SYS> <ARCHIVELOG OU NOARCHIVELOG> <QTD DE MEMORIA EM MG> <WE8ISO8859P1>"
	exit
fi
if [ -z "$3" ]; then
	echo "Digite: sh  $0 $1 $2 <ARCHIVELOG OU NOARCHIVELOG> <QTD DE MEMORIA EM MG> <WE8ISO8859P1>"
	exit
fi
if [ -z "$4" ]; then
	echo "Digite: sh  $0 $1 $2 $3 <QTD DE MEMORIA EM MG> <WE8ISO8859P1>"
	exit
fi
if [ -z "$5" ]; then
	echo "Digite: sh  $0 $1 $2 $3 $4 <WE8ISO8859P1>"
	exit
fi
if [ "$4" -gt "100" ]; then
	if [ "$3" = "ARCHIVELOG" ]; then
		export ORACLE_SID=$1
		export SENHA_SYS=$2
		export ARCH=$3
		export MEM=$4\M
	elif [ "$3" = "NOARCHIVELOG" ]; then
		export ORACLE_SID=$1
		export SENHA_SYS=$2
		export ARCH=$3
		export MEM=$4\M
	else
		echo "Digite: sh  $0 $1 $2 <ARCHIVELOG OU NOARCHIVELOG> $4 $5"
		exit
	fi
else
	echo "Digite: sh  $0 $1 $2 $3 <QTD DE MEMORIA EM MG> $5"
	exit
fi

export CHARACT=$5

ps -ef | grep pmon | grep $ORACLE_SID 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | \
while read instance_db
do
if [ "$instance_db" = "$ORACLE_SID" ]; then
  touch /tmp/banco_no_ar.loc
  exit
fi
done

if [ -e "/tmp/banco_no_ar.loc" ]; then
  rm -f /tmp/banco_no_ar.loc
  echo "Ja existe uma instancia no ar com este nome!"
  exit
fi


#export MEM=$(free -m | grep -i "Mem" | awk '{print ( $2 * 20 ) / 100 }' | cut -f1 -d".")M
sleep 1

mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/dpdump
mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/pfile
mkdir -p $ORACLE_BASE/oradata/$ORACLE_SID
echo "Criando os diretorios:"
echo $ORACLE_BASE/admin/$ORACLE_SID
ll $ORACLE_BASE/admin/$ORACLE_SID
echo $ORACLE_BASE/oradata/$ORACLE_SID


sleep 1
echo "Criando o INIT: $ORACLE_HOME/dbs/init$ORACLE_SID.ora"

if [ -e "$ORACLE_HOME/dbs/init$ORACLE_SID.ora" ]; then
	rm -f  $ORACLE_HOME/dbs/init$ORACLE_SID.ora
fi

cat << JBC > $ORACLE_HOME/dbs/init$ORACLE_SID.ora

##############################################################################
# Copyright (c) 1991, 2001, 2002 by Oracle Corporation
##############################################################################

###########################################
# Archive
###########################################
log_archive_format=%t_%s_%r.dbf

###########################################
# Cache and I/O
###########################################
db_block_size=8192

###########################################
# Cursors and Library Cache
###########################################
open_cursors=300

###########################################
# Database Identification
###########################################
db_domain=""
db_name=$ORACLE_SID

###########################################
# File Configuration
###########################################
control_files="$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl"
#db_recovery_file_dest=/u01/app/oracle/flash_recovery_area
#db_recovery_file_dest_size=5218762752

###########################################
# Miscellaneous
###########################################
compatible=11.2.0.0.0
diagnostic_dest=$ORACLE_BASE

###########################################
# Processes and Sessions
###########################################
processes=150

###########################################
# SGA Memory
###########################################
sga_target=$MEM

###########################################
# Security and Auditing
###########################################
audit_file_dest=$ORACLE_BASE/admin/$ORACLE_SID/adump
audit_trail=none
#remote_login_passwordfile=EXCLUSIVE

###########################################
# Sort, Hash Joins, Bitmap Indexes
###########################################
pga_aggregate_target=50m

###########################################
# System Managed Undo and Rollback Segments
###########################################
undo_tablespace=UNDOTBS1

###########################################
# Shared Server
###########################################

JBC


echo "dispatchers='(PROTOCOL=TCP) (SERVICE=$ORACLE_SID""XDB)'" >> $ORACLE_HOME/dbs/init$ORACLE_SID.ora


sleep 1

if [ -e "$ORACLE_HOME/dbs/orapw$ORACLE_SID" ]; then
	rm -f $ORACLE_HOME/dbs/orapw$ORACLE_SID
fi

echo "Criando o arquivo de senha do oracle PWD: $ORACLE_HOME/dbs/orapw$ORACLE_SID"


$ORACLE_HOME/bin/orapwd file=$ORACLE_HOME/dbs/orapw$ORACLE_SID force=y password=$SENHA_SYS

sleep 1

if [ -e "/tmp/oratab_crdb" ]; then
	rm -f /tmp/oratab_crdb
fi

cp /etc/oratab /tmp/oratab_crdb
find /tmp/oratab_crdb  -exec sed -i "/$ORACLE_SID/d" {} \;
cat /tmp/oratab_crdb > /etc/oratab
rm -f /tmp/oratab_crdb

sleep 1

echo "$ORACLE_SID:$ORACLE_HOME:N" >> /etc/oratab

echo "Configuração do arquivo /etc/oratab."
echo " "
cat /etc/oratab

sleep 1

if [ -e "/tmp/create_db.sql" ]; then
	rm -f /tmp/create_db.sql
fi

echo "Criando o arquivo de create database: /tmp/create_db.sql"
cat << JBC > /tmp/create_db.sql

conn sys/$SENHA_SYS as sysdba

startup nomount pfile='$ORACLE_HOME/dbs/init$ORACLE_SID.ora';

CREATE DATABASE "$ORACLE_SID"
MAXINSTANCES 8
MAXLOGHISTORY 1
MAXLOGFILES 16
MAXLOGMEMBERS 3
MAXDATAFILES 100
DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/system01.dbf' SIZE 700M REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g
EXTENT MANAGEMENT LOCAL
SYSAUX DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/sysaux01.dbf' SIZE 600M REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g,
'$ORACLE_BASE/oradata/$ORACLE_SID/sysaux02.dbf' SIZE 600M REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g
SMALLFILE DEFAULT TEMPORARY TABLESPACE TEMP TEMPFILE '$ORACLE_BASE/oradata/$ORACLE_SID/temp01.dbf' SIZE 100M REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g
SMALLFILE UNDO TABLESPACE "UNDOTBS1" DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/undotbs01.dbf' SIZE 250m REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g,
'$ORACLE_BASE/oradata/$ORACLE_SID/undotbs02.dbf' SIZE 250m REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g
CHARACTER SET $CHARACT
NATIONAL CHARACTER SET AL16UTF16
LOGFILE GROUP 1 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo01.log') SIZE 51200K,
GROUP 2 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo02.log') SIZE 51200K,
GROUP 3 ('$ORACLE_BASE/oradata/$ORACLE_SID/redo03.log') SIZE 51200K
USER SYS IDENTIFIED BY "$SENHA_SYS" USER SYSTEM IDENTIFIED BY "$SENHA_SYS";

CREATE SMALLFILE TABLESPACE "USERS" LOGGING DATAFILE '$ORACLE_BASE/oradata/$ORACLE_SID/users01.dbf' SIZE 100m REUSE AUTOEXTEND ON NEXT  128m MAXSIZE 4g EXTENT MANAGEMENT LOCAL SEGMENT SPACE MANAGEMENT  AUTO;
ALTER DATABASE DEFAULT TABLESPACE "USERS";


set echo on

@?/rdbms/admin/catalog.sql;
@?/rdbms/admin/catblock.sql;
@?/rdbms/admin/catproc.sql;

conn system/$SENHA_SYS

@?/sqlplus/admin/pupbld.sql

conn sys/$SENHA_SYS as sysdba;

@?/rdbms/admin/catoctk.sql;
@?/rdbms/admin/owminst.plb;


create spfile from pfile;

shutdown immediate;

conn sys/$SENHA_SYS as sysdba;

startup mount;

alter database $ARCH;

shutdown immediate;

conn sys/$SENHA_SYS as sysdba;

startup;

set echo on


shutdown immediate;

conn sys/$SENHA_SYS as sysdba;

startup;

select 'utl_recomp_begin: ' || to_char(sysdate, 'HH:MI:SS') from dual;
execute utl_recomp.recomp_serial();
select 'utl_recomp_end: ' || to_char(sysdate, 'HH:MI:SS') from dual;
exit;

JBC



echo "INICIANDO A CRIACAO DO BANCO"

sleep 1

sqlplus /nolog << JBC
@/tmp/create_db.sql
JBC


if [ -e "/tmp/create_db.sql" ]; then
	rm -f /tmp/create_db.sql
fi
if [ -e "$0" ]; then
	rm -f $0
fi




:wq!






