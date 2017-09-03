
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
cat $ORACLE_BASE/admin/scripts/analysis/sh/sendmail_log.sh 2>>/dev/null
echo -e "\n"
fi
if [ -e "$ORACLE_BASE/admin/script/analysis/sh/sendmail_log.sh" ]; then
cat $ORACLE_BASE/admin/script/analysis/sh/sendmail_log.sh 2>>/dev/null
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

WEEKDAY=\`date +"%w"\`

if [ "\$WEEKDAY" = "1" ] || [ "\$WEEKDAY" = "3" ] || [ "\$WEEKDAY" = "5" ]; then
  sh \$ANL_HOME/sh/sendmail_log.sh 2>>/dev/null
fi

EOF1

fi



cat <<EOF>$ANL_HOME/sh/carrega_log.sh

echo "<head>"
echo "  <title>::JBAnalisys</title>"
echo "    <style >"
echo "  #titulo .tit"
echo "   { "
echo "    text-align:left; "
echo "    font-size:31px; "
echo "    font-weight: 900;"
echo "    padding:2;"
echo "   } "
echo "  #titulo "
echo "   { "
echo "    background-color:#C1C1C1 ; "
echo "    padding:1;"
echo "   }"
echo "   #gloss1"
echo "   {"
echo "    width:160px;"
echo "    background:fixed;"
echo "   }"
echo "   .tabela1"
echo "   { "
echo "    width: 80%; "
echo "    left: 5%; "
echo "    position: relative;"
echo "    border-collapse: separate;"
echo "    border-spacing: 6px;"
echo "  }"
echo "  </style>"
echo "</head>"
echo "<body scroll=\"no\" link=\"#3E443F\" vlink=\"#3E443F\" alink=\"#3E443F\"> "
echo "<div id=\"titulo\" style=\"position:fixed; width:97%\">"
echo "  <fieldset style=\"height:40px\">"
echo "    <div class=\"tit\">"
echo "      <div style=\"float:left\">"
echo "        <font style=\"font-family: Tahoma; color: #1C201C;\">JBAnalisys</font>"
echo "      </div>"
echo "      <br/>"
echo "    </div>"
echo "  </fieldset>"
echo "</div>"
echo "<br/>"
echo "<div id=\"gloss1\" style=\"position:fixed; width:178px; margin-top:50px\">"
echo "<fieldset style=\"display: block;"
echo "    margin-left: 2px;"
echo "    border: 2px groove;\"> "
echo "    <legend><font face=\"Verdana, Geneva, sans-serif\" ><b>Linux</b></font></legend>"
echo "<nav>"
echo "<li><a href=\"#Lunix1\">Partições S.O.</a></li>"
echo "<li><a href=\"#top\">Top</a></li>"
echo "<li><a href=\"#vmstat\">VMSTAT</a></li>"
echo "<li><a href=\"#memoria\">Memória</a></li>"
echo "<li><a href=\"#swap\">Swap</a></li>"
echo "<li><a href=\"#hugepages\">HugePages</a></li>"
echo "<div class=\"clear\"></div> "
echo "</nav>"
echo "</fieldset>"
echo "<fieldset style=\""
echo "    display: block;"
echo "    margin-left: 2px;"
echo "    border: 2px groove;\">"
echo "<legend><font face=\"Verdana, Geneva, sans-serif\" ><b>Database</b></font></legend>"
echo "<nav>"
echo "<li><a href=\"#listener\">Listener</a></li>"
echo "<li><a href=\"#db1\">Instancia(s)</a></li>"
echo "<li><a href=\"#db2\">Tuning</a></li>"
echo "<li><a href=\"#db3\">Parâmetros</a></li>"
echo "<li><a href=\"#db4\">Diskgroup</a></li>"
echo "<li><a href=\"#db5\">Tamanho DB</a></li>"
echo "<li><a href=\"#db6\">Tablespaces</a></li>"
echo "<li><a href=\"#db7\">Datafiles</a></li>"
echo "<li><a href=\"#db8\">Schemas</a></li>"
echo "<li><a href=\"#db9\">Last Query</a></li>"
echo "<li><a href=\"#db10\">Lock Session</a></li>"
echo "<li><a href=\"#db11\">Lock Teble(s</a></li>"
echo "<li><a href=\"#db12\">CBO</a></li>"
echo "<li><a href=\"#db13\">Estatistica</a></li>"
echo "<li><a href=\"#db14\">Objetos Invalidos</a></li>"
echo "<li><a href=\"#db15\">SPFILE</a></li>"
echo "<li><a href=\"#db16\">Archiving History</a></li>"
echo "<li><a href=\"#db17\">Alert log</a></li>"
echo "<div class=\"clear\">"
echo "</div> "
echo "</nav>"
echo "</fieldset>"
echo "</div>"
echo "<div id=\"conteudo_cent\" style=\" margin-left: 185px; margin-top: 57px; position:fixed; width:83%; widows:inherit\">"
echo "<fieldset style=\" height:500px;overflow:scroll;\" >"
echo "<a name=\"Lunix1\"><font face=\"Verdana, Geneva, sans-serif\"><b>Partições do Linus</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"10\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

df -PhT | column -t

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"top\"><font face=\"Verdana, Geneva, sans-serif\"><b>TOP</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"20\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

top -b -d 2 -n 1 -c | head -n 50

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"vmstat\"><font face=\"Verdana, Geneva, sans-serif\"><b>VMSTAT</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"10\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

vmstat 1 10

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"memoria\"><font face=\"Verdana, Geneva, sans-serif\"><b>Memória em MB</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"3\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

free -m | head -2

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"swap\"><font face=\"Verdana, Geneva, sans-serif\"><b>SWAP USADO</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"7\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

export JBSWPERUS=\$(free -m | grep wap | awk  '{ print "Total de Swap Usado: " (\$3 * 100) / \$2 "%"}');
export JBSWUSGB=\$(free -m | grep wap | awk  '{ print "Swap Usado: " \$3/1024 " GB"}');
export JBSWUSMB=\$(free -m | grep wap | awk  '{ print "Swap Usado: " \$3 " MB" }');

export JBSWPERFR=\$(free -m | grep wap | awk  '{ print "Total de Swap Livre: " (\$4 * 100) / \$2 "%"}');
export JBSWFRGB=\$(free -m | grep wap | awk  '{ print "Swap Livre: " \$4/1024 " GB"}');
export JBSWFRMB=\$(free -m | grep wap | awk  '{ print "Swap Livre: " \$4 " MB" }');

echo \$JBSWPERUS;echo \$JBSWUSGB;echo \$JBSWUSMB;echo '';echo \$JBSWPERFR;echo \$JBSWFRGB;echo \$JBSWFRMB;

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"hugepages\"><font face=\"Verdana, Geneva, sans-serif\"><b>HugePages</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"7\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

HUGEPAGES_TOTAL=\$(cat /proc/meminfo | grep -i "HugePages_Total" | awk '{ print \$NF }')

if [ "\$HUGEPAGES_TOTAL" -gt "0" ]; then

cat /proc/meminfo | grep -i hugepages

FREE=\$(cat /proc/meminfo | grep -i hugepages | grep -i "HugePages_Free" | awk '{print \$NF}' )
RSVD=\$(cat /proc/meminfo | grep -i hugepages | grep -i "HugePages_Rsvd" | awk '{print \$NF}' )
echo -e "\nHugePages_Free - HugePages_Rsvd: "\$(echo \$FREE-\$RSVD | bc) "\n "
echo "HugePages atual: vm.nr_hugepages = \$HUGEPAGES_TOTAL"
fi

# Check for the kernel version
KERN=\`uname -r | awk -F. '{ printf("%d.%d\n",\$1,\$2); }'\`

# Find out the HugePage size
HPG_SZ=\`grep Hugepagesize /proc/meminfo | awk {'print \$2'}\`

# Start from 1 pages to be on the safe side and guarantee 1 free HugePage
NUM_PG=1

# Cumulative number of pages required to handle the running shared memory segments
for SEG_BYTES in \`ipcs -m | awk {'print \$5'} | grep "[0-9][0-9]*" \`
do
   MIN_PG=\`echo "\$SEG_BYTES/(\$HPG_SZ*1024)" | bc -q\`
   if [ \$MIN_PG -gt 0 ]; then
      NUM_PG=\`echo "\$NUM_PG+\$MIN_PG+1" | bc -q\`
   fi
done

# Finish with results
case \$KERN in
   '2.4') HUGETLB_POOL=\`echo "\$NUM_PG*\$HPG_SZ/1024" | bc -q\`;
          echo "Recommended setting: vm.hugetlb_pool = \$HUGETLB_POOL" ;;
   '2.6') echo "Recommended setting: vm.nr_hugepages = \$NUM_PG" ;;
    *) echo "Unrecognized kernel version \$KERN. Exiting." ;;
esac
# End

echo -e "\nFonte: http://docs.oracle.com/cd/B28359_01/server.111/b32009/appi_vlm.htm#CACDCGAH"


echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"listener\"><font face=\"Verdana, Geneva, sans-serif\"><b>Listener</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"15\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

lsnrctl status


echo "</textarea>"
echo "<br/><br/>"
echo "<textarea rows=\"5\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

find \$ORACLE_BASE -name listener.log | while read LOG
do
   SIZE=\$(du -m \$LOG | awk '{print \$1 }' )
   BKP=\$LOG\_\$(date +"%d%m%Y").bkp
   if [ "\$SIZE" -gt "1024" ]; then
     cp \$LOG \$BKP 1>>/dev/null 
     tar -cvzf \$BKP.tar.gz \$BKP 1>>/dev/null 2>>/dev/null
     rm -f $BKP
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

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"listener\"><font face=\"Verdana, Geneva, sans-serif\"><b>Sinc. Standby</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"15\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

\$STAND

fi


echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db1\"><font face=\"Verdana, Geneva, sans-serif\"><b>Dados da(s) Instancia(s)</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"5\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/jbdb_ins.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db2\"><font face=\"Verdana, Geneva, sans-serif\"><b>Destribuição da memória</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"8\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/memory.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db3\"><font face=\"Verdana, Geneva, sans-serif\"><b>Parâmetros</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"15\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/parameter.log 


echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db4\"><font face=\"Verdana, Geneva, sans-serif\"><b>Espaço em Diskgroup</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"7\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/storage.log 




ASM=$(ps -ef | grep -i "asm" | grep -v "grep" | wc -l)

if [ "\$ASM" -eq "0" ]; then







fi


echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db9\"><font face=\"Verdana, Geneva, sans-serif\"><b>Execuções mais antigas</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"13\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/jblast_query.log 
 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db10\"><font face=\"Verdana, Geneva, sans-serif\"><b>Lock Session</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"13\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/jblock.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db11\"><font face=\"Verdana, Geneva, sans-serif\"><b>Lock Teble(s)</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"13\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/jbusing_table.log

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db12\"><font face=\"Verdana, Geneva, sans-serif\"><b>ESTATISTICAS PARA O OTIMIZADOR DE CONSULTAS (CBO)</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"13\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"


cat \$ANL_HOME/temp/CBO.log 


echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db18\"><font face=\"Verdana, Geneva, sans-serif\"><b>BACKUP FISICO</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"9\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/jbrman_status.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<textarea rows=\"9\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

crontab -l | grep "bkp_full.sh" 2>>/dev/null | grep -E "(^| )\$ORACLE_SID( |\$)" | awk '{ if (\$6=="*" || \$6=="sh" ) hm = \$7; else hm = \$6}  {print hm}'  | while read fisico
do
  BKP_HOME=\$(cat \$fisico 2>>/dev/null | grep "BACKUP_HOME=" | sed 's/.*=//')
  LOG=\$(ls -lthr \$BKP_HOME/log/*full* 2>>/dev/null | tail -1 | awk '{print \$NF}')

  echo -e "\n"
  ls -lh \$LOG
  echo -e "\n"
  tail -30 \$LOG
  echo -e "\n\n"
done

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db19\"><font face=\"Verdana, Geneva, sans-serif\"><b>BACKUP LOGICO</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"9\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

crontab -l | grep "exp" 2>>/dev/null | grep -E "(^| )\$ORACLE_SID( |\$)" | awk '{ if (\$6=="*" || \$6=="sh" ) hm = \$7; else hm = \$6}  {print hm}' | while read logico
do
if [ -e "\$logico" ]; then
BKP_HOME=\$(cat \$logico 2>>/dev/null | grep "DIR=" | sed 's/.*=//' | sed 's/\$ORACLE_SID/'\$ORACLE_SID'/')
LOG=\$(ls -lthr \$BKP_HOME/exp*.log 2>>/dev/null | tail -1 | awk '{print \$NF}')
echo -e "\n"
ls -lh \$LOG
echo -e "\n"
tail -30 \$LOG
echo -e "\n====================================================================================================\n"
fi
done



echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db14\"><font face=\"Verdana, Geneva, sans-serif\"><b>OBJETOS INVALIDOS</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"5\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/compile.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db15\"><font face=\"Verdana, Geneva, sans-serif\"><b>SPFILE</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"3\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/spfile.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db16\"><font face=\"Verdana, Geneva, sans-serif\"><b>ARCHIVING HISTORY</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"15\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/perf_log_switch_history_daily_all.log 

echo "</textarea>"
echo "<br/><br/>"
echo "<a name=\"db17\"><font face=\"Verdana, Geneva, sans-serif\"><b>ALERT LOG</b></font></a>"
echo "<br/>"
echo "<textarea rows=\"15\" cols=\"150\" style=\"font:'Courier New', Courier, monospace\">"

cat \$ANL_HOME/temp/alert.log 

echo "</textarea>"
echo "<div style=\"height:500px\">"
echo "</div>"
echo "</fieldset>"
echo "</div>"
echo "</body>"

EOF







cat <<EOF1>$ANL_HOME/sh/sendmail_log.sh

#
# Email
#

TO=$EMAIL_DBA

sendEmail -f dbmonitor@teor.inf.br -t \$TO -s smtp.teor.inf.br:587 -u "Analise $NCLIENTE" -m "Segue em anexo a analise do ambiente." -a \$LOG1 -xu "dbmonitor@teor.inf.br" -xp "ju5u6hxi"

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
top -b -d 2 -n 1 -c | head -n 50

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

echo \$JBSWPERUS;echo \$JBSWUSGB;echo \$JBSWUSMB;echo '';echo \$JBSWPERFR;echo \$JBSWFRGB;echo \$JBSWFRMB;


HUGEPAGES_TOTAL=\$(cat /proc/meminfo | grep -i "HugePages_Total" | awk '{ print \$NF }')

if [ "\$HUGEPAGES_TOTAL" -gt "0" ]; then

cat /proc/meminfo | grep -i hugepages

FREE=\$(cat /proc/meminfo | grep -i hugepages | grep -i "HugePages_Free" | awk '{print \$NF}' )
RSVD=\$(cat /proc/meminfo | grep -i hugepages | grep -i "HugePages_Rsvd" | awk '{print \$NF}' )
echo -e "\nHugePages_Free - HugePages_Rsvd: "\$(echo \$FREE-\$RSVD | bc) "\n "
echo "HugePages atual: vm.nr_hugepages = \$HUGEPAGES_TOTAL"
fi

# Check for the kernel version
KERN=\`uname -r | awk -F. '{ printf("%d.%d\n",\$1,\$2); }'\`

# Find out the HugePage size
HPG_SZ=\`grep Hugepagesize /proc/meminfo | awk {'print \$2'}\`

# Start from 1 pages to be on the safe side and guarantee 1 free HugePage
NUM_PG=1

# Cumulative number of pages required to handle the running shared memory segments
for SEG_BYTES in \`ipcs -m | awk {'print \$5'} | grep "[0-9][0-9]*" \`
do
   MIN_PG=\`echo "\$SEG_BYTES/(\$HPG_SZ*1024)" | bc -q\`
   if [ \$MIN_PG -gt 0 ]; then
      NUM_PG=\`echo "\$NUM_PG+\$MIN_PG+1" | bc -q\`
   fi
done

# Finish with results
case \$KERN in
   '2.4') HUGETLB_POOL=\`echo "\$NUM_PG*\$HPG_SZ/1024" | bc -q\`;
          echo "Recommended setting: vm.hugetlb_pool = \$HUGETLB_POOL" ;;
   '2.6') echo "Recommended setting: vm.nr_hugepages = \$NUM_PG" ;;
    *) echo "Unrecognized kernel version \$KERN. Exiting." ;;
esac
# End

echo -e "\nFonte: http://docs.oracle.com/cd/B28359_01/server.111/b32009/appi_vlm.htm#CACDCGAH"

echo -e "\n "


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



cat <<EOF>$ANL_HOME/sql/memory.sql

set feedback off
select UPPER(instance_name) Instance from v\$instance;
pro
-- -----------------------------------------------------------------------------------
-- File Name    : http://www.oracle-base.com/dba/monitoring/tuning.sql
-- Author       : DR Timothy S Hall
-- Description  : Displays several performance indicators and comments on the value.
-- Requirements : Access to the v\$ views.
-- Call Syntax  : @tuning
-- Last Modified: 15/07/2000
-- -----------------------------------------------------------------------------------

SET SERVEROUTPUT ON
SET LINESIZE 1000
SET FEEDBACK OFF

DECLARE
  v_value  NUMBER;

  FUNCTION Format(p_value  IN  NUMBER) 
    RETURN VARCHAR2 IS
  BEGIN
    RETURN LPad(To_Char(Round(p_value,2),'9990.00') || '%',8,' ') || '  ';
  END;

BEGIN

  -- --------------------------
  -- Dictionary Cache Hit Ratio
  -- --------------------------
  SELECT (1 - (Sum(getmisses)/(Sum(gets) + Sum(getmisses)))) * 100
  INTO   v_value
  FROM   v\$rowcache;

  DBMS_Output.Put('Dictionary Cache Hit Ratio       : ' || Format(v_value));
  IF v_value < 90 THEN
    DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 90%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;

  -- -----------------------
  -- Library Cache Hit Ratio
  -- -----------------------
  SELECT (1 -(Sum(reloads)/(Sum(pins) + Sum(reloads)))) * 100
  INTO   v_value
  FROM   v\$librarycache;

  DBMS_Output.Put('Library Cache Hit Ratio          : ' || Format(v_value));
  IF v_value < 99 THEN
    DBMS_Output.Put_Line('Increase SHARED_POOL_SIZE parameter to bring value above 99%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;

  -- -------------------------------
  -- DB Block Buffer Cache Hit Ratio
  -- -------------------------------
  SELECT (1 - (phys.value / (db.value + cons.value))) * 100
  INTO   v_value
  FROM   v\$sysstat phys,
         v\$sysstat db,
         v\$sysstat cons
  WHERE  phys.name  = 'physical reads'
  AND    db.name    = 'db block gets'
  AND    cons.name  = 'consistent gets';

  DBMS_Output.Put('DB Block Buffer Cache Hit Ratio  : ' || Format(v_value));
  IF v_value < 89 THEN
    DBMS_Output.Put_Line('Increase DB_BLOCK_BUFFERS parameter to bring value above 89%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;
  
  -- ---------------
  -- Latch Hit Ratio
  -- ---------------
  SELECT (1 - (Sum(misses) / Sum(gets))) * 100
  INTO   v_value
  FROM   v\$latch;

  DBMS_Output.Put('Latch Hit Ratio                  : ' || Format(v_value));
  IF v_value < 98 THEN
    DBMS_Output.Put_Line('Increase number of latches to bring the value above 98%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;

  -- -----------------------
  -- Disk Sort Ratio
  -- -----------------------
  SELECT (disk.value/mem.value) * 100
  INTO   v_value
  FROM   v\$sysstat disk,
         v\$sysstat mem
  WHERE  disk.name = 'sorts (disk)'
  AND    mem.name  = 'sorts (memory)';

  DBMS_Output.Put('Disk Sort Ratio                  : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase SORT_AREA_SIZE parameter to bring value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value Acceptable.');  
  END IF;
  
  -- ----------------------
  -- Rollback Segment Waits
  -- ----------------------
  SELECT (Sum(waits) / Sum(gets)) * 100
  INTO   v_value
  FROM   v\$rollstat;

  DBMS_Output.Put('Rollback Segment Waits           : ' || Format(v_value));
  IF v_value > 5 THEN
    DBMS_Output.Put_Line('Increase number of Rollback Segments to bring the value below 5%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;

  -- -------------------
  -- Dispatcher Workload
  -- -------------------
  SELECT NVL((Sum(busy) / (Sum(busy) + Sum(idle))) * 100,0)
  INTO   v_value
  FROM   v\$dispatcher;

  DBMS_Output.Put('Dispatcher Workload              : ' || Format(v_value));
  IF v_value > 50 THEN
    DBMS_Output.Put_Line('Increase MTS_DISPATCHERS to bring the value below 50%');
  ELSE
    DBMS_Output.Put_Line('Value acceptable.');
  END IF;
  
END;
/
pro

EOF

cat <<EOF>$ANL_HOME/sql/parameter.sql


pro
select UPPER(instance_name) Instance from v\$instance;
pro
set lines 200 pages 200
select * from v\$resource_limit;
pro
set pages 200 lines 200
col name for a40
col value for a30

pro </textarea>
pro <br/><br/>
pro <textarea rows="15" cols="150" style="font:'Courier New', Courier, monospace">

SELECT name, VALUE FROM v\$parameter WHERE lower(NAME) in ('sga_max_size','sga_target','pga_aggregate_target','undo_management','undo_retention','undo_tablespace','audit_trail','db_file_multiblock_read_count','cursor_sharing','compatible','use_large_pages','java_pool_size','large_pool_size','olap_page_pool_size','shared_pool_reserved_size','shared_pool_size','shared_pool_size','streams_pool_size');

pro        



EOF





cat <<EOF>$ANL_HOME/sql/sizedb.sql


set feedback off
set feed off
select UPPER(instance_name) Instance from v\$instance;
pro

col TMDB for 999,999,999 heading 'TAMANHO DB EM MB'
select sum(bytes)/1024/1024 TMDB from dba_segments;

EOF

cat <<EOF>$ANL_HOME/sql/lstbs.sql

set feedback off
set feed off
select UPPER(instance_name) Instance from v\$instance;

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


cat <<EOF>$ANL_HOME/sql/lsdg.sql

set feedback off

select UPPER(instance_name) Instance from v\$instance;
pro
set feed off


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











cat <<EOF>$ANL_HOME/sql/lsdf.sql

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

pro </textarea>
pro <br/><br/>
pro <a name="db7"><font face="Verdana, Geneva, sans-serif"><b>Tamanho dos Datafiles</b></font></a>
pro <br/>
pro <textarea rows="8" cols="150" style="font:'Courier New', Courier, monospace">

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


EOF


cat <<EOF>$ANL_HOME/sql/jbsize_owner_all.sql

pro </textarea>
pro <br/><br/>
pro <a name="db8"><font face="Verdana, Geneva, sans-serif"><b>Tamanho dos Schemas</b></font></a>
pro <br/>
pro <textarea rows="16" cols="150" style="font:'Courier New', Courier, monospace">
pro
pro TAMANHOS DOS SCHEMAS 
pro ---------------------

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
  dbms_output.put_line(chr(10)||'NOME DA INSTANCIA:......................... ' || upper(v_instance));
  
  for x in (SELECT OWNER, SUM(BYTES) sum FROM DBA_SEGMENTS WHERE
    OWNER NOT IN ('SYS','SYSTEM','OUTLN','SCOTT','ADAMS','JONES','CLARK','BLAKE','HR','OE','SH','DEMO','ANONYMOUS','AURORA$ORB$UNAUTHENTICATED','AWR_STAGE','CSMIG','CTXSYS','DBSNMP','DIP','DMSYS','DSSYS','EXFSYS','LBACSYS','MDSYS','ORACLE_OCM','ORDPLUGINS','ORDSYS','PERFSTAT','TRACESVR','TSMSYS','XDB','SYSMAN','WKSYS','WKPROXY','OLAPSYS','OWBSYS','MGMT_VIEW','SI_INFORMTN_SCHEMA','WMSYS')
    GROUP BY OWNER) loop

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
#-- Data de atualização : 29/08/2014
#-- ---------------------------------------------------------------------------------------------------------#

set lines 200
set serveroutput on
set echo off

declare 

JBQB VARCHAR2(2) := CHR(13) || CHR(10);
vinstance varchar2(15);
vdatabase varchar2(15);
vvalid numeric(10);
vretorn varchar2(3):='y';

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin

select upper(instance_name) into vinstance from v\$instance;
select upper(name) into vdatabase from v\$database;

for x in (
  SELECT s.sid, s.serial# serial, s.last_call_et, s.status, s.username, s.osuser, p.spid, s.program, s.event, s.state, s.sql_hash_value, s.inst_id, s.machine
  FROM gv\$process p, gv\$session s
  WHERE p.addr = s.paddr and s.sql_hash_value != 0  and s.username is not null /*and s.status = 'ACTIVE'*/ and audsid != userenv('SESSIONID') and s.last_call_et>43200
  ORDER BY s.last_call_et asc
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
  dbms_output.put_line('SERVIDOR:........................ ' || x.machine || JBQB);
  dbms_output.put_line('INFORMACOES DA ESPERA');
  dbms_output.put_line('SESSAO ESTA ESPERANDO EVENTO:.... ' || x.event);
  dbms_output.put_line('ESTADO DE ESPERA:................ ' || x.state || JBQB);
  if x.sql_hash_value <> 0 then
    dbms_output.put_line('SQL HASH VALUE:.................. ' || x.sql_hash_value);
    dbms_output.put_line('QUERY TEXT:...................... select sql_text from v\$sql where HASH_VALUE=' || x.sql_hash_value || ';');

      if vretorn='Y' or vretorn='y' then
        for query_loop in (select sql_text from v\$sql where HASH_VALUE=x.sql_hash_value)loop
          dbms_output.put_line(chr(10)||'     '||query_loop.sql_text||chr(10));
        end loop;
      end if;

    dbms_output.put_line('=============================================================================================='||JBQB);
  end if;

end loop;

SELECT nvl(count(sid),0) into vvalid FROM gv\$process p, gv\$session s
WHERE p.addr =  s.paddr and s.sql_hash_value is not null and s.sql_hash_value <> 0  and s.username is not null and audsid != userenv('SESSIONID') and s.last_call_et>43200;

if vvalid = 0 then
  dbms_output.put_line('NESTE MOMENTO NAO HA USUARIOS EXECUTANDO PROCESSOS NO BANCO DE DADOS COM MAIS DE 10 HORAS.');
end if;


end;
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
-- Descrição           : Identificar lock e seus detalhes.
-- Nome do arquivo     : jblock.sql
-- Data de criação     : 01/07/2014
-- Data de atualização : 04/05/2015
-- -----------------------------------------------------------------------------------

set serveroutput on
set lines 500 
Set pages 200
set long 999
set feedback off

declare

v_query_max_lock varchar2(20);
vloop_lock_qtd varchar2(20);
vvalid numeric(3);
JBQB VARCHAR2(2) := CHR(13) || CHR(10);

vtmps varchar2(90):=0;
vtmpm varchar2(90):=0;
vtmph varchar2(90):=0;
vtmpd varchar2(90):=0;

begin


for ljb in (
  select l1.sid,max(l2.ctime) ctime,l1.id1,l1.id2
  from v\$lock l1, v\$lock l2 
  where l1.block>0 and l2.block=0 and l1.id1=l2.id1 and l1.id2=l2.id2 
  group by l1.sid,l1.id1,l1.id2
  order by 2 asc
) loop

for x in (
  select sid,prev_hash_value,sql_hash_value,username,status,osuser,machine,serial#
  from v\$session where sid=ljb.sid
) loop

  dbms_output.put_line('+++++++++++++++++++++++++ BLOQUEADOR +++++++++++++++++++++++++++++++ ');
  dbms_output.put_line('DATABASE INFORMATION:');
  dbms_output.put_line('SID:......................... ' || x.sid);
  dbms_output.put_line('SERIAL#:..................... ' || x.serial#);
  dbms_output.put_line('DATABASE USER:............... ' || x.username);
  dbms_output.put_line('STATUS:...................... ' || x.status);
  
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

  dbms_output.put_line('S.O INFORMATION:');
    
    for xy in (
        select nvl(spid,0) spid from v\$process p, v\$session s 
        where p.addr = s.paddr and s.sid = x.sid
    ) loop
      if xy.spid <> 0 then
      dbms_output.put_line('PID:......................... ' || xy.spid);
    end if;
  end loop;
  
  dbms_output.put_line('S/O USER:.................... ' || x.osuser);
  dbms_output.put_line('MACHINE:..................... ' || x.machine || JBQB);
  dbms_output.put_line('KILL SESSION:');
  dbms_output.put_line('alter system kill session '''||x.sid||','||x.serial#||''' immediate;' || JBQB);
  
  dbms_output.put_line('LOCK INFORMATION:');
  if x.sql_hash_value <> 0 then
  dbms_output.put_line('HASH VALUE ATUAL:............ ' || x.sql_hash_value);
  dbms_output.put_line('QUERY TEXT:.................. select sql_text from v\$sql where HASH_VALUE=' || x.sql_hash_value || ';' || JBQB);
  else
  dbms_output.put_line('ULTIMO HASH VALUE:........... ' || x.prev_hash_value);
  dbms_output.put_line('QUERY TEXT:.................. select sql_text from v\$sql where HASH_VALUE=' || x.prev_hash_value || ';' || JBQB);
  end if;
    
-- Mostra o tipo do objeto e a quantidade em lock

  for tab_z in 
  ( 
    SELECT distinct O.OBJECT_TYPE FROM v\$locked_object l, DBA_OBJECTS O, v\$session s
    where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid 
  ) loop
    vloop_lock_qtd:=0;
    
    for tab_y in 
    ( 
      SELECT O.OBJECT_TYPE FROM v\$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid 
    ) loop
      if tab_y.OBJECT_TYPE = tab_z.OBJECT_TYPE then vloop_lock_qtd:= vloop_lock_qtd + 1; end if;
    end loop;
    dbms_output.put_line('QTD DE OBJETOS EM LOCK:...... ' || vloop_lock_qtd || ' ' || tab_z.OBJECT_TYPE || JBQB);
  
  end loop;
  
  for tab_z in 
  ( 
    SELECT distinct O.OBJECT_TYPE FROM v\$locked_object l, DBA_OBJECTS O where L.OBJECT_ID = O.OBJECT_ID AND L.SESSION_ID = x.sid 
  ) loop
    dbms_output.put_line(tab_z.OBJECT_TYPE || '(s) EM LOCK:::::::::::::' );
    
    for tab_x in 
    ( 
      SELECT O.OBJECT_NAME,O.OWNER FROM v\$locked_object l, DBA_OBJECTS O 
      WHERE L.OBJECT_ID = O.OBJECT_ID AND  O.OBJECT_TYPE=tab_z.OBJECT_TYPE AND L.SESSION_ID = x.sid 
    ) loop
      dbms_output.put_line(tab_x.OWNER || '.' || tab_x.OBJECT_NAME );
    end loop;
  end loop;
  dbms_output.put_line(JBQB || '+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  ');



  dbms_output.put_line('============================ BLOQUEADO ====================== ');   
  for v_block in (
    select s.sid,s.serial#,s.sql_hash_value from v\$session s, v\$lock l
    where s.sid=l.sid and request>0 and l.id1=ljb.id1 and l.id2=ljb.id2
  ) loop  

    dbms_output.put_line('.... SID:......................... ' || v_block.sid || ' | SERIAL#:... ' || v_block.serial#);
    dbms_output.put_line('.... QUERY TEXT:.................. select sql_text from v\$sql where HASH_VALUE=' || v_block.sql_hash_value || ';');
    dbms_output.put_line(JBQB);
  end loop;
  
end loop;

end loop;


select count(1) into vvalid
from v\$lock l1, v\$lock l2 
where l1.block>0 and l1.id1=l2.id1 and l1.id2=l2.id2 order by l2.ctime asc;

if vvalid = 0 then
  dbms_output.put_line(chr(10)||'- ------------------------------------------ -');
  dbms_output.put_line('- NAO EXISTE LOCKS DE USUARIOS NESTE MOMENTO -');
  dbms_output.put_line('- ------------------------------------------ -'||chr(10));
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
show parameter optimizer_index_
pro


SET SERVEROUTPUT ON
set lines 2000

declare 
  c1 varchar2(90);
  c2 varchar2(90);
  c3 varchar2(90);
  c4 varchar2(90);
  c5 varchar2(90);
BEGIN

select
  a.average_wait, b.average_wait, a.total_waits /(a.total_waits + b.total_waits), 
  b.total_waits /(a.total_waits + b.total_waits), (b.average_wait / a.average_wait)*100 
into
  c1, c2, c3, c4, c5
from v\$system_event a, v\$system_event b
where a.event = 'db file scattered read' and b.event = 'db file sequential read';

dbms_output.put_line(chr(10)||chr(10)||'MEDIA WAITS PARA FULL SCAN READ I/O:.........' || to_char(c1,'99.99'));
dbms_output.put_line('MEDIA WAITS PARA INDEX READ I/O:.............' || to_char(c2,'99.99'));
dbms_output.put_line('PORCENTAGEM DE I/O WAITS PARA FULL SCANS:....' || to_char(c3,'99.99'));
dbms_output.put_line('PORCENTAGEM DE I/O WAITS PARA INDEX SCANS:...' || to_char(c4,'99.99'));
dbms_output.put_line('VALOR INICIAL PARA OPTIMIZER INDEX COST ADJ >>>>>>>>>>>>> ' || to_char(C5,'9999'));

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END;
/

pro </textarea>
pro <br/><br/>
pro <a name="db13"><font face="Verdana, Geneva, sans-serif"><b>COLETA DE ESTATISTICA</b></font></a>
pro <br/>
pro <textarea rows="16" cols="150" style="font:'Courier New', Courier, monospace">

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

pro memory1
@\$ANL_HOME/sql/memory.sql
pro
pro
pro memory2


pro parameter1
@\$ANL_HOME/sql/parameter.sql
pro
pro
pro parameter2


pro sizedb1
@\$ANL_HOME/sql/sizedb.sql
pro
pro
pro sizedb2

pro lstbs1
@\$ANL_HOME/sql/lstbs.sql
pro
pro
pro lstbs2

pro lsdg1
@\$ANL_HOME/sql/lsdg.sql
pro
pro
pro lsdg2


pro lsdf1
@\$ANL_HOME/sql/lsdf.sql
pro
pro
pro lsdf2



pro jbsize_owner_all1
@\$ANL_HOME/sql/jbsize_owner_all.sql
pro
pro
pro jbsize_owner_all2


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

if [ ! -d "\$ANL_HOME/log/$ORACLE_SID" ];then mkdir -p \$ANL_HOME/log/$ORACLE_SID; export LOG_DIR=\$ANL_HOME/log/$ORACLE_SID; fi


sh \$ANL_HOME/sh/alert.sh >>\$LOG_DIR/alert.log

sh \$ANL_HOME/sh/jbfilt.sh jbdb_ins >> \$LOG_DIR/jbdb_ins.log
sh \$ANL_HOME/sh/jbfilt.sh parameter >> \$LOG_DIR/parameter.log
sh \$ANL_HOME/sh/jbfilt.sh memory >> \$LOG_DIR/memory.log



sh \$ANL_HOME/sh/jbfilt.sh sizedb >> \$LOG_DIR/sizedb.log
sh \$ANL_HOME/sh/jbfilt.sh lstbs >> \$LOG_DIR/lstbs.log
sh \$ANL_HOME/sh/jbfilt.sh lsdg >> \$LOG_DIR/lsdg.log
sh \$ANL_HOME/sh/jbfilt.sh lsdf >> \$LOG_DIR/lsdf.log
sh \$ANL_HOME/sh/jbfilt.sh jbsize_owner_all >> \$LOG_DIR/jbsize_owner_all.log



sh \$ANL_HOME/sh/jbfilt.sh jblast_query >> \$LOG_DIR/jblast_query.log
sh \$ANL_HOME/sh/jbfilt.sh jblock >> \$LOG_DIR/jblock.log
sh \$ANL_HOME/sh/jbfilt.sh jbusing_table >> \$LOG_DIR/jbusing_table.log
sh \$ANL_HOME/sh/jbfilt.sh CBO >> \$LOG_DIR/CBO.log
sh \$ANL_HOME/sh/jbfilt.sh compile >> \$LOG_DIR/compile.log
sh \$ANL_HOME/sh/jbfilt.sh spfile >> \$LOG_DIR/spfile.log
sh \$ANL_HOME/sh/jbfilt.sh perf_log_switch_history_daily_all >> \$LOG_DIR/perf_log_switch_history_daily_all.log

CONT_BKP=\$(sh \$ANL_HOME/sh/jbfilt.sh jbrman_status )
if [ ! -z "\$CONT_BKP" ]; then
  sh \$ANL_HOME/sh/jbfilt.sh jbrman_status >> \$LOG_DIR/jbrman_status.log
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

:wq!









sh /tmp/conf_jbanalisys.sh
