



rm -f /opt/app/oracle/admin/sgoijms/script/DelArch.sh

vi /opt/app/oracle/admin/sgoijms/script/DelArch.sh
i
#!/bin/bash
# Teor Tecnologia Orientada
# Rua Chile, 1669 - Sala 4
# (16) 3911-8999
# Ribeirao Preto - SP
#
#
# Criado em 18/09/2015
#
# Efetua backup fisico full do banco de dados utilizando utilitario RMAN
#
# Versao para Linux
# $1 ORACLE_SID

#
# Inicio
#

#. ~/.bash_profile
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1
export ORACLE_HOME=/opt/app/oracle/product/11.2.0/dbhome_2
export PATH=$ORACLE_HOME/bin:$PATH

if [ "$1" = '' ]; then
   echo "                           "
   echo "Digite: sh bkp_full.sh <SID> ou bkp_full.sh <SID>                           " ;
   exit 1;
fi

BANCO=`ps -ef | grep smon | grep $1 2>>/dev/null | sed 's/.*mon_\(.*\)$/\1/' | grep -E "(^| )$1( |$)"`

if [ "$1" = '' ]; then
   echo -e "\n\nDigite: sh AplArch.sh <SID> ou AplArch.sh <SID>\n\n"
   exit
elif [ "$BANCO" = "$1" ]; then
   export ORACLE_SID=$BANCO
else
   echo "Banco nao existe"
   exit
fi

export DATA=`date +%d%m%Y_%H%M`
export DEL_LOG=/opt/app/oracle/admin/sgoijms/script/log/DelArch_$DATA.log
export STDB_DEL=/opt/app/oracle/admin/sgoijms/script/DelArch.rcv

sqlplus -S /nolog <<EOF>$STDB_DEL
conn / as sysdba
set serveroutput on feedback off
begin
dbms_output.put_line('run{'||chr(10)||'allocate channel c1 device type disk;');
dbms_output.put_line('crosscheck backup;');
dbms_output.put_line('crosscheck archivelog all;');
dbms_output.put_line('crosscheck copy;');
dbms_output.put_line('catalog start with '||chr(39)||'/u01/FLASH_RECOVERY_AREA/SGOIJMS/'||chr(39)||' noprompt;');
for x in (
select a.sequence#,a.thread#
from v\$archived_log a, v\$log_history b
where a.name is not null
  and a.sequence#=b.sequence#
  and a.thread#=b.thread#
)loop
dbms_output.put_line('delete force noprompt archivelog sequence '||x.sequence#||' thread '||x.thread#||';');
end loop;
dbms_output.put_line('delete noprompt backup of archivelog all completed before ''sysdate-2'';');
dbms_output.put_line('release channel c1;');
dbms_output.put_line('}');
end;
/
quit;
EOF

rman target \'/ as sysdba \' cmdfile $STDB_DEL msglog $DEL_LOG


