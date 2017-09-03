HORARIO DE VERAO

T&C
====

zdump -v /etc/localtime | grep $(date +"%Y")


/etc/localtime  Sun Feb 22 01:59:59 2015 UTC = Sat Feb 21 23:59:59 2015 BRST isdst=1 gmtoff=-7200
/etc/localtime  Sun Feb 22 02:00:00 2015 UTC = Sat Feb 21 23:00:00 2015 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 18 02:59:59 2015 UTC = Sat Oct 17 23:59:59 2015 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 18 03:00:00 2015 UTC = Sun Oct 18 01:00:00 2015 BRST isdst=1 gmtoff=-7200

[root@srvora01 [] ~]# date
Sat Feb 21 21:37:40 BRST 2015




########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################



crontab -l >> ~/crontab_`date +"%d%m%y_%H%M"`.bkp

mkdir ~/teor

ls -l ~/teor/shutdown_instances.log ~/teor/instances.log

rm -f ~/teor/shutdown_instances.log ~/teor/instances.log

ps -ef | grep _smon_ | grep -v opuser | grep -v -i "asm" | grep -v 'grep' | sed 's/.*_smon_\(.*\)$/\1/' | grep -v ")" | while read instance
do
export ORACLE_SID=$instance

echo $ORACLE_SID>>~/teor/instances.log
echo $(date) >> ~/teor/shutdown_instances.log
sqlplus -S /nolog <<EOF>>~/teor/shutdown_instances.log
	conn / as sysdba
	create pfile='/tmp/init$instance.ora' from spfile;

	set feedback off;
	set lines 500;
	col STATUS for a15
	col "OPEN MODE" for a11
	col VERSAO for a58
	col "MODO ARCHIVE" for a15
	--select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') "Data e Hora" from dual;
	SELECT INS.INSTANCE_NAME INSTANCIA,
	INS.PARALLEL RAC,
	INS.STATUS,
	DAT.NAME DATABASE,
	DAT.OPEN_MODE "OPEN MODE",
	DAT.LOG_MODE "MODO ARCHIVE",
	VER.BANNER VERSAO
	FROM V\$INSTANCE INS, V\$DATABASE DAT, V\$VERSION VER
	WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';

	shutdown immediate;
	pro
	quit
EOF

clear

cat ~/teor/shutdown_instances.log

done






ls -l ~/teor/startup_instances.log

rm -f ~/teor/startup_instances.log

cat ~/teor/instances.log | while read instance
do
export ORACLE_SID=$instance
echo $(date) >> ~/teor/startup_instances.log
sqlplus -S /nolog <<EOF>>~/teor/startup_instances.log
	conn / as sysdba

	startup

	set feedback off;
	set lines 500;
	col STATUS for a15
	col "OPEN MODE" for a11
	col VERSAO for a58
	col "MODO ARCHIVE" for a15
	--select to_char(sysdate,'dd/mm/yyyy hh24:mi:ss') "Data e Hora" from dual;
	SELECT INS.INSTANCE_NAME INSTANCIA,
	INS.PARALLEL RAC,
	INS.STATUS,
	DAT.NAME DATABASE,
	DAT.OPEN_MODE "OPEN MODE",
	DAT.LOG_MODE "MODO ARCHIVE",
	VER.BANNER VERSAO
	FROM V\$INSTANCE INS, V\$DATABASE DAT, V\$VERSION VER
	WHERE BANNER LIKE '%Oracle Database%' or BANNER LIKE '%Oracle9i%';

	quit
	pro
EOF

clear

cat ~/teor/startup_instances.log
done



ls -l ~/teor/shutdown_instances.log

ls -l ~/teor/startup_instances.log









########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################























########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################



SCRIPT_SHUT_RAC=/tmp/shut_instances.sh
LOG_INSTANCE=/tmp/instances.log
rm -f $LOG_INSTANCE
ps -ef | grep ora_smon_ | grep -v opuser | grep -v -i "asm" | grep -v 'grep' | sed 's/.*ora_smon_\(.*\)$/\1/' | grep -v ")" | while read instances
do
echo $instances>>$LOG_INSTANCE
export ORACLE_SID=$instances
sqlplus -S / as sysdba <<EOF>>$LOG_INSTANCE
show parameter db_name
create pfile='/tmp/init$instances.ora' from spfile;
quit;
EOF
done
echo "# $(date)" >$SCRIPT_SHUT_RAC
cat $LOG_INSTANCE | grep db_name | awk '{print $NF}' | while read banco
do
cat <<EOF>>$SCRIPT_SHUT_RAC
srvctl status database -d $banco >> $SCRIPT_SHUT_RAC.log
srvctl stop database -d $banco -o immediate  >> $SCRIPT_SHUT_RAC.log
srvctl status database -d $banco  >> $SCRIPT_SHUT_RAC.log

