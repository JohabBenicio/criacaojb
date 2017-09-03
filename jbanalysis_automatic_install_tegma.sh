
rm -f /tmp/conf_jbanalisys.sh
cd /

vi /tmp/conf_jbanalisys.sh
i


clear

echo -e "\n-- ---------------------------------------------------------------------------------------------------"
echo "-- Autor               : Johab Benicio de Oliveira."
echo "-- Descrição           : Coleta dados do ambiente e mantem como histórico para realização de analises."
echo "-- Nome do arquivo     : jbanalysis.sql"
echo "-- Data de criação     : 20/01/2015"
echo "-- Data de atualização : 20/05/2015"
echo -e "-- ---------------------------------------------------------------------------------------------------\n"


read -p "Informe o nome do cliente: " NCLI

if [ -e "$ORACLE_BASE/admin/scripts/analysis/sh/sendmail_log.sh" ]; then
cat $ORACLE_BASE/admin/scripts/analysis/sh/sendmail_log.sh | grep "TO=" | cut -d '=' -f 2 2>>/dev/null
echo -e "\n"
fi
if [ -e "$ORACLE_BASE/admin/script/analysis/sh/sendmail_log.sh" ]; then
cat $ORACLE_BASE/admin/script/analysis/sh/sendmail_log.sh | grep "TO=" | cut -d '=' -f 2 2>>/dev/null
echo -e "\n"
fi

NCLIENTE=$(echo $NCLI | sed 's/ //g')

read -p "Vai enviar email? Sim (1): " ENV_EMAIL_BKP

if [ "$ENV_EMAIL_BKP" != "1" ] || [ -z "$ENV_EMAIL_BKP" ]; then export ENV_EMAIL_BKP=2; fi

if [ "$ENV_EMAIL_BKP" -eq "1" ]; then

  read -p "Informe seu email da teor. Exemplo: johab@teor.inf.br: " EMAIL_DBA
  if [ -z "$EMAIL_DBA" ]; then  echo -e "\n           Informe seu e-mail! \n\n"; exit; fi

fi

if [ -z "$EMAIL_DBA" ]; then export EMAIL_DBA=suporte@teor.inf.br; fi

DIRCOPLOG=/tmp/jhb$NCLIENTE

