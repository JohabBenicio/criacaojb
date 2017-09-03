############### Criado por Johab Benicio de Oliveira #################

--PARA SUBIR O BANCO AUTOMATICO TEM QUE CRIAR UM SCRIPT
-- COMO ROOT NO DIRETORIO : cd /etc/init.d

vi oracle


-- ESCREVER NO /etc/init.d/oracle

vi /etc/init.d/oracle
i

#!/bin/sh
# chkconfig: 345 99 10
# description: Oracle auto start-stop script.
#
# Set ORA_HOME to be equivalent to the $ORACLE_HOME
# from which you wish to execute dbstart and dbshut;
#
# Set ORA_OWNER to the user id of the owner of the
# Oracle database in ORA_HOME.

ORA_OWNER=oracle
ORA_HOME=/u01/app/oracle/product/11.2.0.4
ORA_DIR=/u01/app/oracle/admin/scripts/dbstart


case "$1" in
    'start')
        # Start the Oracle databases:
        # The following command assumes that the oracle login
        # will not prompt the user for any values
        su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl start"

        while read DB_START
        do
            su - $ORA_OWNER -c "bash $ORA_DIR/$DB_START"
        done < <(ls -1 $ORA_BASE/admin/scripts/dbstart | grep "sta_" )

        ;;
    'stop')
        # Stop the Oracle databases:
        # The following command assumes that the oracle login
        # will not prompt the user for any values

        while read DB_STOP
        do
            su - $ORA_OWNER -c "bash $ORA_DIR/$DB_STOP"
        done < <(ls -1 $ORA_BASE/admin/scripts/dbstart | grep "sto_" )

        su - $ORA_OWNER -c "$ORA_HOME/bin/lsnrctl stop"
        ;;
esac


:wq!







#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################







-- DEPOIS DAR PREVILÉGIO 750 PARA O ARQUIVO CRIADO

chmod 750 /etc/init.d/oracle

-----------------------------------------------------------------------------

-- ASSOCIAR O SERVIÇO DO ORACLE COM OS NÍVEIS DE EXECUÇÃO ADEQUADO E CONFIGURÁ-LO PARA INICIAR AUTOMATICAMENTE USANDO O SEGUINTE COMANDO.

chkconfig --level 345 oracle on






#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################






SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sta_01_producao.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por iniciar o banco de dados (Em caso de ambiente standby).
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=producao
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4

export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sta_01_$ORACLE_SID.log

startup nomount
alter database mount standby database ;
quit

EOF



:wq!





SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sta_02_db41.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por iniciar o banco de dados (Em caso de ambiente standby).
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=db41
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sta_02_$ORACLE_SID.log

startup nomount
alter database mount standby database ;
quit

EOF

:wq!






SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sta_03_ora2.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por iniciar o banco de dados (Em caso de ambiente standby).
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=ora2
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.


## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sta_03_$ORACLE_SID.log

startup nomount
alter database mount standby database ;
quit

EOF

:wq!




SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sta_04_prod.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por iniciar o banco de dados (Em caso de ambiente standby).
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=prod
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sta_04_$ORACLE_SID.log

startup nomount
alter database mount standby database ;
quit

EOF

:wq!






SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sta_05_desenv.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por iniciar o banco de dados (Em caso de ambiente standby).
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=desenv
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sta_05_$ORACLE_SID.log
startup;
quit

EOF

:wq!




#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################








SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sto_01_producao.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por parar o banco de dados.
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=producao
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4

export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sto_01_$ORACLE_SID.log

shutdown immediate;
quit

EOF



:wq!





SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sto_02_db41.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por parar o banco de dados.
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=db41
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sto_02_$ORACLE_SID.log

shutdown immediate;
quit

EOF

:wq!






SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sto_03_ora2.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por parar o banco de dados.
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=ora2
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.


## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sto_03_$ORACLE_SID.log

shutdown immediate;
quit

EOF

:wq!




SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sto_04_prod.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por parar o banco de dados.
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=prod
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sto_04_$ORACLE_SID.log

shutdown immediate;
quit

EOF

:wq!






SCRIPT=/u01/app/oracle/admin/scripts/dbstart/sto_05_desenv.sh
rm -f $SCRIPT
vi $SCRIPT
i

#!/bin/bash
#
# Pro4Tuning
# Descricao: Script responsavel por parar o banco de dados.
#
# Histoico de manutencoes
# ---------------------------------------------------------------------
# It ---Data---  Consultor --      Descritivo -------------------------
# 1. 19/05/2017  Johab Benicio     Criacao
# ---------------------------------------------------------------------

export ORACLE_SID=desenv
ORACLE_BASE=/u01/app/oracle
ORACLE_HOME=$ORACLE_BASE/product/11.2.0.4
export PATH=$ORACLE_HOME/bin:$PATH:.

## Valida se a instancia ja foi iniciada.
VALID=$(ps -ef | grep "_pmon_$ORACLE_SID" | grep -v grep | wc -l)
if [ $VALID -gt 0 ]; then
echo "Instancia $ORACLE_SID ja foi iniciada."
exit
fi

sqlplus / as sysdba <<EOF>/tmp/sto_05_$ORACLE_SID.log
startup;
quit

EOF

:wq!















############################################################################################################################################
############################################################################################################################################
###   Para ASM com a versao Oracle 10G
############################################################################################################################################
############################################################################################################################################

-- E PARA SUBIR O ASM AUTOMATICO IR NO DIRETORIO "/etc"
-- EDITAR O ARQUIVO "inittab"


-- LINHA QUE FICA NO FINAL

h1:35:respawn:/etc/init.d/init.cssd run >/dev/null 2>&1 </dev/null

-- E MUDAR A LINHA QUE FICA NO FINAL PARA O SEGUINTE LUGAR DENTRO DO ARQUIVO

1:2345:respawn:/sbin/mingetty tty1
2:2345:respawn:/sbin/mingetty tty2
3:2345:respawn:/sbin/mingetty tty3
4:2345:respawn:/sbin/mingetty tty4
5:2345:respawn:/sbin/mingetty tty5
6:2345:respawn:/sbin/mingetty tty6

# Run xdm in runlevel 5
x:5:respawn:/etc/X11/prefdm -nodaemon
h1:35:respawn:/etc/init.d/init.cssd run >/dev/null 2>&1 </dev/null --> arrancar daqui

-----------------------------------------------------------------------------

# System initialization.
si::sysinit:/etc/rc.d/rc.sysinit

l0:0:wait:/etc/rc.d/rc 0
l1:1:wait:/etc/rc.d/rc 1
l2:2:wait:/etc/rc.d/rc 2
h1:35:respawn:/etc/init.d/init.cssd run >/dev/null 2>&1 </dev/null --> incluir aqui
l3:3:wait:/etc/rc.d/rc 3
l4:4:wait:/etc/rc.d/rc 4
l5:5:wait:/etc/rc.d/rc 5
l6:6:wait:/etc/rc.d/rc 6


# Trap CTRL-ALT-DELETE
#ca::ctrlaltdel:/sbin/shutdown -t3 -r now           --> comentar esta linha para não reiniciar o servidor com o comando ctrl + alt + del.





-- ####################  FIM  ######################