


======================================================================================================================================

yum search oracle-validate

# yum install oracle-rdbms-server-11gR2-preinstall

yum install -y oracle-validated.x86_64 --nogpgcheck

yum update -y --nogpgcheck

#oracleasm-support-2.1.8-1.el6.x86_64.rpm
======================================================================================================================================

/etc/init.d/iptables status

find /etc/selinux/config -exec sed -i 's/SELINUX=/#SELINUX=/g'  {} \;
echo "SELINUX=disabled" >> /etc/selinux/config

/etc/init.d/iptables stop
chkconfig iptables off

======================================================================================================================================


echo -e "oracle\noracle" | passwd oracle

id oracle





======================================================================================================================================

cat <<EOF>/etc/hosts
# Do not remove the following line, or various programs
# that require network functionality will fail.
#::1            localhost6.localdomain6 localhost6

127.0.0.1         localhost.localdomain   localhost
172.16.243.138    jhbsml10g.com           jhbsml10g

EOF


======================================================================================================================================

chown -R oracle:oinstall /u01


======================================================================================================================================

su - oracle

cat <<EOF>~/.bash_profile
# .bash_profile
# Get the aliases and functions
if [ -f ~/.bashrc ]; then
        . ~/.bashrc
fi

# User specific environment and startup programs
PATH=\$PATH:\$HOME/bin:/sbin
export PATH

# Begin Oracle settings
export ORACLE_SID=jhbmst
export ORACLE_BASE="/u01/app/oracle"
export ORACLE_HOME="\$ORACLE_BASE/product/10.2.0/db_1"
export NLS_LANG="AMERICAN_AMERICA.WE8ISO8859P1"
export NLS_DATE_FORMAT="DD/MM/RRRR hh24:mi"
export LD_LIBRARY_PATH="\$ORACLE_HOME/lib:/lib64:/usr/lib64:/usr/X11R6/lib64:."
export THREADS_FLAG="native"
export PATH="\$ORACLE_GRID_HOME/bin:\$ORACLE_HOME/bin:\$ORACLE_HOME/OPatch:\$ORACLE_BASE/admin/otlp/scripts:/sbin:\$PATH:/usr/X11R6/lib64:/usr/X11R6/bin:."
export PS1="[\u@\h [\\\$ORACLE_SID] \W]\\\$ "
umask 022

alias home="cd \$ORACLE_HOME"
alias base="cd \$ORACLE_BASE"
alias admin="cd \$ORACLE_BASE/admin"
alias sql="sqlplus / as sysdba"
alias asm="export ORAENV_ASK=NO ; ORACLE_SID=+ASM ; . oraenv; export ORAENV_ASK=YES"
alias sid="export ORAENV_ASK=NO ; ORACLE_SID=jhbmst ; . oraenv; export ORAENV_ASK=YES"

# End Oracle settings

EOF


======================================================================================================================================

. .bash_profile

mkdir -p $ORACLE_HOME

======================================================================================================================================



DESCOMPACTAR BINARIO ORACLE
===========================
su - oracle

gunzip 10201_database_linux_x86_64.cpio.gz
cpio -di < 10201_database_linux_x86_64.cpio

./runInstaller



SUBIR PARA 10.2.0.5
===========================
unzip p8202632_10205_Linux-x86-64.zip

./runInstaller



@?/rdbms/admin/catupgrd

@?/rdbms/admin/utlrp



mkdir /u02/ora_install

/u02/ora_install/grid/runInstaller

/u02/ora_install/database/runInstaller





