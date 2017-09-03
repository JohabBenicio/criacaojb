

show parameter remote

alter system reset remote_listener;


bom dia!

favor recriar standby das instâncias prodadm, prodcl e prodlm hoje no oracle RAC para a máquina 192.168.50.4.
Favor tomar cuidado na hora de subir o grid do standby, pois ela trabalhou como produção por 3 dias devido a problema na base de produção.
OBS: atenção quando o standby estiver montado, verificar o parâmetro remote listener para não pegar no produção.
Qualquer dúvida entrar em contato com o Fábio Galão, ele está por dentro do que deve ser feito.

Obrigado!


################################################################################################################
LADO STANDBY
################################################################################################################
# 1) - Configurar os alias

alias prodcl='export ORAENV_ASK=NO ; ORACLE_SID=prodcl ; . oraenv; export ORAENV_ASK=YES'
alias asm='export ORAENV_ASK=NO ; ORACLE_SID=+ASM ; . oraenv; export ORAENV_ASK=YES'


################################################################################################################
LADO STANDBY
################################################################################################################
# 2) - Subir o banco de dados em modo nomount

prodcl

sqlplus / as sysdba
alter system set remote_listener='' scope=both;
shut immediate;
startup nomount;

################################################################################################################
LADO STANDBY
################################################################################################################
# 3) - Remover os arquivos de dados do banco de dados a ser atualizado

asm

asmcmd -p

cd +DGDATA/

ls PRODCL

rm -rf PRODCL



################################################################################################################
LADO PRODUCAO
################################################################################################################
# 4) - Preparar script para o duplicate


cat <<EOF>/tmp/dup_active_standby.rcv
duplicate target database for standby from active database;
EOF


################################################################################################################
LADO PRODUCAO
################################################################################################################
# 5) - Capturar o TNS e validar a conexão

# TNS STANDBY
grep "=" /u01/app/oracle/product/11.2.0.4/network/admin/tnsnames.ora | grep -i "standby"

prodadm_standby =
prodcl_standby =
prodlm_standby =

# TNS PRODUCAO
grep "=" /u01/app/oracle/product/11.2.0.4/network/admin/tnsnames.ora | grep "1" | grep -v "("

# Senhas
prodadm = oracle11g
prodcl = oracle
prodlm = oracle

######
rman target sys/oracle@prodcl1 auxiliary sys/oracle@prodcl_standby


################################################################################################################
LADO PRODUCAO
################################################################################################################
# 6) - Executar o duplicate


nohup rman target sys/oracle@prodcl1 auxiliary sys/oracle@prodcl_standby cmdfile /tmp/dup_active_standby.rcv > /tmp/dup_active_standby.log &
sleep 1
tail -300f /tmp/dup_active_standby.log










sed -i 's/192.168.50.33/192.168.50.4/g' /u01/app/oracle/product/11.2.0.4/network/admin/tnsnames.ora










