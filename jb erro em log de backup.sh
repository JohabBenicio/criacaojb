PECA=arch
VTEM=1

find  *$PECA*.log -mtime -$VTEM | while read arch
do
VALID=$(cat $arch | grep "ORA-\|RMAN-" | grep -v "grep\|WARNING" | wc -l)
if [ "$VALID" -gt "0" ]; then
ls -lthr $arch
fi
done





VTEM=3
find -name "*.log" -mtime -$VTEM | while read log
do
VALID=$(cat $log | grep "ORA-\|RMAN-" | grep -v grep | wc -l)
if [ "$VALID" -gt "0" ]; then
ls -lthr $log
fi;
done

prodcl2

piece handle=/backup/prodlm/fisico/ARCH_PRODLM_272103_1_01_09_2016_921426019 tag=TAG20160901T154019 comment=NONE
channel c1: backup set complete, elapsed time: 00:00:02
Finished backup at 01/09/2016 15:40

Starting Control File and SPFILE Autobackup at 01/09/2016 15:40
released channel: c1
RMAN-00571: ===========================================================
RMAN-00569: =============== ERROR MESSAGE STACK FOLLOWS ===============
RMAN-00571: ===========================================================
RMAN-03009: failure of Control File and SPFILE Autobackup command on c1 channel at 09/01/2016 15:40:24
ORA-00245: control file backup failed; target is likely on a local file system

Recovery Manager complete.


CONFIGURE SNAPSHOT CONTROLFILE NAME TO '+DGDATA/prodlm/snapcf_prodlm2.f';







A abertura deste incidente ocorreu devido as atividades realizadas no chamado "47188 - Horario de verão".
Estamos encaminhando este chamado para o encerramento.

Atenciosamente,
Johab Benício de Oliveira.










AÇÕES EXECUTADAS (resumo)
=========================
1) - Analise de logs;
* Não detectamos nenhum erro nos logs de backup.

Obs.: Com base nos dados do log, seu backup foi concluido com sucesso.
Estamos encaminhando este chamado para o encerramento.

DADOS COLETADOS
===============
-rw-r--r-- 1 oracle oinstall 143477 Feb 21 02:13 /backup/dw/logico/expdp_full_dw1_0_210216.log

Master table "SYS"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
******************************************************************************
Dump file set for SYS.SYS_EXPORT_FULL_01 is:
  /backup/dw/logico/expdp_full_dw1_0_210216_01.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_02.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_03.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_04.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_05.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_06.dmp
Job "SYS"."SYS_EXPORT_FULL_01" successfully completed at Sun Feb 21 02:13:13 2016 elapsed 0 00:08:10


Att,
Johab Benicio
DBA Oracle.





AÇÕES EXECUTADAS (resumo)
========================
1) - Analise de logs.

CAUSA
======
A abertura deste incidente ocorreu devido as atividades realizadas no chamado "47188 - Horario de verão".
Estamos encaminhando este chamado para o encerramento.

DADOS COLETADOS
================
1) - Ultimo log de backup.

Master table "SYS"."SYS_EXPORT_FULL_01" successfully loaded/unloaded
******************************************************************************
Dump file set for SYS.SYS_EXPORT_FULL_01 is:
  /backup/dw/logico/expdp_full_dw1_0_210216_01.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_02.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_03.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_04.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_05.dmp
  /backup/dw/logico/expdp_full_dw1_0_210216_06.dmp
Job "SYS"."SYS_EXPORT_FULL_01" successfully completed at Sun Feb 21 02:13:13 2016 elapsed 0 00:08:10


Att,
Johab Benicio.
DBA Oracle.

