Recomendo fazer uma partiусo chamada "/u01". Padrсo Oracle.

Caso tenha duvidas da instalaусo, segue abaixo o link oficial da Oracle para instalaусo do Oracle 11g R2.
http://docs.oracle.com/cd/E11882_01/install.112/e24326/toc.htm



Oracle recomenda as seguintes definiушes mьnimo.

Instale os seguintes pacotes.


	rpm -ivh binutils-2.17.50*

	rpm -ivh compat-libstdc++-33*
	
	rpm -ivh elfutils-libelf-devel-* 

	rpm -ivh gcc-4.1.2-*

	rpm -ivh gcc-c++-4.1.2*

	rpm -ivh glibc-2.*

	rpm -ivh glibc-common-*

	rpm -ivh glibc-devel-2*

	rpm -ivh glibc-headers-*

	rpm -ivh ksh-20100*

	rpm -ivh libaio-0.* 

	rpm -ivh libaio-devel-0.*

	rpm -ivh libgcc-4.1.*

	rpm -ivh libstdc++-4.1.*

	rpm -ivh libstdc++-devel-4.*
	
	rpm -ivh libXp-1.0.0-*
	
	rpm -ivh libXp-devel-1.0.*

	rpm -ivh make-3.81-3.e*

	rpm -ivh sysstat-7.0.2-11.el5.i386.rpm
	
	rpm -ivh unixODBC-libs-2.2.11-10.el5.i386.rpm
	
	rpm -ivh unixODBC-2.2.11-10.el5.i386.rpm

	rpm -ivh unixODBC-devel-2.*

	rpm -ivh unixODBC-2.2.1*
	
	rpm -ivh sysstat-7.0.*


cd /
eject





find /etc/selinux/config -exec sed -i 's/SELINUX=/#SELINUX=/g'  {} \;

echo "SELINUX=disabled" >> /etc/selinux/config





cat /etc/pam.d/login | grep "pam_limits.so" | while read parameter
do
echo "#$parameter" >> /etc/pam.d/login
done





find /etc/pam.d/login -exec sed -i '/pam_limits.so/d' {} \;

echo "session    required     pam_limits.so" >> /etc/pam.d/login

find /etc/sysctl.conf -exec sed -i 's/fs.aio-max-nr/#fs.aio-max-nr/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/fs.file-max/#fs.file-max/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/kernel.shmmax/#kernel.shmmax/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/kernel.shmall/#kernel.shmall/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/kernel.shmmni/#kernel.shmmni/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/kernel.sem/#kernel.sem/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/net.ipv4.ip_local_port_range/#net.ipv4.ip_local_port_range/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/net.core.rmem_default/#net.core.rmem_default/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/net.core.rmem_max/#net.core.rmem_max/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/net.core.wmem_default/#net.core.wmem_default/g' {} \;
find /etc/sysctl.conf -exec sed -i 's/net.core.wmem_max/#net.core.wmem_max/g' {} \;












cat << EOF >> /etc/sysctl.conf

fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmmax = echo "( 13 * 1024 * 1024 * 1024 )" | bc
kernel.shmall = echo "( 10 * 1024 * 1024 * 1024 ) / $(getconf PAGE_SIZE)" | bc
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576

EOF









cat << EOF >> /etc/security/limits.conf

arteresoracle              soft    nproc   2047
oracle              hard    nproc   16384
oracle              soft    nofile  4096
oracle              hard    nofile  65536
oracle              soft    stack   10240

EOF








echo -e "\nCriar novos grupos e usuрrios."
groupadd -g 501 oinstall
groupadd -g 504 admin
groupadd -g 506 dba
groupadd -g 505 oper


useradd -u 502 -g oinstall -G dba,oper,admin oracle


echo -e "oracle\noracle" | passwd oracle


mkdir -p  /u01/app/11.2.0/grid
mkdir -p /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01
chmod -R 775 /u01/



mkdir -p /u02/app/oracle/oradata
chown -R oracle:oinstall /u02
chmod -R 775 /u02/





xhost +

#-- Logar como o usuрrio oracle e adicione as seguintes linhas no final do ".Bash_profile" arquivo, lembrando-se
#-- de ajustр-los para sua instalaусo especьfica.

HOST=$(hostname)

cat << EOF >> /home/oracle/.bash_profile

ORACLE_SID='prod'; export ORACLE_SID

TMP=/tmp; export TMP

TMPDIR=\$TMP; export TMPDIR

ORACLE_HOSTNAME=$HOST; export ORACLE_HOSTNAME

ORACLE_UNQNAME=prod; export ORACLE_UNQNAME

ORACLE_BASE=/u01/app/oracle; export ORACLE_BASE

DB_HOME=\$ORACLE_BASE/product/11.2.0/db_1; export DB_HOME

ORACLE_HOME=\$DB_HOME; export ORACLE_HOME

GRID_HOME=/u01/app/11.2.0/grid; export GRID_HOME

BASE_PATH=/usr/sbin:\$PATH; export BASE_PATH

PATH=\$ORACLE_HOME/bin:\$BASE_PATH; export PATH

LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH

CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib; export CLASSPATH
	
TNS_ADMIN=\$ORACLE_HOME/network/admin;  export TNS_ADMIN

ORACLE_TERM=xterm; export ORACLE_TERM
	
if [ \$USER = "oracle" ]; then
if [ \$SHELL = "/bin/ksh" ]; then
	ulimit -p 16384
	ulimit -n 65536
else
	ulimit -u 16384 -n 65536
fi
fi

alias grid_env='. /home/oracle/grid_env'
alias prod_env='. /home/oracle/prod_env'
alias sql='sqlplus / as sysdba'


EOF

	

if [ -e "/home/oracle/grid_env" ]; then
	rm -f /home/oracle/grid_env
fi

cat << EOF >> /home/oracle/grid_env

ORACLE_SID=+ASM1; export ORACLE_SID
ORACLE_HOME=\$GRID_HOME; export ORACLE_HOME
PATH=\$ORACLE_HOME/bin:\$BASE_PATH; export PATH

LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib; export CLASSPATH

EOF



if [ -e "/home/oracle/prod_env" ]; then
	rm -f /home/oracle/prod_env
fi	
	
cat << EOF >> /home/oracle/prod_env
	
ORACLE_SID=prod; export ORACLE_SID
ORACLE_HOME=\$DB_HOME; export ORACLE_HOME
PATH=\$ORACLE_HOME/bin:\$BASE_PATH; export PATH

LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib; export CLASSPATH

EOF


DISPLAY=:0.0; export DISPLAY
xhost +





sh runInstaller -ignoreInternalDriverError

