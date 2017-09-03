

Environment variables
First step is create a user and create a password: # useradd oracle
# password oracle

export JAVA_HOME=/u01/app/java
export ORACLE_HOME=/u01/app/oracle/middleware/oracle_home
export WL_HOME=/u01/app/oracle/middleware/oracle_home/wlserver


mkdir -p /u01/app/oracle/domains/
mkdir -p $JAVA_HOME
mkdir -p $ORACLE_HOME
mkdir -p $WL_HOME


mkdir /u01/ora_install


scp jdk-8u73-linux-x64.tar.gz fmw_12.2.1.0.0_wls_Disk1_1of1.zip root@172.16.214.129:/u01/ora_install

tar -vzxf jdk-8u73-linux-x64.tar.gz

mv jdk1.8.0_73 $JAVA_HOME


export JAVA_HOME=/u01/app/java/jdk1.8.0_73

#################################################################################

ANALISE MAIS ABAIXO QUE ESTA CORRETO!!!

Login as root user on Zlinux
• Perform the command:

# update-alternatives --install /usr/bin/java java $JAVA_HOME ifcon
$JAVA_HOME/bin/java -1

• After install the alternative , now we will configurate this as default, for this perform the followed command

#update-alternatives –-config java


7.1 Installing Weblogic
First of all is necessary install the Oracle weblogic application server, for this run the command:
#java –d64 –jar fmw_12.2.1.0.0_wls.jar






## ##############################################################################
# 1 Criar usuario.
## ##############################################################################

useradd oracle
groupadd oinstall
usermod -g oinstall oracle
echo -e "oracle\noracle" | passwd oracle

chown -R oracle:oinstall /u01

## ##############################################################################
# 2 Configurar o bash profiler
## ##############################################################################

cat <<EOF>/home/oracle/.web_env.sh

#!/bin/bash

export JAVA_HOME=/u01/app/oracle/java/jdk1.8.0_73
export MW_HOME=/u01/app/oracle/middleware
export ORACLE_HOME=$MW_HOME/oracle_home
export MW_HOME=$MW_HOME/wlserver
export NODEMGR_HOME=/u01/app/oracle/domains/wl_domain/nodemanager
export DOMAIN_HOME=/u01/app/oracle/domains/agendamento
export PATH=$PATH:$JAVA_HOME/bin

alias startupweblogic="nohup /u01/app/oracle/middleware/oracle_home/domains/Agendamento/startWebLogic.sh >/tmp/StartupWeblogic.log &"
alias startupnodemanager="nohup /u01/app/oracle/middleware/oracle_home/domains/Agendamento/bin/startNodeManager.sh > /tmp/StartupNodeManager.log &"


EOF

cat <<EOF>>/home/oracle/.bash_profile

alias weblogic_env=". /home/oracle/.web_env.sh"

EOF


su - oracle
mkdir -p $JAVA_HOME
mkdir -p $MW_HOME


## ##############################################################################
# 3 Configurar o /etc/hosts
## ##############################################################################

exit
cat <<EOF>/etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

172.16.214.129  weblogic.com    weblogic
172.16.28.137   wlms01.com      wlms01
172.16.28.138   wlms02.com      wlms02
EOF

## ##############################################################################
# 4 Configurar o SUDO
## ##############################################################################

vi /etc/sudoers

oracle    ALL=(ALL)       ALL


## ##############################################################################
# 4 Configurar o SUDO
## ##############################################################################

cd /Users/johabbeniciodeoliveira/OneDrive/TEOR/Johab\ Teor/Scripts/WebLogic/
scp jdk-8u73-linux-x64.tar.gz oracle@172.16.214.129:/u01/ora_install


tar -xvf jdk-8u73-linux-x64.tar.gz
chown -R oracle:oinstall /u01
su - oracle
mv /u01/ora_install/jdk1.8.0_73/* $JAVA_HOME

update-alternatives --install /usr/bin/java java $JAVA_HOME/bin/java -1
update-alternatives --config java

## ##############################################################################
# 5 Instalar o WebLogic
## ##############################################################################

cd /u01/ora_install/

unzip fmw_12.2.1.0.0_wls_Disk1_1of1.zip

java -jar -d64 fmw_12.2.1.0.0_wls.jar




## ##############################################################################
# 6 Criar arquivo de boot
## ##############################################################################

cd $DOMAIN_HOME/wl_domain/servers/AdminServer/
mkdir security
cd security


cat <<EOF>boot.properties
username=weblogic
password=welcome1
EOF


## ##############################################################################
# 5 Instalar o WebLogic
## ##############################################################################






nohup sh /u01/app/oracle/middleware/oracle_home/wlserver/server/bin/startNodeManager.sh





/u01/app/oracle/domains/wl_domain/security




JAVA Memory arguments: -Xms256m -Xmx512m


vde.home = /u01/app/oracle/domains/wl_domain/servers/AdminServer/data/ldap
weblogic.Name = AdminServer
weblogic.ProductionModeEnabled = true
weblogic.home = /u01/app/oracle/middleware/oracle_home/wlserver/server
wls.home = /u01/app/oracle/middleware/oracle_home/wlserver/server





WL_HOME="/u01/app/oracle/middleware/oracle_home/wlserver"
export WL_HOME