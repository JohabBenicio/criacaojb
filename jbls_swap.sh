#-- -----------------------------------------------------------------------------------
#-- Autor               : Johab Benicio de Oliveira.
#-- Descrição           : Analise de consumo de Swap
#-- Nome do arquivo     : jbls_swap.sql
#-- Data de criação     : 01/07/2014
#-- -----------------------------------------------------------------------------------

export JBSWPERUS=$(free -m | grep wap | awk  '{ print "Total de Swap Usado: " ($3 * 100) / $2 "%"}');
export JBSWUSGB=$(free -m | grep wap | awk  '{ print "Swap Usado: " $3/1024 " GB"}');
export JBSWUSMB=$(free -m | grep wap | awk  '{ print "Swap Usado: " $3 " MB" }');

export JBSWPERFR=$(free -m | grep wap | awk  '{ print "Total de Swap Livre: " ($4 * 100) / $2 "%"}');
export JBSWFRGB=$(free -m | grep wap | awk  '{ print "Swap Livre: " $4/1024 " GB"}');
export JBSWFRMB=$(free -m | grep wap | awk  '{ print "Swap Livre: " $4 " MB" }');

echo -e '\n';echo $JBSWPERUS;echo $JBSWUSGB;echo $JBSWUSMB;echo '';echo $JBSWPERFR;echo $JBSWFRGB;echo $JBSWFRMB; echo -e '\n'; 