EOF
done







SCRIPT_START_RAC=/tmp/startup_instances_ok.sh
LOG_INSTANCE=/tmp/instances.log

rm -f $SCRIPT_START_RAC
cat $LOG_INSTANCE | grep db_name | awk '{print $NF}' | while read banco
do

cat <<EOF>>$SCRIPT_START_RAC
# $(date)

srvctl status database -d $banco
srvctl start database -d $banco
srvctl status database -d $banco

EOF
done


*.sga_max_size=17179869184
*.sga_target=  17.179.869.184
4.398.046.511.104


8.589.934.592

cat /tmp/instances.log | grep db_unique_name | awk '{print "srvctl status database -d " $NF}'





########################################################################################################################
########################################################################################################################
########################################################################################################################
########################################################################################################################




















AÇÕES EXECUTADAS (resumo)
========================
1) - Acompanhamento da saída do horário de verão.

Prezado Cliente, boa noite.

A saída do horario de verão foi atualizada com sucesso.

DADOS COLETADOS
================
[oracle@srvora01-vnt [sgap1] ~]$ date; ssh srvora02-vnt date
Sun Feb 21 00:12:11 BRT 2016
Sun Feb 21 00:12:11 BRT 2016


Att,
Johab Benicio
DBA Oracle.








AÇÕES EXECUTADAS (resumo)
========================
1) - Banco de dados baixado;
2) - Acompanhamento da saída do horário de verão;
3) - Startup do banco de dados.


Prezado Cliente, boa noite.

O processo de saída do horário de verão foi executado com sucesso.

DADOS COLETADOS
================
[oracle@hiperionnew [jundiaiweb] ~]$ date; ps -ef | grep smon
Sun Feb 21 00:46:22 BRT 2016
oracle    3296     1  0 Feb20 ?        00:00:00 ora_smon_jundiaiweb
oracle    3399     1  0 Feb20 ?        00:00:00 ora_smon_portalgmf
oracle    6314     1  0  2015 ?        00:00:00 asm_smon_+ASM

[oracle@srvdb01 ~]$ date; ps -ef | grep smon
Sun Feb 21 00:49:20 BRT 2016
oracle    3816     1  0  2015 ?        00:10:08 asm_smon_+ASM
oracle   20063 33899  0 00:49 pts/1    00:00:00 grep smon
oracle   51661     1  0 Feb20 ?        00:00:01 ora_smon_sinha

[oracle@promedeu [dae] ~]$ date; ps -ef | grep smon
Sun Feb 21 00:48:33 BRT 2016
oracle   24630     1  0 Feb20 ?        00:00:00 ora_smon_dae
oracle   24732     1  0 Feb20 ?        00:00:00 ora_smon_daehm

[oracle@titania [filaprod] ~]$ date; ps -ef | grep smon
Sun Feb 21 00:48:33 BRT 2016
oracle   19060     1  0 Feb20 ?        00:00:00 ora_smon_filaprod
oracle   24546 16543  0 00:48 pts/1    00:00:00 grep smon

[oracle@ganimedep [CIGAM] ~]$ date; ps -ef | grep smon
Sun Feb 21 00:48:33 BRT 2016
oracle    2446     1  0 Feb20 ?        00:00:00 ora_smon_CIGAM
oracle    3665  1448  0 00:48 pts/2    00:00:00 grep smon
oracle    6293     1  0  2015 ?        00:00:00 asm_smon_+ASM




Att,
Johab Benicio.
DBA Oracle.




















date mesdiahoraminuto

date 02212305


date 03061816







Demanda Programada
====================
1) - Escopo Técnico.
- Ajustar horário no servidor "dbserver".

2) - Atividades previstas.
- Conectar no servidor;
- Baixar instancias "CM" e "CMT";
- Ajustar hora no servidor;
- Aguarda 40 minutos;
- Subir instancias "CM" e "CMT".

