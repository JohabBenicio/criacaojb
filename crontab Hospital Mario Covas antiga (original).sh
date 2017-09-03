#
# Ambiente do crontab
#
SHELL=/bin/bash
#
# Backup
#
#15 0 * * * ~/sis/bin/backupGeral.sh
#15 1 18 10 0 ~/sis/bin/backupGeral.sh
#
# Coleta estatisticas
#
##0 21 * * * ~/sis/bin/estatisticas.sh
#
# Remove arquivos de log antigos
#
#0 20 * * 6 ~/sis/bin/limpeza.sh
#
# Backup de outros arquivos
#
#0 15 * * 0 ~/sis/cst/backupOutros.sh
#
# Monitorador
#
0,15,30,45 * * * * ~/sis/bin/atualizaSISMON.sh
#
# Aplica archives no banco de dados standby
#
#15 * * * * ~/sis/bin/recoverStd.sh <<ORACLE_SID>>
#
# Envia archives para o banco de dados standby
#
#0,15,30,45 * * * * ~/sis/bin/copiaArchStd.sh <<ORACLE_SID>>
#0,10,20,30,40,50 * * * * ~/sis/bin/copiaArchStd.sh prdmv 1
#
# Gera relatorio com a situacao do standby
#
#0 9 * * * ~/sis/bin/statusStd.sh <<ORACLE_SID>>
#0 9 * * * ~/sis/bin/statusStd.sh prdmv
#
# Gera relatorio sobre o servidor e bancos de dados
#
#0 8 * * 1 ~/sis/bin/relatSISMON.sh
#
# Backup incremental (archives)
#
#0 * * * * ~/sis/bin/backupArchive.sh
#
# Fim
#


#############################################################################
# BACKUP FISICO PARA DISCO                                                  #
#############################################################################
# BANCO PRDMV
#05 00 * * *   /u01/backup/prdmv/fisico/sh/bkp_full.sh prdmv 1>/dev/null 2>/dev/null
#00 1-23 * * * /u01/backup/prdmv/fisico/sh/bkp_archive.sh prdmv 1>/dev/null 2>/dev/null
#30 03 * * *   /u01/backup/prdmv/fisico/sh/bkp_crosscheck.sh prdmv 1>/dev/null 2>/dev/null
#45 03 * * *   /u01/backup/prdmv/fisico/sh/limpa_logs.sh prdmv 1>/dev/null 2>/dev/null


#############################################################################
# Standby deleta Archives                                                   #
#############################################################################
# BANCO prdmv Standby
#00 23 * * * /bin/sh /u01/backup/prdmv/standby/limpaArch.sh 1>/dev/null 2>/dev/null


##############################################################
# Rotina de Envio de E-mail
##############################################################
#00 08 * * * /u01/backup/prdmv/standby/StdMail.sh 1>/dev/null 2>/dev/null
#00 17 * * * /u01/backup/prdmv/standby/StdMail.sh 1>/dev/null 2>/dev/null
