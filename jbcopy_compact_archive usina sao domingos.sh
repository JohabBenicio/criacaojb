#!/bin/bash
# Teor Tecnologia Orientada
# Rua Carneiro da Cunha, 167 - cj. 104
# (11) 3797-8299
# São Paulo - SP
#
# Criado em 01/04/2015
#
# Efetua a copia dos archives e compacta o mesmo.
# Mantem  uma retencao de 180 dias
#
# Inicio
#
BASH=~/.bash_profile

if [ -e "$BASH" ]; then
  . $BASH
else
  BASH=~/.profile
  . $BASH
fi

ORIGEM=/u02/oraarch/prod/*.arc
DESTINO=/u02/backup/prod/arc_compactados
CP_HOME=/u01/app/oracle/admin/prodb/scripts/copy_arc
CP_LOG=$CP_HOME/log/copy_archive.log
CP_ERR=$CP_HOME/log/copy_archive_error.log
RM_LOG=$CP_HOME/log/delete_compactados.log
LOCK=$CP_HOME/lock/lock_process.loc

if [ -e "$LOCK" ]; then
PROC=$(ps -ef | grep "$(cat $LOCK)" | grep -v grep | wc -l)
if [ "$PROC" -gt "0" ]; then
echo -e "\nProcesso ja esta em execucao! \n">> $CP_LOG
exit
else
echo "$$">$LOCK
fi
else
echo "$$">$LOCK
fi

find $ORIGEM -perm 640 -mmin +1 | while read ARC_NAME
do
  cp $ARC_NAME $DESTINO

  if [ "$?" -eq "0" ]; then
        chmod 644 $ARC_NAME
        echo -e "\n Copia do archive $ARC_NAME efetuado com sucesso `date`" >> $CP_LOG
  else
        echo "Erro durante a copia do archive $ARC_NAME `date`" >> $CP_ERR
  fi
done

LIST_BACKUP=$(ls $DESTINO/*.arc | wc -l)


if [ "$LIST_BACKUP" -gt "101" ]; then
   FIRST_COMP=$(ls -1 $DESTINO/*.arc | head -1 |cut -d _ -f 3 | cut -d . -f 1 | sed 's/^0*//')
   LAST_COMP=$(ls -1 $DESTINO/*.arc | tail -1 |cut -d _ -f 3 | cut -d . -f 1 | sed 's/^0*//')
   tar -cvzf $DESTINO/arch_$FIRST_COMP\_$LAST_COMP.tar.gz $DESTINO/*.arc

   if [ "$?" -eq "0" ]; then
        rm -f $DESTINO/*.arc
   fi

fi

find $DESTINO/*.tar.* -mtime +150 | while read compactados
do
   echo -n "`ll $compactados` apagado em `date`, " >> $RM_LOG
   rm -f $compactados
   if [ "$?" -eq "0" ]; then
        echo " OK"  >> $RM_LOG
   else
        echo " ERROR"  >> $RM_LOG
   fi
done