3) - Tempo estimado.
- 1h (uma hora).

4) - Pré-requisitos.
- Ter acesso ao servidor com usuário root.


Att,
Johab Benício










AÇÕES EXECUTADAS (resumo)
====================
- Analise do ambiente;
- Configuração do ZIC;
- Realização do ajuste do horário do servidor;
- Shutdown das instancias "CM" e "CMT";
- Startup das instancias após uma janela de 40 minutos.


DADOS COLETADOS
==============

- ZIC Antes do atendimento
zdump -v /etc/localtime | grep 201
/etc/localtime  Sun Feb 21 01:59:59 2010 UTC = Sat Feb 20 23:59:59 2010 BRST isdst=1 gmtoff=-7200
/etc/localtime  Sun Feb 21 02:00:00 2010 UTC = Sat Feb 20 23:00:00 2010 BRT isdst=0 gmtoff=-10800


- ZIC Depois do atendimento
zdump -v /etc/localtime | grep 201
/etc/localtime  Sun Feb 22 01:59:59 2015 UTC = Sat Feb 21 23:59:59 2015 BRST isdst=1 gmtoff=-7200
/etc/localtime  Sun Feb 22 02:00:00 2015 UTC = Sat Feb 21 23:00:00 2015 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 18 02:59:59 2015 UTC = Sat Oct 17 23:59:59 2015 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 18 03:00:00 2015 UTC = Sun Oct 18 01:00:00 2015 BRST isdst=1 gmtoff=-7200
(...)
/etc/localtime  Sun Oct 20 02:59:59 2019 UTC = Sat Oct 19 23:59:59 2019 BRT isdst=0 gmtoff=-10800
/etc/localtime  Sun Oct 20 03:00:00 2019 UTC = Sun Oct 20 01:00:00 2019 BRST isdst=1 gmtoff=-7200


- Shutdown da instancia.

Mon Mar 9 03:34:26 BRT 2015

INSTANCIA        RAC STATUS          DATABASE  OPEN MODE   MODO ARCHIVE    VERSAO
---------------- --- --------------- --------- ----------- --------------- ----------------------------------------------------------
cm               NO  OPEN            CM        READ WRITE  ARCHIVELOG      Oracle Database 10g Release 10.2.0.3.0 - 64bit Production
Database closed.
Database dismounted.
ORACLE instance shut down.

Mon Mar 9 03:35:07 BRT 2015

INSTANCIA        RAC STATUS          DATABASE  OPEN MODE   MODO ARCHIVE    VERSAO
---------------- --- --------------- --------- ----------- --------------- ----------------------------------------------------------
cmt              NO  OPEN            CMT       READ WRITE  NOARCHIVELOG    Oracle Database 10g Release 10.2.0.3.0 - 64bit Production
Database closed.
Database dismounted.
ORACLE instance shut down.


- Startup da instancia

Mon Mar 9 03:35:39 BRT 2015
ORACLE instance started.

Total System Global Area 2147483648 bytes
Fixed Size                  2074048 bytes
Variable Size            1342179904 bytes
Database Buffers          754974720 bytes
Redo Buffers               48254976 bytes
Database mounted.
Database opened.

INSTANCIA        RAC STATUS          DATABASE  OPEN MODE   MODO ARCHIVE    VERSAO
---------------- --- --------------- --------- ----------- --------------- ----------------------------------------------------------
cm               NO  OPEN            CM        READ WRITE  ARCHIVELOG      Oracle Database 10g Release 10.2.0.3.0 - 64bit Production
Mon Mar 9 03:35:49 BRT 2015
ORACLE instance started.

Total System Global Area 2147483648 bytes
Fixed Size                  2074048 bytes
Variable Size             939526720 bytes
Database Buffers         1157627904 bytes
Redo Buffers               48254976 bytes
Database mounted.
Database opened.

INSTANCIA        RAC STATUS          DATABASE  OPEN MODE   MODO ARCHIVE    VERSAO
---------------- --- --------------- --------- ----------- --------------- ----------------------------------------------------------
cmt              NO  OPEN            CMT       READ WRITE  NOARCHIVELOG    Oracle Database 10g Release 10.2.0.3.0 - 64bit Production




Att,
Johab Benício.







date 03 15 13 45 2010