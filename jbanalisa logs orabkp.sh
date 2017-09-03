anual.job_duration=1h
semanal.job_frequency=8d

vi $DBN.conf

JOBN=semanal
DBN=grwebh
LOGJ=/tmp/check_backup_$DBN\_$JOBN.log
cat $ODS_HOME/config/$DBN.conf | grep $JOBN > $LOGJ
echo -e "\n\n" >> $LOGJ
cat $ODS_HOME/bulletin/$DBN.$JOBN >> $LOGJ
echo -e "\n\n" >> $LOGJ
ls -lthr $ODS_HOME/logs/$DBN*backup_$JOBN* | awk '{print $NF}' | while read files
do
DRYRUN=$(grep "DRY-RUN" $files | wc -l)
if [ "$DRYRUN" -eq "0" ]; then
ls -l $files >> $LOGJ
echo -e "\n" >> $LOGJ
tail -30 $files >> $LOGJ
echo -e "\n\n" >> $LOGJ
fi;
done
less $LOGJ




AÇÕES EXECUTADAS (resumo)
========================
1) - Atualização do orabkp.
* Versão 1.3.1 corrige a falha do calculo da próxima execução.

Estamos encaminhando este chamado para o encerramento.

Att,
Johab Benicio.
DBA Oracle.



