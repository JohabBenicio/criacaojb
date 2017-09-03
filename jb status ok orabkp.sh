


ls $ODS_HOME/bulletin/P*.archi* | while read file
do

FL=$(ls -l $file)
FLD=$(echo $FL | cut -d ' ' -f 5)
cat <<EOF


AÇÕES EXECUTADAS (resumo)
========================
1) - Analise do bulletin.

DADOS COLETADOS
================
Log analisado:${FL#*$FLD}

$(cat $file)


Com base nos dados coletados, podemos afirmar que seu ultimo backup foi concluído com sucesso.
Estamos encaminando este chamado para o encerramento.


Att,
Johab Benicio.
DBA Oracle.



EOF

done