if [ -d "$ORACLE_BASE/admin/scripts" ]; then
    export ANL_BASE=$ORACLE_BASE/admin/scripts
    if [ -d "$ANL_BASE/analysis" ]; then
      mkdir -p $DIRCOPLOG
      cp -pr $ANL_BASE/analysis/log $DIRCOPLOG
      cp -p $ANL_BASE/analysis/sh/jbstatus_standby.sh $DIRCOPLOG 2>>/dev/null
      tar -czf /tmp/bkp_jbanalisys_$(date +"%d%m%Y").tar.gz $ANL_BASE/analysis 2>>/dev/null; rm -rf $ANL_BASE/analysis/*; mv /tmp/bkp_jbanalisys_$(date +"%d%m%Y").tar.gz $ANL_BASE/analysis;
    fi
    mkdir -p $ANL_BASE/analysis 2>>/dev/null
    export ANL_HOME=$ANL_BASE/analysis
    cat $ANL_HOME/sh/sendmail_log.sh 2>>/dev/null

elif [ -d "$ORACLE_BASE/admin/script" ]; then
    export ANL_BASE=$ORACLE_BASE/admin/script
    if [ -d "$ANL_BASE/analysis" ]; then
      mkdir -p $DIRCOPLOG
      cp -pr $ANL_BASE/analysis/log $DIRCOPLOG
      cp -p $ANL_BASE/analysis/sh/jbstatus_standby.sh $DIRCOPLOG 2>>/dev/null
      tar -czf /tmp/bkp_jbanalisys_$(date +"%d%m%Y").tar.gz $ANL_BASE/analysis 2>>/dev/null; rm -rf $ANL_BASE/analysis/*; mv /tmp/bkp_jbanalisys_$(date +"%d%m%Y").tar.gz $ANL_BASE/analysis;
      cp -pr $DIRCOPLOG/log $ANL_BASE/analysis
    fi
    mkdir -p $ANL_BASE/analysis 2>>/dev/null
    export ANL_HOME=$ANL_BASE/analysis
    cat $ANL_HOME/sh/sendmail_log.sh 2>>/dev/null

else
  mkdir -p $ORACLE_BASE/admin/scripts 2>>/dev/null
  export ANL_BASE=$ORACLE_BASE/admin/scripts
  mkdir -p $ANL_BASE/analysis 2>>/dev/null
  export ANL_HOME=$ANL_BASE/analysis
fi

mkdir -p $ANL_HOME/sh 2>>/dev/null
mkdir -p $ANL_HOME/sql 2>>/dev/null
mkdir -p $ANL_HOME/log 2>>/dev/null
mkdir -p $ANL_HOME/temp 2>>/dev/null
cp -pr $DIRCOPLOG/log/* $ANL_BASE/analysis/log/
cp -p $DIRCOPLOG/jbstatus_standby.sh $ANL_BASE/analysis/sh 2>>/dev/null

cd $ANL_HOME

cat <<EOF1>$ANL_HOME/exec_jbanalysis.sh
#!/bin/bash

export ORACLE_BASE=$ORACLE_BASE
export ORACLE_HOME=$ORACLE_HOME
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:/lib:/usr/lib;
export PATH=$PATH


export ANL_BASE=$ANL_BASE
export ANL_HOME=$ANL_HOME
export LHOST=$ANL_HOME/temp/lhost.log


HOST=\`hostname\`

export HOSTNAME=\$(echo \$HOST | cut -f1 -d".")
export NCLIENTE=$NCLIENTE

rm -f \$ANL_HOME/temp/*




#
# QTD Linhas do Alert.log
#
export NUMALT=500

#
# Modo de conexão
#
export CONN_SQL='sqlplus -S / as sysdba'


export NOME_LOG=Analise_$NCLIENTE\_\$HOSTNAME\_\`date +"%d"_"%b"_"%G"_"%H%M"\`.log

export LOG1=\$ANL_HOME/log/\$NOME_LOG

export LOG2=\$ANL_HOME/log/Analise_DBA_$NCLIENTE_\$HOSTNAME_\`date +"%d"_"%b"_"%G"_"%H%M"\`.log

rm -f \$LOG1
rm -f \$LOG2

ps -ef | grep smon | grep -v opuser | grep -v -i "asm\|osysmond.bin\|grep" | sed 's/.*mon_\(.*\)$/\1/' | while read instance
do
export ORACLE_SID=\$instance

sh \$ANL_HOME/sh/exec_oracle_sql.sh 1>>/dev/null 2>>/dev/null


done

COMPACT=\$(ls \$ANL_HOME/log/Analise*.log 2>>/dev/null | wc -l)

if [ "\$COMPACT" -gt "60" ]; then
  tar -cvzf \$ANL_HOME/log/Analise_$NCLIENTE_\$ORACLE_SID_\`date +"%d"_"%b"_"%G"\`.tar.gz \$ANL_HOME/log/Analise*.log
  rm -f \$ANL_HOME/log/Analise*.log
fi

sh \$ANL_HOME/sh/carrega_log.sh > \$LOG1

#rm -f \$ANL_HOME/temp/*


echo -e "\n\n" >> \$LOG1

EOF1

if [ "$ENV_EMAIL_BKP" -eq "1" ]; then

cat <<EOF1>>$ANL_HOME/exec_jbanalysis.sh

sh \$ANL_HOME/sh/sendmail_log.sh 2>>/dev/null


EOF1

fi



cat <<EOF>$ANL_HOME/sh/carrega_log.sh
#!/bin/bash
echo -e "\n============================================================================================"
echo "========================================= DADOS S.O ========================================"
echo -e "============================================================================================\n"

sh $ANL_HOME/sh/jbhost.sh

echo -e "\n============================================================================================"
echo "==================================== LISTENER ORACLE ======================================="
echo -e "============================================================================================\n"

find \$ORACLE_BASE -name listener.log | while read LOG
do
   SIZE=\$(du -m \$LOG | awk '{print \$1 }' )
   BKP=\$LOG\_\$(date +"%d%m%Y").bkp
   if [ "\$SIZE" -gt "1024" ]; then
     cp \$LOG \$BKP 1>>/dev/null
     tar -cvzf \$BKP.tar.gz \$BKP 1>>/dev/null 2>>/dev/null
     rm -f \$BKP
     if [ "\$?" -eq "0" ]; then
        echo -e "\nLog do listener antigo."
        du -h \$LOG
        echo " " > \$LOG
        echo -e "\nBackup do log."
        du -h \$BKP.tar.gz

     fi
   fi
   echo -e "\nLog do Listener atual."
        du -h \$LOG
done


STAND=\$(find $ORACLE_BASE -name jbstatus_standby.sh)

if [ ! -z "\$STAND" ] && [ -e "\$STAND" ]; then

echo -e "\n============================================================================================"
echo "======================================= SINC STANDBY ======================================="
echo -e "============================================================================================\n"

\$STAND

fi

echo -e "\n============================================================================================"
echo "================================= DADOS DO BANCO E INSTANCIA ==============================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/jbdb_ins.log

echo -e "\n============================================================================================"
echo "====================================== PARAMETRO ==========================================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/parameter.log


echo -e "\n============================================================================================"
echo "================================= ARMAZENAMENTO ============================================"
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/storage.log

echo -e "\n============================================================================================"
echo "================================ LAST SESSIONs EXEC ========================================"
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/jblast_query.log

echo -e "\n============================================================================================"
echo "===================================== LOCK SESSION ========================================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/jblock.log


echo -e "\n============================================================================================"
echo "====================================== LOCK TABLE =========================================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/jbusing_table.log


echo -e "\n============================================================================================"
echo "==================== ESTATISTICAS PARA O OTIMIZADOR DE CONSULTAS (CBO) ====================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/CBO.log

echo -e "\n============================================================================================"
echo "==================================== OBJETOS-INVALIDOS ====================================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/compile.log

echo -e "\n============================================================================================"
echo "=================================== ARCHIVING HISTORY ======================================"
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/perf_log_switch_history_daily_all.log


echo -e "\n============================================================================================"
echo "=================================== ALERT LOG =============================================="
echo -e "============================================================================================\n"

cat \$ANL_HOME/temp/alert.log



EOF




function f_sendmail (){
clear
cat <<EOF
#####################################################################################
Descrição: Informe o diretorio mais nome do sendemail

Exemplo: /u01/app/oracle/admin/scripts/standby/sendEmail

Aguarde a execucao do find e locate: find $ORACLE_BASE -name "*sendEmail*"

EOF
locate sendEmail 2>>/dev/null
find $ORACLE_BASE -name "*sendEmail*" 2>>/dev/null
echo -e "\n"
read -p "Informe o nome do sendEmail: " vsendemail
if [ -z "$vsendemail" ]; then
    echo "Opcao nao valida, tente novamente."; sleep 2; f_sendmail
fi
}

f_sendmail


cat <<EOF1>$ANL_HOME/sh/sendmail_log.sh

#
# Email
#

TO=$EMAIL_DBA
SENDEMAIL=$vsendemail
MENS=$ANL_HOME/temp/Mensagem_email.txt


cat <<EOF>\$MENS
Prezado Cliente,

Segue em anexo a analise do host \$(hostname).
Favor abrir o arquivo "\$(basename \$LOG1)" com algum browser de internet para melhor visualizacao.


Att,
Teor Tecnologia.

EOF


\$SENDEMAIL -f dbmonitor@teor.inf.br -t \$TO -s smtp.teor.inf.br:587 -u "Analise $NCLIENTE" -o message-file=\$MENS -a \$LOG1 -xu "dbmonitor@teor.inf.br" -xp "ju5u6hxi"

EOF1








cat <<EOF02>$ANL_HOME/sh/jbhost.sh
#!/bin/bash
echo "== ========================================================================================="
echo "== Cliente: $NCLIENTE"
echo "== Servidor: $HOSTNAME"
echo "== ========================================================================================="

#############################################################

echo -e "\n "
echo "DISCOS"
echo "========="
df -PhT | column -t

#############################################################

echo -e "\n "
echo "TOP"
echo "========="
top -bd 2 -n 1 -sc | head -n 30

#############################################################

echo -e "\n "
echo "VMSTAT"
echo "========="
vmstat 1 10

#############################################################

echo -e "\n "

echo "MEMORIA TOTAL DO SERVIDOR"
echo "=========================="

free -m | grep -i mem | awk '{print \$2 " MB"}'


echo -e "\n "

echo "SWAP USADO"
echo "==========="

#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Analise de consumo de Swap
#-- Nome do arquivo     : jbls_swap.sql
#-- Data de criação     : 01/07/2014
#-- -----------------------------------------------------------------------------------

export JBSWPERUS=\$(free -m | grep wap | awk  '{ print "Total de Swap Usado: " (\$3 * 100) / \$2 "%"}');
export JBSWUSGB=\$(free -m | grep wap | awk  '{ print "Swap Usado: " \$3/1024 " GB"}');
export JBSWUSMB=\$(free -m | grep wap | awk  '{ print "Swap Usado: " \$3 " MB" }');

export JBSWPERFR=\$(free -m | grep wap | awk  '{ print "Total de Swap Livre: " (\$4 * 100) / \$2 "%"}');
export JBSWFRGB=\$(free -m | grep wap | awk  '{ print "Swap Livre: " \$4/1024 " GB"}');
export JBSWFRMB=\$(free -m | grep wap | awk  '{ print "Swap Livre: " \$4 " MB" }');

echo " " ;echo \$JBSWPERUS;echo \$JBSWUSGB;echo \$JBSWUSMB;echo '';echo \$JBSWPERFR;echo \$JBSWFRGB;echo \$JBSWFRMB; echo -e '\n';



EOF02




cat <<EOF>$ANL_HOME/sql/jbdb_ins.sql
set feedback off;
pro
#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Consulta de verifiucação do banco de dados
#-- Nome do arquivo     : jbdb_ins.sql
#-- Data de criação     : 02/04/2014
#-- -----------------------------------------------------------------------------------

set lines 500 long 500;
col STATUS for a15
col "OPEN MODE" for a11
col "INSTANCIA" for a10
col VERSAO for a58
col "MODO ARCHIVE" for a15
SELECT INS.INSTANCE_NAME INSTANCIA,
  INS.PARALLEL RAC,
  INS.STATUS,
  DAT.NAME DATABASE,
  DAT.OPEN_MODE "OPEN MODE",
  DAT.LOG_MODE "MODO ARCHIVE",
  VER.BANNER VERSAO
FROM v\$INSTANCE INS, v\$DATABASE DAT, v\$VERSION VER
WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';
pro
EOF





cat <<EOF>$ANL_HOME/sql/parameter.sql


pro
select UPPER(instance_name) Instance from v\$instance;
pro
set pages 200 lines 200
col name for a40
col value for a30

SELECT name, VALUE FROM v\$parameter WHERE lower(NAME) in ('sga_max_size','sga_target','pga_aggregate_target','undo_management','undo_retention','undo_tablespace','audit_trail','db_file_multiblock_read_count','cursor_sharing','compatible','use_large_pages','java_pool_size','large_pool_size','olap_page_pool_size','shared_pool_reserved_size','shared_pool_size','shared_pool_size','streams_pool_size');

pro



EOF


ASM=$(ps -ef | grep -i "+asm" | grep -v "grep" | wc -l)

if [ "$ASM" -gt "0" ]; then

cat <<EOF>$ANL_HOME/sql/storage.sql

set feedback off

select UPPER(instance_name) Instance from v\$instance;
pro
set feed off
 col TMDB for 999,999,999 heading 'TAMANHO DB EM MB'
 select sum(bytes)/1024/1024 TMDB from dba_segments;
pro
SET LINESIZE  145
SET PAGESIZE  9999
SET VERIFY    off

COLUMN group_name             FORMAT a20           HEAD 'Disk Group|Name'
COLUMN sector_size            FORMAT 99,999        HEAD 'Sector|Size'
COLUMN block_size             FORMAT 99,999        HEAD 'Block|Size'
COLUMN allocation_unit_size   FORMAT 999,999,999   HEAD 'Allocation|Unit Size'
COLUMN state                  FORMAT a11           HEAD 'State'
COLUMN type                   FORMAT a6            HEAD 'Type'
COLUMN total_mb               FORMAT 999,999,999   HEAD 'Total Size (MB)'
COLUMN used_mb                FORMAT 999,999,999   HEAD 'Used Size (MB)'
COLUMN free_mb                FORMAT 999,999,999   HEAD 'Free Size (MB)'
COLUMN pct_used               FORMAT 999.99        HEAD 'Pct. Used'
COLUMN pct_free               FORMAT 999.99        HEAD 'Pct. Free'

break on report on disk_group_name skip 1

compute sum label "Grand Total: " of total_mb used_mb on report

SELECT
    '+'||name                                     group_name
  , sector_size                              sector_size
  , block_size                               block_size
  , allocation_unit_size                     allocation_unit_size
  , state                                    state
  , type                                     type
  , total_mb                                 total_mb
  , (total_mb - free_mb)                     used_mb
  , free_mb
  , ROUND((1- (free_mb / total_mb))*100, 2)  pct_used
  , ROUND((1- ((total_mb - free_mb) / total_mb))*100, 2)  pct_livre
FROM
    v\$asm_diskgroup
WHERE
    name is not null
ORDER BY
    name
/

EOF

else

cat <<EOF>$ANL_HOME/sql/storage.sql

set feedback off

select UPPER(instance_name) Instance from v\$instance;
pro
set feed off

 col TMDB for 999,999,999 heading 'TAMANHO DB EM MB'
 select sum(bytes)/1024/1024 TMDB from dba_segments;

EOF


fi

cat <<EOF>>$ANL_HOME/sql/storage.sql

pro
set pages 9999 lines 9999
COL KTABLESPACE   FOR A27      HEADING 'Tablespace'
COL KTBS_SIZE     FOR 9,999,990  HEADING 'Tamanho|atual'       JUSTIFY RIGHT
COL KTBS_EM_USO   FOR 9,999,990  HEADING 'Em uso'              JUSTIFY RIGHT
COL KTBS_MAXSIZE  FOR 999,999,990  HEADING 'Tamanho|maximo'      JUSTIFY RIGHT
COL KFREE_SPACE   FOR 9,999,990  HEADING 'Espaco|livre atual'  JUSTIFY RIGHT
COL KSPACE        FOR 999,999,990  HEADING 'Espaco|livre total'  JUSTIFY RIGHT
COL KPERC         FOR 990      HEADING '%|Ocupacao'          JUSTIFY RIGHT

break on report

compute sum label Total: of ktbs_size    on report
compute sum              of ktbs_em_uso  on report
compute sum              of ktbs_maxsize on report
compute sum              of kfree_space  on report
compute sum              of kspace       on report

select t.tablespace_name ktablespace,
       substr(t.contents, 1, 1) tipo,
       trunc((d.tbs_size-nvl(s.free_space, 0))/1024/1024) ktbs_em_uso,
       trunc(d.tbs_size/1024/1024) ktbs_size,
       trunc(d.tbs_maxsize/1024/1024) ktbs_maxsize,
       trunc(nvl(s.free_space, 0)/1024/1024) kfree_space,
       trunc((d.tbs_maxsize - d.tbs_size + nvl(s.free_space, 0))/1024/1024) kspace,
       decode(d.tbs_maxsize, 0, 0, trunc((d.tbs_size-nvl(s.free_space, 0))*100/d.tbs_maxsize)) kperc
from
  ( select SUM(bytes) tbs_size,
           SUM(decode(sign(maxbytes - bytes), -1, bytes, maxbytes)) tbs_maxsize,
           tablespace_name tablespace
    from ( select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_data_files
           union all
           select nvl(bytes, 0) bytes, nvl(maxbytes, 0) maxbytes, tablespace_name
           from dba_temp_files
         )
    group by tablespace_name
  ) d,
  ( select SUM(bytes) free_space,
           tablespace_name tablespace
    from dba_free_space
    group by tablespace_name
  ) s,
  dba_tablespaces t
where t.tablespace_name = d.tablespace(+) and
      t.tablespace_name = s.tablespace(+)
order by 8;


EOF

















cat <<EOF>$ANL_HOME/sql/datafile.sql

set feedback off
pro
set lines 1000 pages 1000

col kbytes           format 99,999,990  heading File|size(MB)
col kmaxsize         format 99,999,990  heading Max|size(MB)
col kautoextensible  format a4         heading Auto
--col incr             format a12         heading Inc|size(MB)
col incr             format 9999        heading INC
col ktablespace_name format a27        heading Tablespace
col kstatus          format a7        heading Status
col kfile_id         format 990        heading File#
col kfile_name       format a68        heading File

select trunc(a.bytes/1024/1024) kbytes,
       trunc(a.maxbytes/1024/1024)  kmaxsize,
       a.autoextensible kautoextensible,
       a.increment_by*t.block_size/1024/1024 as incr,
       a.tablespace_name ktablespace_name,
       b.status kstatus,
       a.file_id kfile_id,
       a.file_name kfile_name
from dba_data_files a, v\$datafile b, dba_tablespaces t
where a.file_id = b.file#
and t.tablespace_name = a.tablespace_name
order by a.tablespace_name, a.file_name;
pro
pro
pro
pro TAMANHOS DOS SCHEMAS
pro ---------------------

set serveroutput on
set feedback off

-- -----------------------------------------------------------------------------------------#
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Trazer usuario(s) e seu tamanho
-- Nome do arquivo     : jbsizeowner_all.sql
-- Data de criação     : 15/07/2014
-- Data de atualização : 27/08/2014
-- -----------------------------------------------------------------------------------------#
-- http://www.idevelopment.info/data/Oracle/DBA_tips/Database_Administration/DBA_26.shtml

--------------------------------------------------------------------------------------------#
-- TRAZER TODOS USUARIOS COM SEU TAMANHO ----------------------------------------------------#
--------------------------------------------------------------------------------------------#


set serveroutput on
set feedback off

declare
    JBQB VARCHAR2(2) := CHR(13) || CHR(10);
    v_size varchar2(90);
    v_sum varchar2(20);
    v_owner varchar2(50);
    v_instance varchar2(20);
begin

    select instance_name into v_instance from v\$instance;
    dbms_output.put_line('NOME DA INSTANCIA:......................... ' || upper(v_instance));

    for x in (SELECT OWNER, SUM(BYTES) sum FROM DBA_SEGMENTS WHERE
        OWNER NOT IN ('SYS','SYSTEM','OUTLN','SCOTT','ANONYMOUS','AURORA\\\$ORB\\\$UNAUTHENTICATED','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','TRACESVR','TSMSYS','XDB','SYSMAN','WKSYS','WKPROXY','OLAPSYS','OWBSYS','MGMT_VIEW','SI_INFORMTN_SCHEMA','WMSYS')
        GROUP BY OWNER order by sum desc) loop

        v_sum:=x.sum;
        v_owner:=x.owner;


        dbms_output.put_line('NOME DO USUARIO:........... ' || v_owner);

        v_size:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))-1); v_size:=rtrim( ltrim( v_size ) );

        if v_size = '' or v_size is null then
            v_size:=v_sum /1024/1024/1024;
        end if;

        if v_size >= 1 then
            v_size:=substr(v_sum /1024/1024/1024,1,(INSTR(v_sum /1024/1024/1024,'.'))+3);
            select replace(v_size,'.',',') into v_size from dual;
            dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' GB' || JBQB );

        else
            v_size:=substr(v_sum /1024/1024,1,(INSTR(v_sum /1024/1024,'.'))-1); v_size:=rtrim( ltrim( v_size ) );

            if v_size = '' or v_size is null then
                v_size:=v_sum /1024/1024;
            end if;

            if v_size >= 1 then
                select replace(v_size,'.',',') into v_size from dual;
                dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' MB' || JBQB);

            else
                v_size:=substr(v_sum /1024,1,(INSTR(v_sum /1024,'.'))-1); v_size:=rtrim( ltrim( v_size ) );

                if v_size = '' or v_size is null then
                    v_size:=v_sum /1024;
                end if;

                if v_size >= 1 then
                    dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_size || ' KB' || JBQB);
                else
                    dbms_output.put_line('TAMANHO DO OWNER:.......... ' || v_sum || ' BYTES' || JBQB);
                end if;
            end if;
        end if;
    end loop;
end;
/

pro
pro
pro
EOF

cat <<EOF>$ANL_HOME/sql/jblast_query.sql

set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro

#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuario(s) ativos e seu tempo de atividade junto com detalhes de sua sessão
#-- Nome do arquivo     : jblast_query.sql
#-- Data de criação     : 28/08/2014
#-- Data de atualização : 05/03/2015
#-- ---------------------------------------------------------------------------------------------------------#

set lines 200
set serveroutput on
set echo off

declare

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);
vnumquery numeric(3):='999';
vretorn varchar2(3):='Y';
vpe varchar2(10):='N';

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin

select upper(instance_name) into vinstance from v\$instance;
select upper(name) into vdatabase from v\$database;

if vnumquery is null then
vnumquery:=100;
end if;

for x in (
 select * from (
  SELECT s.sid, s.serial# serial, s.last_call_et, s.sql_id, s.status, s.username, s.osuser, p.spid, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine
  FROM gv\$process p, gv\$session s
  WHERE p.addr = s.paddr and s.sql_hash_value != 0  and s.username is not null  and audsid != userenv('SESSIONID') and s.last_call_et>43200
  ORDER BY s.last_call_et desc ) where rownum <vnumquery ORDER BY last_call_et asc
)loop

  dbms_output.put_line('INFORMACOES DO BANCO DE DADOS');
  dbms_output.put_line('SID:............................. ' || x.sid);
  dbms_output.put_line('SERIAL:.......................... ' || x.serial);
  dbms_output.put_line('INSTANCIA:....................... ' || vinstance);
  dbms_output.put_line('BANCO DE DADOS:.................. ' || vdatabase || JBQB);

  dbms_output.put_line('ORACLE USER:..................... ' || x.username);
  dbms_output.put_line('STATUS:.......................... ' || x.status);
  DBMS_OUTPUT.PUT_LINE('INSTANCE ID:..................... ' || 'NODE ' || x.inst_id);
  --dbms_output.put_line(x.last_call_et/60/60);
  vtmpm := substr(x.last_call_et/60,1,(INSTR(x.last_call_et/60,'.'))-1);
  if vtmpm is null then
    vtmpm := substr(x.last_call_et/60,1,(INSTR(x.last_call_et/60,','))-1);
    if vtmpm is null then
      vtmpm := x.last_call_et/60;
    end if;
  end if;

  vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
  if vtmph is null then
    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
    if vtmph is null then
      vtmph := vtmpm/60;
    end if;
  end if;

  vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,'.') )-1 );
  if vtmpd is null then
    vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,',') )-1 );
  end if;


  if x.last_call_et < 86400 then
    if x.last_call_et < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpm || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  elsif x.last_call_et > 86400 then
    vtmps:=x.last_call_et-(vtmpd*86400);

    vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,'.'))-1);
    if vtmpm is null then
      vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,','))-1);
      if vtmpm is null then
        vtmpm := vtmps/60;
      end if;
    end if;

    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
    if vtmph is null then
      vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
      if vtmph is null then
        vtmph := vtmpm/60;
      end if;
    end if;

    if vtmps < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  end if;

  dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
  dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);
  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S PID:......................... ' || x.spid);
  dbms_output.put_line('O/S USER:........................ ' || x.osuser);
  dbms_output.put_line('MAQUINA:......................... ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state || JBQB);

  if x.sql_hash_value <> 0 then
    dbms_output.put_line('SQL HASH VALUE:.................. ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v\$sql where HASH_VALUE=' || x.sql_hash_value || ';'||JBQB);

      if upper(vretorn)='Y' then
        for query_loop in (select sql_text from v\$sql where HASH_VALUE=x.sql_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_text||chr(10));
        end loop;
        dbms_output.put_line(chr(10));
      end if;

      if upper(vpe)='Y' then
        dbms_output.put_line('PLANO(s) DE EXECUCAO CRIADO(s) PARA ESTA QUERY:...');
        for pe in (SELECT distinct PLAN_HASH_VALUE FROM v\$sql_plan where HASH_VALUE=x.sql_hash_value )LOOP
             dbms_output.put_line(pe.PLAN_HASH_VALUE||', ');
        END LOOP;

        dbms_output.put_line(chr(10));

        for pe in (SELECT PLAN_TABLE_OUTPUT FROM TABLE(dbms_xplan.display_cursor(x.sql_hash_value)) )LOOP
          dbms_output.put_line(pe.PLAN_TABLE_OUTPUT);
        END LOOP;
        dbms_output.put_line(JBQB||JBQB||JBQB||JBQB||JBQB||JBQB);
      END IF;


    dbms_output.put_line(JBQB||'============================================================================================'||JBQB);
  end if;

end loop;

SELECT nvl(count(sid),0) into vvalid FROM gv\$process p, gv\$session s
WHERE p.addr =  s.paddr and s.sql_hash_value is not null and s.sql_hash_value <> 0  and s.username is not null and audsid != userenv('SESSIONID');

if vvalid = 0 then
  dbms_output.put_line(JBQB);
  dbms_output.put_line('NESTE MOMENTO NAO HA USUARIOS EXECUTANDO PROCESSOS NO BANCO DE DADOS.');
  dbms_output.put_line(JBQB);
end if;


end;
/


pro
pro
pro ============================================================================================
pro ================================ PROCESS e SESSCIONS =======================================
pro ============================================================================================
pro
pro


set serveroutput on
declare
qtd_proc varchar2(90);
BEGIN
for y in (select * from gv\$resource_limit where resource_name in ('processes','sessions') )loop
  dbms_output.put_line('NODE: '||y.inst_id);
  dbms_output.put_line('RESOURCE NAME........... '||ltrim(rtrim(y.resource_name)));
  dbms_output.put_line('CURRENT UTILIZATION..... '||ltrim(rtrim(y.current_utilization)));
  dbms_output.put_line('MAX UTILIZATION......... '||ltrim(rtrim(y.max_utilization)));
  dbms_output.put_line('INITIAL ALLOCATION...... '||ltrim(rtrim(y.initial_allocation)));
  dbms_output.put_line('LIMIT VALUE............. '||ltrim(rtrim(y.limit_value)) ||chr(10));

end loop;

for x in (select username,inst_id,count(*) qtd_sess from gv\$session where username is not null and status='ACTIVE' group by username,inst_id order by qtd_sess desc)LOOP
  select count(*) into qtd_proc from gv\$process p, gv\$session s where p.addr=s.paddr and p.inst_id=x.inst_id and s.username=x.username and status='ACTIVE';

  if x.qtd_sess > 20 or qtd_proc > 20 then
    dbms_output.put_line(chr(10)||chr(10)||'SESSOES ATIVAS');
    dbms_output.put_line('NODE: '||x.inst_id ||chr(10)|| 'OWNER:............ '||x.username );
    dbms_output.put_line('QTD. SESSAO:...... '||x.qtd_sess);
    dbms_output.put_line('QTD. PROCESS:..... '||qtd_proc||chr(10)||chr(10));
  end if;

END LOOP;


for x in (select username,inst_id,count(*) qtd_sess from gv\$session where username is not null and status='ACTIVE' group by username,inst_id order by qtd_sess desc)LOOP
  select count(*) into qtd_proc from gv\$process p, gv\$session s where p.addr=s.paddr and p.inst_id=x.inst_id and s.username=x.username and status='INACTIVE';

  if x.qtd_sess > 20 or qtd_proc > 20 then
    dbms_output.put_line('SESSOES INATIVAS');
    dbms_output.put_line('NODE: '||x.inst_id ||chr(10)|| 'OWNER:............ '||x.username );
    dbms_output.put_line('QTD. SESSAO:...... '||x.qtd_sess);
    dbms_output.put_line('QTD. PROCESS:..... '||qtd_proc||chr(10)||chr(10));
  end if;

END LOOP;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/


pro
pro


EOF


cat <<EOF>$ANL_HOME/sql/jblock.sql
set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro


-- -----------------------------------------------------------------------------------
-- Autor               : Johab Benicio de Oliveira.
-- Descrição           : Dados de loks de sessoes
-- Nome do arquivo     : jblock.sql
-- Data de criação     : 01/07/2014
-- Data de atualização : 08/06/2016
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 200 pages 2000 long 999999
col sql_fulltext for a200

declare
v_query_max_lock varchar2(20);
vloop_lock_qtd varchar2(20);
vvalid varchar2(90);
JBQB VARCHAR2(90) := CHR(13) || CHR(10);

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;
v_hist varchar2(20):='S';
v_tables varchar2(20):='S';

begin
if v_hist is null then
    v_hist:='N';
end if;
if v_tables is null then
    v_tables:='N';
end if;


for ljb in (
    select l1.sid,max(l2.ctime) ctime,l1.id1,l1.id2,l1.TYPE
    from gv\$lock l1, gv\$lock l2
    where l1.block>0 and l2.block=0 and l1.id1=l2.id1 and l1.id2=l2.id2
    group by l1.sid,l1.id1,l1.id2,l1.TYPE
    order by 2 asc
) loop

for x in (
    select s.saddr,s.sid,s.prev_hash_value,s.sql_hash_value,s.username,s.status,s.osuser,s.machine,s.program,s.serial#,i.instance_name,i.host_name,s.sql_id,s.inst_id,to_char(s.logon_time,'dd/mm/yyyy hh24:mi:ss') logon_time
    from gv\$session s, gv\$instance i where sid=ljb.sid and s.inst_id=i.inst_id and username is not null
) loop
vvalid:= x.username;


    dbms_output.put_line(rpad('+',40,'+')||' BLOQUEADOR '||rpad('+',40,'+')||chr(10));
    dbms_output.put_line('DATABASE INFORMATION:');
    dbms_output.put_line(rpad('USUARIO BLOQUEADOR:',29,'.')||chr(32)||lpad(x.username,10,' ')||chr(32)||chr(32)||rpad(' | STATUS:',29,'.')||chr(32)||x.status );
    dbms_output.put_line(rpad('SID:',29,'.')||chr(32)||lpad(x.sid,10,' ')||chr(32)||chr(32)||rpad(' | SERIAL#:',29,'.')||chr(32)||x.serial# );
    dbms_output.put_line(rpad('INSTANCE:',29,'.')||chr(32)||lpad(x.instance_name,10,' ')||chr(32)||chr(32)||rpad(' | SERVIDOR INSTANCE:',29,'.')||chr(32)||x.host_name||chr(10) );
    dbms_output.put_line('LOGON TIME:.................. '||x.logon_time);

    vtmpm := substr(ljb.ctime/60,1,(INSTR(ljb.ctime/60,'.'))-1);
    if vtmpm is null then
        vtmpm := substr(ljb.ctime/60,1,(INSTR(ljb.ctime/60,','))-1);
        if vtmpm is null then
            vtmpm := ljb.ctime/60;
        end if;
    end if;

    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
    if vtmph is null then
        vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
        if vtmph is null then
            vtmph := vtmpm/60;
        end if;
    end if;

    vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,'.') )-1 );
    if vtmpd is null then
        vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,',') )-1 );
    end if;

    if ljb.ctime < 60 then
        dbms_output.put_line('TIME LOCK:................... ' || ljb.ctime || ' SEGUNDO(s)' || JBQB );
        elsif ljb.ctime < 3600 then
        dbms_output.put_line('TIME LOCK:................... ' || vtmpm || ' MINUTO(s) E ' || (ljb.ctime-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif ljb.ctime > 3600 then
        dbms_output.put_line('TIME LOCK:................... ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

-- Forma de acesso

    dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
    dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);

-- Dados SO

    dbms_output.put_line('S.O INFORMATION:');

    for xy in (
            select nvl(spid,0) spid from gv\$process p, gv\$session s
            where p.addr = s.paddr and s.sid = x.sid
    ) loop
        if xy.spid <> 0 then
            dbms_output.put_line('PID:......................... ' || xy.spid);
        end if;
    end loop;

    dbms_output.put_line('S/O USER:.................... ' || x.osuser);
    dbms_output.put_line('MACHINE:..................... ' || x.machine || JBQB);
    dbms_output.put_line('KILL SESSION:');
    dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||',@'||x.inst_id||''' immediate;' || JBQB);

-- Dados do lock

if x.sql_hash_value > 0 then
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('TIPO DO LOCK:..... ' || ljb.TYPE);
    dbms_output.put_line('HASH ATUAL:....... ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT: '||chr(10)||' select sql_fulltext from gv\$sql where sql_id=''' || x.sql_id || ''';' || JBQB);
else
    dbms_output.put_line('LOCK INFORMATION:');
    dbms_output.put_line('NESTE MOMENTO O HASH_VALUE ESTA COMO 0');
end if;

if upper(v_hist) = 'S' or upper(v_hist) = 'Y' then
    dbms_output.put_line(chr(10)||'HISTORICO DE EXECUCAO: ');
    dbms_output.put_line('QUERY TEXT');

        for oc in (select SQL_ID from gv\$open_cursor where sid=x.sid and user_name=x.username )
        LOOP
            for ot in (select distinct sql_text from v\$sql where
                   ((upper(SQL_FULLTEXT) like upper('UPDATE %') or upper(SQL_FULLTEXT) like upper('% UPDATE %'))
                or (upper(SQL_FULLTEXT) like upper('DELETE %') or upper(SQL_FULLTEXT) like upper('% DELETE %'))
                or (upper(SQL_FULLTEXT) like upper('LOCK TABLE%') or upper(SQL_FULLTEXT) like upper('% LOCK TABLE %'))) and SQL_ID=oc.SQL_ID)
            LOOP
                    dbms_output.put_line('select sql_fulltext from v\$sql where SQL_ID='|| chr(39) || oc.SQL_ID || chr(39) || ';');
            END LOOP;

        END LOOP;
end if;

-- Mostra o tipo do objeto e a quantidade em lock

    for tab_z in
    (
        SELECT distinct O.OBJECT_TYPE FROM gv\$locked_object l, DBA_OBJECTS O, gv\$session s
        where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
    ) loop
        vloop_lock_qtd:=0;

        for tab_y in
        (
            SELECT O.OBJECT_TYPE FROM gv\$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
        ) loop
            if tab_y.OBJECT_TYPE = tab_z.OBJECT_TYPE then vloop_lock_qtd:= vloop_lock_qtd + 1; end if;
        end loop;
        dbms_output.put_line(chr(10)||'QTD DE OBJETOS EM LOCK:...... ' || vloop_lock_qtd || ' ' || tab_z.OBJECT_TYPE || JBQB);

    end loop;

if upper(v_tables) = 'S' or upper(v_tables) = 'Y' then
    for tab_z in
    (
        SELECT distinct O.OBJECT_TYPE FROM gv\$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid
    ) loop

        dbms_output.put_line(tab_z.OBJECT_TYPE || '(s) EM LOCK:::::::::::::' );
        for tab_x in
        (
            SELECT O.OBJECT_NAME,O.OWNER,
            Decode(l.LOCKED_MODE, 0, 'None',1, 'Null (NULL)',2, 'Row-S (SS)',3, 'Row-X (SX)',4, 'Share (S)',5, 'S/Row-X (SSX)',6, 'Exclusive (X)',l.LOCKED_MODE) LOCKED_MODE FROM gv\$locked_object l, DBA_OBJECTS O
            WHERE L.OBJECT_ID = O.OBJECT_ID AND  O.OBJECT_TYPE=tab_z.OBJECT_TYPE AND L.SESSION_ID = x.sid
        ) loop
            dbms_output.put_line(rpad(tab_x.OWNER || '.' || tab_x.OBJECT_NAME||chr(32),50,'-') || '> ' || tab_x.LOCKED_MODE);
        end loop;
    end loop;
end if;
    dbms_output.put_line(chr(10)||rpad('+',92,'+')||chr(10));

    dbms_output.put_line('============================ BLOQUEADO ============================ ');
    for v_block in (
        select s.inst_id,s.sid,s.serial#,s.sql_id,l.TYPE,s.username,s.osuser from gv\$session s, gv\$lock l
        where s.sid=l.sid and request>0 and l.id1=ljb.id1 and l.id2=ljb.id2
    ) loop

        dbms_output.put_line('.... SID: ' || rpad(v_block.sid,6,' ') || ' | SERIAL#: ' || rpad(v_block.serial#,6,' ') || ' | Tipo do Lock: '||rpad(v_block.type,6,' ')||' | S/O USER: '||rpad(v_block.osuser,15,' ') || ' | USER DB: '||  rpad(nvl(v_block.username,'- - - - - - - -'),15,' ')|| ' | SQL_ID: '||rpad(nvl(v_block.sql_id,'- - - - - - - '),15,' ')||' | INSTANCIA: '||v_block.inst_id);
    end loop;
dbms_output.put_line(JBQB || JBQB );
end loop;

end loop;


if vvalid is null then
    dbms_output.put_line('- ------------------------------------------ -');
    dbms_output.put_line('- NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO -');
    dbms_output.put_line('- ------------------------------------------ -');
    dbms_output.put_line( JBQB || JBQB );
end if;

end;
/


pro
pro
EOF



cat <<EOF>$ANL_HOME/sql/jbusing_table.sql

set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro
#-- ---------------------------------------------------------------------------------------------------------#
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Trazer usuarios que estao usando a tabela informada e seus detalhes
#-- Nome do arquivo     : jbusing_table.sql
#-- Data de criação     : 19/11/2014
#-- ---------------------------------------------------------------------------------------------------------#

set lines 100
set serveroutput on
set echo off
set feedback off

declare

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;
vpid varchar2(2000);
vvalidanalise varchar2(9);

begin

select upper(instance_name) into vinstance from v\$instance;
select upper(name) into vdatabase from v\$database;

SELECT count(s.sid) into vvalidanalise FROM gv\$process p, gv\$session s,gv\$locked_object l, dba_objects o WHERE s.username is not null and l.session_id=s.sid and l.object_id=o.object_id and s.last_call_et>3600 ORDER BY s.last_call_et asc;

if vvalidanalise = 0 then
dbms_output.put_line('NESTE MOMENTO NAO EXISTE LOCK DE TABELAS COM MAIS DE 1 HORA NESTA INSTANCIA.');
else

for x in (
   SELECT s.sid, s.last_call_et, s.status, s.username, s.osuser, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine,o.object_name,DECODE ( l.locked_mode, 0, 'None', 1, 'NoLock', 2, 'Row-Share (SS)', 3, 'Row-Exclusive (SX)', 4, 'Share-Table', 5, 'Share-Row-Exclusive (SSX)', 6, 'Exclusive','[Nothing]')   LOCKED_MODE,o.owner,o.object_type,s.serial# serial
   FROM gv\$process p, gv\$session s,gv\$locked_object l, dba_objects o
   WHERE s.username is not null and l.session_id=s.sid and l.object_id=o.object_id and s.last_call_et>3600
   group by s.sid, s.serial# , s.last_call_et, s.status, s.username, s.osuser, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine,o.object_name,l.locked_mode,o.owner,o.object_type
   ORDER BY s.last_call_et asc
)loop


  for y in ( SELECT p.spid from gv\$process p, gv\$session s where s.sid=x.sid and s.serial#=x.serial and p.addr = s.paddr and p.spid is not null) LOOP

    if vpid is not null then
      vpid:=y.spid ||', '|| vpid;
      null;
    else
      vpid:=y.spid;
    end if;
  END LOOP;


  dbms_output.put_line('INFORMACOES DO BANCO DE DADOS');
  dbms_output.put_line('SID:............................. ' || x.sid);
  dbms_output.put_line('SERIAL:.......................... ' || x.serial);
  dbms_output.put_line('INSTANCIA:....................... ' || vinstance);
  dbms_output.put_line('BANCO DE DADOS:.................. ' || vdatabase || JBQB);

  dbms_output.put_line('ORACLE USER:..................... ' || x.username);
  dbms_output.put_line('STATUS:.......................... ' || x.status);
  DBMS_OUTPUT.PUT_LINE('INSTANCE ID:..................... ' || 'NODE ' || x.inst_id);

  vtmpm := substr(x.last_call_et/60,1,(INSTR(x.last_call_et/60,'.'))-1);
  if vtmpm is null then
    vtmpm := substr(x.last_call_et/60,1,(INSTR(x.last_call_et/60,','))-1);
    if vtmpm is null then
      vtmpm := x.last_call_et/60;
    end if;
  end if;

  vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
  if vtmph is null then
    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
    if vtmph is null then
      vtmph := vtmpm/60;
    end if;
  end if;

  vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,'.') )-1 );
  if vtmpd is null then
    vtmpd := substr( (vtmph/24), 1, ( INSTR(vtmph/24,',') )-1 );
  end if;


  if x.last_call_et < 86400 then
    if x.last_call_et < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || x.last_call_et || ' SEGUNDO(s)' || JBQB );
      elsif x.last_call_et < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpm
        || ' MINUTO(s) E ' || (x.last_call_et-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif x.last_call_et > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmph
        || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  elsif x.last_call_et > 86400 then
    vtmps:=x.last_call_et-(vtmpd*86400);

    vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,'.'))-1);
    if vtmpm is null then
      vtmpm := substr(vtmps/60,1,(INSTR(vtmps/60,','))-1);
      if vtmpm is null then
        vtmpm := vtmps/60;
      end if;
    end if;

    vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,'.') )-1 );
    if vtmph is null then
      vtmph := substr( (vtmpm/60), 1, ( INSTR(vtmpm/60,',') )-1 );
      if vtmph is null then
        vtmph := vtmpm/60;
      end if;
    end if;

    if vtmps < 60 then
        dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd
          || ' DIA(s) DE EXECUCAO E ' || vtmps || ' SEGUNDO(s)' || JBQB );
      elsif vtmps < 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd
        || ' DIA(s) DE EXECUCAO E ' || vtmpm || ' MINUTO(s) E ' || (vtmps-(vtmpm*60)) || ' SEGUNDO(s)' || JBQB );
    elsif vtmps > 3600 then
      dbms_output.put_line('TEMPO DE EXECUCAO:............... ' || vtmpd
        || ' DIA(s) DE EXECUCAO E ' || vtmph || ' HORA(s) E ' || (vtmpm-(vtmph*60)) || ' MINUTO(s)' || JBQB );
    end if;

  end if;

  dbms_output.put_line('FORMA DE CONEXAO (programa usado):');
  dbms_output.put_line('SESSION PROGRAM:................. ' || x.program || JBQB);

  dbms_output.put_line('INFORMACOES DA TABELA');
  dbms_output.put_line('DONO DA TABELA:.................. ' || x.owner );
  dbms_output.put_line('NOME DA TABELA:.................. ' || x.object_name || JBQB );

  dbms_output.put_line('INFORMACOES DO SERVIDOR');
  dbms_output.put_line('O/S PID:......................... ' || vpid);
  dbms_output.put_line('O/S USER:........................ ' || x.osuser);
  dbms_output.put_line('SERVIDOR:........................ ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state);
  dbms_output.put_line('TIPO DE LOCK:.................... ' || x.locked_mode );
  if x.sql_hash_value <> 0 then
    dbms_output.put_line(JBQB || 'SQL HASH VALUE:.................. ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v\$sql where HASH_VALUE=' || x.sql_hash_value || ';');
  end if;
  dbms_output.put_line('=============================================================================================='||JBQB||JBQB);

end loop;


end if;

end;
/

pro
pro
EOF


cat <<EOF>$ANL_HOME/sql/CBO.sql
set lines 200
set feedback off
pro
pro
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';
select UPPER(instance_name) Instance from v\$instance;

pro
pro
pro COLETA DE ESTATISTICA
pro +++++++++++++++++++++++
pro

set lines 999 pages 999

COL Mais_Atual               HEADING 'Estatistica|mais recente'
COL Mais_Antigo              HEADING 'Estatistica|mais antigo'
COL Total        FOR 999,990 HEADING 'Qtde|total'               JUSTIFY RIGHT
COL Analisado    FOR 999,990 HEADING 'Qtde com|estatistica'     JUSTIFY RIGHT
COL owner        FOR A30     HEADING 'Esquema'

set feed off
alter session set nls_date_format='dd/mm/yyyy hh24:mi:ss';

pro Tabelas
pro =======

select max(last_analyzed) Mais_Atual,
        min(last_analyzed) Mais_Antigo,
        count(*) Total,
        count(last_analyzed) Analisado,
        owner
 from dba_tables
 group by owner order by Mais_Atual desc;

pro
pro Indices
pro =======

select max(last_analyzed) Mais_Atual,
        min(last_analyzed) Mais_Antigo,
        count(*) Total,
        count(last_analyzed) Analisado,
        owner
 from dba_indexes
 group by owner order by Mais_Atual desc;

pro
EOF


cat <<EOF> $ANL_HOME/sql/jbrman_status.sql
set feedback off
set feedback off
pro
set lines 200 long 200 pages 200
col name for a80
col status for a25
col START_DATA for a10
col START_HORA for a8
col "HORA FIM" for a15

select * from (select b.instance_name, a.object_type, a.status, to_char(a.start_time,'DD/MM/YYYY') start_data, to_char(a.start_time,'hh24:mi:ss') start_hora, 'ate as ' || to_char(a.end_time ,'hh24:mi:ss') "HORA FIM"
from v\$rman_status a, v\$instance b
where to_char(a.start_time,'mm')=to_char(sysdate,'mm') and a.object_type!='ARCHIVELOG' and a.object_type is not null and rownum <=7 order by start_data asc) db
union all
select * from (select b.instance_name, a.object_type, a.status, to_char(a.start_time,'DD/MM/YYYY') start_data, to_char(a.start_time,'hh24:mi:ss') start_hora, 'ate as ' || to_char(a.end_time ,'hh24:mi:ss') "HORA FIM"
from v\$rman_status a, v\$instance b
where to_char(a.start_time,'mm')=to_char(sysdate,'mm') and a.object_type='ARCHIVELOG' and rownum <=10 order by start_data asc) arch;

EOF


cat <<EOF>$ANL_HOME/sql/compile.sql
set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro
select count(*) AS "OBJETOS INVALIDOS"
from
    dba_objects
where
    STATUS = 'INVALID' and
    OBJECT_TYPE in ( 'PACKAGE BODY', 'PACKAGE', 'FUNCTION', 'PROCEDURE',
                      'TRIGGER', 'VIEW' );
EOF


cat <<EOF>$ANL_HOME/sql/spfile.sql
pro
set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro
show parameter spfile;
EOF


cat <<EOF>$ANL_HOME/sql/perf_log_switch_history_daily_all.sql

set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro
-- +----------------------------------------------------------------------------+
-- |                          Jeffrey M. Hunter                                 |
-- |                      jhunter@idevelopment.info                             |
-- |                         www.idevelopment.info                              |
-- |----------------------------------------------------------------------------|
-- |      Copyright (c) 1998-2007 Jeffrey M. Hunter. All rights reserved.       |
-- |----------------------------------------------------------------------------|
-- | DATABASE : Oracle                                                          |
-- | FILE     : perf_log_switch_history_daily_all.sql                           |
-- | CLASS    : Tuning                                                          |
-- | PURPOSE  : Reports on how often log switches occur in your database on a   |
-- |            daily basis. It will query all records contained in             |
-- |            v\$log_history. This script is to be used with an Oracle 8       |
-- |            database or higher.                                             |
-- | NOTE     : As with any code, ensure to test this script in a development   |
-- |            environment before attempting to run it in production.          |
-- +----------------------------------------------------------------------------+

SET LINESIZE 150
SET PAGESIZE 9999
SET VERIFY   off

COLUMN ME    FORMAT 99
COLUMN H00   FORMAT 999     HEADING '00'
COLUMN H01   FORMAT 999     HEADING '01'
COLUMN H02   FORMAT 999     HEADING '02'
COLUMN H03   FORMAT 999     HEADING '03'
COLUMN H04   FORMAT 999     HEADING '04'
COLUMN H05   FORMAT 999     HEADING '05'
COLUMN H06   FORMAT 999     HEADING '06'
COLUMN H07   FORMAT 999     HEADING '07'
COLUMN H08   FORMAT 999     HEADING '08'
COLUMN H09   FORMAT 999     HEADING '09'
COLUMN H10   FORMAT 999     HEADING '10'
COLUMN H11   FORMAT 999     HEADING '11'
COLUMN H12   FORMAT 999     HEADING '12'
COLUMN H13   FORMAT 999     HEADING '13'
COLUMN H14   FORMAT 999     HEADING '14'
COLUMN H15   FORMAT 999     HEADING '15'
COLUMN H16   FORMAT 999     HEADING '16'
COLUMN H17   FORMAT 999     HEADING '17'
COLUMN H18   FORMAT 999     HEADING '18'
COLUMN H19   FORMAT 999     HEADING '19'
COLUMN H20   FORMAT 999     HEADING '20'
COLUMN H21   FORMAT 999     HEADING '21'
COLUMN H22   FORMAT 999     HEADING '22'
COLUMN H23   FORMAT 999     HEADING '23'
COLUMN TOTAL FORMAT 999,999 HEADING 'Total'

SELECT
    TO_CHAR(first_time, 'MM') MES
  , SUBSTR(TO_CHAR(first_time, 'DD/MM/RRRR HH:MI:SS'),1,10)                       DAY
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'00',1,0)) H00
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'01',1,0)) H01
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'02',1,0)) H02
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'03',1,0)) H03
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'04',1,0)) H04
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'05',1,0)) H05
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'06',1,0)) H06
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'07',1,0)) H07
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'08',1,0)) H08
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'09',1,0)) H09
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'10',1,0)) H10
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'11',1,0)) H11
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'12',1,0)) H12
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'13',1,0)) H13
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'14',1,0)) H14
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'15',1,0)) H15
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'16',1,0)) H16
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'17',1,0)) H17
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'18',1,0)) H18
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'19',1,0)) H19
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'20',1,0)) H20
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'21',1,0)) H21
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'22',1,0)) H22
  , SUM(DECODE(SUBSTR(TO_CHAR(first_time, 'DD/MM/RR HH24:MI:SS'),10,2),'23',1,0)) H23
  , COUNT(*)                                                                      TOTAL
FROM
  v\$log_history  a
where TO_CHAR(first_time, 'MM/RRRR') = (select to_char(sysdate,'mm/rrrr') from dual)
or TO_CHAR(first_time, 'MM/RRRR') = (select to_char(sysdate,'mm') -1||'/'||to_char(sysdate,'rrrr') from dual)
GROUP BY SUBSTR(TO_CHAR(first_time, 'DD/MM/RRRR HH:MI:SS'),1,10),TO_CHAR(first_time, 'MM')
Order by 1,2
/


EOF

cat <<EOF>$ANL_HOME/sql/alert_log.sql
conn / as sysdba
set feedback off
set serveroutput on

declare
x varchar2(90);
y varchar2(90);
BEGIN

select VALUE into x from v\$parameter where NAME='background_dump_dest';
select instance_name into y from v\$instance;

dbms_output.put_line(x||'/alert_'||y||'.log'||chr(10));

END;
/
exit
EOF

cat <<EOF1>$ANL_HOME/sh/alert.sh

function producao {
\$CONN_SQL <<EOF
@\\\$ANL_HOME/sql/alert_log.sql
EOF
}

ALERT=\$(producao)

echo "" ;echo ""
echo "#-- -------------------------------------------------------------------------------------------------"
echo "#-- ALERT LOG: (Alertas nas ultimas \$NUMALT linhas) - \$ORACLE_SID"
echo "#-- -------------------------------------------------------------------------------------------------"
echo "#-- \$ALERT"
echo ""
tail -\$NUMALT \$ALERT 2>>/dev/null | grep -4i "ORA-" | while read ALERT_LOG
do
  echo \$ALERT_LOG
done



SIZE=\$(du -m \$ALERT | awk '{print \$1 }' )
BKP=\$ALERT\_\$(date +"%d%m%Y").bkp
if [ "\$SIZE" -gt "1024" ]; then
  du -m \$ALERT
  cp \$ALERT \$BKP
  tar -cvzf \$BKP.tar.gz \$BKP
  rm -f \$BKP
  if [ "\$?" -eq "0" ]; then
     echo -e "\nTamanho do alert.log antigo." >> \$LOG1
     du -h \$ALERT >> \$LOG1
     echo " " > \$ALERT >> \$LOG1
     echo -e "\nBackup do alert.log." >> \$LOG1
     du -h \$BKP.tar.gz >> \$LOG1
     echo -e "\nTamanho do alert.log atual." >> \$LOG1
     du -h \$ALERT >> \$LOG1
  fi
fi

echo -e "\n" >> \$LOG1


EOF1



cat <<EOF1>$ANL_HOME/sh/jbfilt.sh
#!/bin/bash

VAL2=\$(cat -n $ANL_HOME/temp/instance_log.log | grep "\$1"2 | awk '{ print \$1-1}')
VAL1=\$(cat -n $ANL_HOME/temp/instance_log.log | head "-\$VAL2" | grep "\$1"1 | awk '{ print \$1+1}')
VAL3=\$(echo \$VAL2-\$VAL1 | bc)

cat \$ANL_HOME/temp/instance_log.log | head "-\$VAL2" | tail "-\$VAL3"

EOF1


cat <<EOXEXEC>$ANL_HOME/sh/exec_oracle_sql.sh


\$CONN_SQL <<EOF>\$ANL_HOME/temp/instance_log.log

set echo off;
set feedback off;

pro jbdb_ins1
@\$ANL_HOME/sql/jbdb_ins.sql
pro
pro
pro jbdb_ins2

pro parameter1
@\$ANL_HOME/sql/parameter.sql
pro
pro
pro parameter2


pro storage1
@\$ANL_HOME/sql/storage.sql
pro
pro
pro storage2

pro datafile1
@\$ANL_HOME/sql/datafile.sql
pro
pro
pro datafile2

pro jblast_query1
@\$ANL_HOME/sql/jblast_query.sql
pro
pro
pro jblast_query2

pro jblock1
@\$ANL_HOME/sql/jblock.sql
pro
pro
pro jblock2

pro jbusing_table1
@\$ANL_HOME/sql/jbusing_table.sql
pro
pro
pro jbusing_table2

pro CBO1
@\$ANL_HOME/sql/CBO.sql
pro
pro
pro CBO2

pro jbrman_status1
@\$ANL_HOME/sql/jbrman_status.sql
pro
pro
pro jbrman_status2

pro compile1
@\$ANL_HOME/sql/compile.sql
pro
pro
pro compile2

pro spfile1
@\$ANL_HOME/sql/spfile.sql
pro
pro
pro spfile2

pro perf_log_switch_history_daily_all1
@\$ANL_HOME/sql/perf_log_switch_history_daily_all.sql
pro
pro
pro perf_log_switch_history_daily_all2

EOF

VALID_LOG=\$(cat \$ANL_HOME/temp/instance_log.log | grep -i "ORA-01219\|ORA-01034\|Session ID: 0 Serial number: 0" | wc -l)

if [ "\$VALID_LOG" -eq "0" ]; then

sh \$ANL_HOME/sh/backup_log.sh >> \$ANL_HOME/temp/backup_log.log

sh \$ANL_HOME/sh/alert.sh >>\$ANL_HOME/temp/alert.log

sh \$ANL_HOME/sh/jbfilt.sh jbdb_ins >> \$ANL_HOME/temp/jbdb_ins.log

sh \$ANL_HOME/sh/jbfilt.sh parameter >> \$ANL_HOME/temp/parameter.log

sh \$ANL_HOME/sh/jbfilt.sh storage >> \$ANL_HOME/temp/storage.log
sh \$ANL_HOME/sh/jbfilt.sh datafile >> \$ANL_HOME/temp/storage.log
sh \$ANL_HOME/sh/jbfilt.sh jblast_query >> \$ANL_HOME/temp/jblast_query.log
sh \$ANL_HOME/sh/jbfilt.sh jblock >> \$ANL_HOME/temp/jblock.log
sh \$ANL_HOME/sh/jbfilt.sh jbusing_table >> \$ANL_HOME/temp/jbusing_table.log
sh \$ANL_HOME/sh/jbfilt.sh CBO >> \$ANL_HOME/temp/CBO.log
sh \$ANL_HOME/sh/jbfilt.sh compile >> \$ANL_HOME/temp/compile.log
sh \$ANL_HOME/sh/jbfilt.sh spfile >> \$ANL_HOME/temp/spfile.log
sh \$ANL_HOME/sh/jbfilt.sh perf_log_switch_history_daily_all >> \$ANL_HOME/temp/perf_log_switch_history_daily_all.log

CONT_BKP=\$(sh \$ANL_HOME/sh/jbfilt.sh jbrman_status )
if [ ! -z "\$CONT_BKP" ]; then
  sh \$ANL_HOME/sh/jbfilt.sh jbrman_status >> \$ANL_HOME/temp/jbrman_status.log
fi

fi

EOXEXEC




cat <<EOF


#+---------------------------------------------------------------------------------------------------------------------------------------------+
## ANALISE AMBIENTE                                                                                                                            |
#+---------------------------------------------------------------------------------------------------------------------------------------------+
# Minute Hour  MonthDay Month  Weekday Command
# ------ ----- -------- ------ ------- --------------------------------------------------------------------------------------------------------+
  00     15    *        *      *       $ANL_HOME/exec_jbanalysis.sh 1>/dev/null 2>/dev/null

EOF



chmod -R 755 $ANL_HOME/sh $ANL_HOME/exec_jbanalysis.sh

rm -f /tmp/conf_jbanalisys.sh

rm -rf $DIRCOPLOG
