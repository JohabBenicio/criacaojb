

-- DESABILITAR COLETA AUTOMATICA DO BANCO

/*
BEGIN
  DBMS_AUTO_TASK_ADMIN.DISABLE(
  client_name => 'auto optimizer stats collection',
  operation => NULL,
  window_name => NULL);
END;
/



select client_name,status from dba_autotask_client;





if [ -d "$ORACLE_BASE/admin/scripts" ]; then
    export STAT_BASE=$ORACLE_BASE/admin/scripts
    export STAT_HOME=$STAT_BASE/statistic
    cd $STAT_HOME
elif [ -d "$ORACLE_BASE/admin/script" ]; then
    export STAT_BASE=$ORACLE_BASE/admin/script
    export STAT_HOME=$STAT_BASE/statistic
    cd $STAT_HOME
fi




set lines 200 pages 9999
col COMMENTS for a80
SELECT owner, job_name, enabled FROM dba_scheduler_jobs where job_name like 'STATS\_%' escape '\' order by job_name;





set lines 200 pages 9999
col COMMENTS for a80
SELECT count(*) FROM dba_scheduler_jobs where job_name like 'STATS\_%' escape '\' order by job_name;







begin
  for cursor1 in (select owner, job_name from dba_scheduler_jobs where job_name like 'STATS\_%' escape '\')
  loop
    begin
      dbms_scheduler.stop_job (cursor1.owner || '.' || cursor1.job_name, true);
    exception
      when others then
        null;
    end;

    begin
      dbms_scheduler.drop_job (cursor1.owner || '.' || cursor1.job_name);
    exception
      when others then
        null;
    end;
  end loop;
end;
/






create user teorstat identified by Teor123;
grant connect,resource,ANALYZE ANY,ANALYZE ANY DICTIONARY to teorstat;
grant execute on dbms_stats to teorstat;
quit;





if [ -d "$ORACLE_BASE/admin/scripts" ]; then
    export STAT_BASE=$ORACLE_BASE/admin/scripts
    mkdir -p $STAT_BASE/statistic 2>>/dev/null
    export STAT_HOME=$STAT_BASE/statistic
elif [ -d "$ORACLE_BASE/admin/script" ]; then
    export STAT_BASE=$ORACLE_BASE/admin/script
    mkdir -p $STAT_BASE/statistic 2>>/dev/null
    export STAT_HOME=$STAT_BASE/statistic
else
  mkdir -p $ORACLE_BASE/admin/scripts 2>>/dev/null
  export STAT_BASE=$ORACLE_BASE/admin/scripts
  mkdir -p $STAT_BASE/statistic 2>>/dev/null
  export STAT_HOME=$STAT_BASE/statistic
fi

mkdir $STAT_HOME/log
mkdir $STAT_HOME/dump


cd $STAT_HOME


cat <<JHB>$STAT_HOME/exec_statistic.sh

#!/bin/bash
# Teor Tecnologia Orientada
#
# Criado em 07/01/2016
#
# Executa a coleta de estatistica dos owners listado.
#
# Versao para Linux
# \$1 ORACLE_SID

#
## Inicio
#

LIST_SCHEMAS="'IV00_INTERVIAS'"

if [ -z "\$1" ]; then
   echo "Digite: sh \$0 <SID> ou \$0 <SID>" ;
   exit;
fi
STAT_HOME="$STAT_HOME"
export LOG="\$STAT_HOME/log/collection_statistic.log"
export DATA=\`date +%d%m%Y\`

BANCO=\$(ps -ef | grep smon | grep \$1 | sed 's/.*mon_\(.*\)\$/\1/' | grep -E "(^| )\$1( |\$)")

if [ "\$BANCO" != "\$1" ]; then
   echo -e "Banco \$1 nao esta no ar \n" >> \$LOG
   exit;
fi
export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi

VORATAB=\$(grep \$BANCO\: /etc/oratab | wc -l)
if [ "\$VORATAB" -eq "1" ]; then
export ORAENV_ASK=NO ; ORACLE_SID=\$BANCO ; . oraenv; export ORAENV_ASK=YES;
else
export ORACLE_SID=\$BANCO
fi



SCHEMAS=\$(echo "\$LIST_SCHEMAS" | tr [a-z] [A-Z])

# Backup das estatisticas

echo "Inicio do backup das estatistica  da instancia \$ORACLE_SID -> \$(date)" >> \$LOG

sqlplus /nolog <<EOF
conn teorstat/Teor123
drop table STATS_SCHEMA_TEOR purge;
execute dbms_stats.create_stat_table (ownname => 'TEORSTAT', stattab => 'STATS_SCHEMA_TEOR');
EXEC DBMS_STATS.export_schema_stats('WMSPRD2','STATS_SCHEMA_TEOR',NULL,'TEORSTAT');

exit;

EOF

if [ ! -d "\$STAT_HOME/dump/\$ORACLE_SID" ]; then
mkdir -p \$STAT_HOME/dump/\$ORACLE_SID
fi

exp \'/ as sysdba \' file=\$STAT_HOME/dump/\$ORACLE_SID/exp_statistic_schema_\$DATA.dmp log=\$STAT_HOME/dump/\$ORACLE_SID/exp_statistic_schema_\$DATA.log TABLES="TEORSTAT.STATS_SCHEMA_TEOR"

rm -f \$STAT_HOME/dump/\$ORACLE_SID/exp_statistic_db_\$DATA.dmp.gz 2>>/dev/null
gzip \$STAT_HOME/dump/\$ORACLE_SID/exp_statistic_db_\$DATA.dmp

if [ "\$?" -eq "0" ]; then
  find \$STAT_HOME/dump/\$ORACLE_SID/exp*.gz -mtime +30 -exec rm -f {} \;
fi

echo "Fim do backup das estatistica da instancia \$ORACLE_SID -> \$(date)" >> \$LOG
echo -e "\n" >> \$LOG

# Executa o script de coleta

echo "Inicio do procedimento de coleta de estatistica da instancia \$ORACLE_SID -> \$(date)" >> \$LOG


sqlplus /nolog <<EOF
conn / as sysdba
declare
y number;
begin
select count(distinct inst_id) into y from gv\\\$session;
for x in (
select
   'begin ' || chr (10) || ' dbms_stats.gather_table_stats(ownname => ' || chr(39) || OWNER || chr(39) || ', tabname => ' || chr(39) || table_name || chr(39) ||
    ', estimate_percent => dbms_stats.auto_sample_size, method_opt => ''FOR ALL COLUMNS SIZE 1'', cascade => true, no_invalidate => false);' || chr(10) || 'end; ' cmd, rownum
from dba_tables
 where owner in (\$SCHEMAS)) LOOP
    dbms_scheduler.create_job(job_name => 'STATS_' || to_char (x.rownum), job_type => 'plsql_block', job_action => x.cmd, enabled => false, auto_drop => true);
    dbms_scheduler.set_attribute(name => 'STATS_' || to_char (x.rownum), attribute => 'instance_id', value => (mod (x.rownum, y) + 1));
    dbms_scheduler.enable(name => 'STATS_' || to_char (x.rownum));
END LOOP;
end;
/
exit;
EOF

echo "Fim do procedimento de coleta de estatistica da instancia \$ORACLE_SID -> \$(date)" >> \$LOG
echo -e "\n====================================================================\n" >> \$LOG

#
## FIM
#

JHB



chmod +x $STAT_HOME/exec_statistic.sh




cat <<JHB>$STAT_HOME/stop_statistic.sh

export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"

if [ -f ~/.bash_profile ]; then
. ~/.bash_profile;
elif [ ~/.profile ]; then
. ~/.profile
fi

export DATA=\`date +%d%m%Y\`
STAT_HOME="$STAT_HOME"
LOG="\$STAT_HOME/log/collection_statistic.log"

BANCO=\`ps -ef | grep smon | grep \$1 2>>/dev/null | sed 's/.*mon_\(.*\)\\$/\1/' | grep -E "(^| )\$1( |\$)"\`


if [ -z "\$1" ]; then
   echo "Digite: sh \$0 <SID> ou \$0 <SID>" ;
   exit;

elif [ "\$BANCO" = "\$1" ]; then
   export ORACLE_SID=\$1
else
   echo -e "Banco \$1 nao esta no ar \n" >> \$LOG
   exit;

fi


sqlplus /nolog <<EOF
conn / as sysdba

begin
  for cursor1 in (select owner, job_name from dba_scheduler_jobs where job_name like 'STATS\_%' escape '\')
  loop
    begin
      dbms_scheduler.stop_job (cursor1.owner || '.' || cursor1.job_name, true);
    exception
      when others then
        null;
    end;

    begin
      dbms_scheduler.drop_job (cursor1.owner || '.' || cursor1.job_name);
    exception
      when others then
        null;
    end;
  end loop;
end;
/

exit;

EOF

echo "Coleta de estatistica abortada da instancia \$ORACLE_SID -> \$(date)" >> \$LOG


JHB





chmod -R 775 $STAT_HOME/




cat <<EOF

Weekday
1 - Segunda
2 - Terca
3 - Quarta
4 - Quinta
5 - Sexta
6 - Sabado
7 - Domingo

#+-----------------------------------------------------------------------------------------------------------------------------------+
## COLETA DE ESTATISTICA DO BANCO DE DADOS                                                                                           |
#+-----------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour MonthDay Month Weekday Command
# ------ ---- -------- ----- ------- ------------------------------------------------------------------------------------------------+
  00     1    *        *     6       $STAT_HOME/exec_statistic.sh $ORACLE_SID 1>/dev/null 2>/dev/null


EOF








#+-----------------------------------------------------------------------------------------------------------------------------------+
## COLETA DE ESTATISTICA DO BANCO DE DADOS                                                                                           |
#+-----------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour MonthDay Month Weekday Command
# ------ ---- -------- ----- ------- ------------------------------------------------------------------------------------------------+
  00     02   *        *     2       /u01/app/oracle/admin/scripts/statistic/exec_statistic.sh sgap1 1>/dev/null 2>/dev/null







