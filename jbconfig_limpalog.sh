
rm -f /tmp/limplog.sh

vi /tmp/limplog.sh
i

read -p "Insira o BACKUP_HOME: " BKP_HOME

export BACKUP_HOME=$BKP_HOME

cat <<EOF> $BACKUP_HOME/sh/limpa_logs.sh

#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8277
# São Paulo - SP
#
# Criado em 08/05/2013
#
# Realiza a limpeza dos logs.
#
# Versao para Linux
# \$1 ORACLE_SID

#
# Inicio
#

export BACKUP_HOME=$BACKUP_HOME

find \$BACKUP_HOME/log/*.log -mtime +7 -print | while read arquivo
do
   rm -f \$arquivo
done


EOF


chmod 755 $BACKUP_HOME/sh/limpa_logs.sh


echo -e "\n\n  00     01    *        *      *       $BACKUP_HOME/sh/limpa_logs.sh $instance 1>/dev/null 2>/dev/null\n\n"



:wq!

chmod 755 /tmp/limplog.sh



