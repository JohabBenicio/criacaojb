

rpm -Uvh binutils-2.20.51.0.2-5.11.el6* ok

rpm -Uvh compat-libcap1-1.10-1* ok

rpm -Uvh compat-libstdc++-33-3.2.3-69.el6

rpm -Uvh gcc-4.4.4-13.el6*

rpm -Uvh gcc-c++-4.4.4-13.el6*

rpm -Uvh glibc-2.12-1.7.el6*

rpm -Uvh glibc-devel-2.12-1.7.el6*

rpm -Uvh ksh*

rpm -Uvh libgcc-4.4.4-13.el6*

rpm -Uvh libstdc++-4.4.4-13.el6*

rpm -Uvh libstdc++-devel-4.4.4-13.el6*

rpm -Uvh libaio-0.3.107-10.el6*

rpm -Uvh libaio-devel-0.3.107-10.el6*

rpm -Uvh make-3.81-19.el6*

rpm -Uvh sysstat-9.0.4-11.el6*

rpm -Uvh unixODBC-2.2.1*

rpm -Uvh unixODBC-devel-2.2.14-14.el6.x86_64.rpm


rpm -Uvh unixODBC-2.2.14-11.el6*
rpm -ivh sysstat-7.0.2-1 ok
rpm -ivh unixODBC-libs-2.2








groupadd -g 501 oinstall
groupadd -g 506 dba
groupadd -g 505 oper


useradd -u 502 -g oinstall -G dba,oper oracle


echo -e "oracle\noracle" | passwd oracle




cat << EOF >> /etc/security/limits.conf

oracle              soft    nproc   2047
oracle              hard    nproc   16384
oracle              soft    nofile  1024
oracle              hard    nofile  65536
oracle              soft    stack   10240

EOF






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

kernel.sem = 250 32000 100 128
kernel.shmall = `echo "( 10 * 1024 * 1024 * 1024 ) / $(getconf PAGE_SIZE)" | bc`
kernel.shmmax = `echo "( 13 * 1024 * 1024 * 1024 )" | bc`
kernel.shmmni = 4096

fs.file-max = 6815744
fs.aio-max-nr = 1048576

net.ipv4.ip_local_port_range = 9000 65500

net.core.rmem_max = 4194304
net.core.wmem_max = 1048576

net.core.rmem_default = 262144
net.core.wmem_default = 262144


EOF



/sbin/sysctl -p








find /etc/selinux/config -exec sed -i 's/SELINUX=/#SELINUX=/g'  {} \;

echo "SELINUX=disabled" >> /etc/selinux/config





cat /etc/pam.d/login | grep "pam_limits.so" | while read parameter
do
echo "#$parameter" >> /etc/pam.d/login
done



find /etc/pam.d/login -exec sed -i '/pam_limits.so/d' {} \;

echo "session    required     pam_limits.so" >> /etc/pam.d/login







mkdir -p /u01/app/11.2.0/grid
mkdir -p /u01/app/oracle/product/11.2.0/db_1
chown -R oracle:oinstall /u01
chmod -R 775 /u01






#-- Logar como o usuрrio oracle e adicione as seguintes linhas no final do ".Bash_profile" arquivo, lembrando-se
#-- de ajustр-los para sua instalaусo especьfica.

HOST=$(hostname)

cat << EOF >> /home/oracle/.bash_profile

ORACLE_SID='NBS'; export ORACLE_SID

TMP=/tmp; export TMP

TMPDIR=\$TMP; export TMPDIR

ORACLE_HOSTNAME=$HOST; export ORACLE_HOSTNAME

ORACLE_UNQNAME=NBS; export ORACLE_UNQNAME

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
	

alias grid_env='. /home/oracle/grid_env'
alias prod_env='. /home/oracle/prod_env'
alias sql='sqlplus / as sysdba'


EOF

	

if [ -e "/home/oracle/grid_env" ]; then
	rm -f /home/oracle/grid_env
fi

cat << EOF > /home/oracle/grid_env

ORACLE_SID=+ASM; export ORACLE_SID
ORACLE_HOME=\$GRID_HOME; export ORACLE_HOME
PATH=\$ORACLE_HOME/bin:\$BASE_PATH; export PATH

LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib; export CLASSPATH

EOF



if [ -e "/home/oracle/prod_env" ]; then
	rm -f /home/oracle/prod_env
fi	
	
cat << EOF >> /home/oracle/prod_env
	
ORACLE_SID=NBS; export ORACLE_SID
ORACLE_HOME=\$DB_HOME; export ORACLE_HOME
PATH=\$ORACLE_HOME/bin:\$BASE_PATH; export PATH

LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib; export LD_LIBRARY_PATH
CLASSPATH=\$ORACLE_HOME/JRE:\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib; export CLASSPATH

EOF


DISPLAY=:0.0; export DISPLAY
xhost +





sh runInstaller -ignoreInternalDriverError





[oracle@srvorastandby ~]$ cat /etc/sysconfig/network-scripts/ifcfg-eth0
# Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet
DEVICE=eth0
BOOTPROTO=static
BROADCAST=129.1.255.255
HWADDR=00:1E:C9:EC:47:D0
IPADDR=129.1.7.250
NETMASK=255.255.0.0
NETWORK=129.1.0.0
GATEWAY=129.1.100.254
ONBOOT=yes
[oracle@srvorastandby ~]$ cat /etc/sysconfig/network-scripts/ifcfg-eth1
# Broadcom Corporation NetXtreme II BCM5708 Gigabit Ethernet
DEVICE=eth1
BOOTPROTO=dhcp
HWADDR=00:1E:C9:EC:47:D2
ONBOOT=no
HOTPLUG=no
DHCP_HOSTNAME=srvorastandby.caltabiano.net.br
[oracle@srvorastandby ~]$


[oracle@srvorastandby ~]$ cat /etc/resolv.conf
search caltabiano.net.br
nameserver 129.1.1.5
nameserver 8.8.8.8
#nameserver 129.1.1.2
#nameserver 129.1.1.3
[oracle@srvorastandby ~]$





[oracle@srvorastandby ~]$ cat /etc/resolv.conf
search caltabiano.net.br
nameserver 129.1.1.5
nameserver 8.8.8.8






Disk /dev/sdb: 146.2 GB, 146163105792 bytes
255 heads, 63 sectors/track, 17769 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0001a2ef

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1       17769   142729461   83  Linux

Disk /dev/sdc: 499.6 GB, 499558383616 bytes
255 heads, 63 sectors/track, 60734 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0002d710

   Device Boot      Start         End      Blocks   Id  System
/dev/sdc1   *           1          26      204800   83  Linux
Partition 1 does not end on cylinder boundary.
/dev/sdc2              26        3942    31457280   83  Linux
/dev/sdc3            3942        7206    26214400   83  Linux
/dev/sdc4            7206       60735   429972480    5  Extended
/dev/sdc5            7206        9295    16777216   82  Linux swap / Solaris
/dev/sdc6            9295       60735   413193216   83  Linux

Disk /dev/sda: 146.2 GB, 146163105792 bytes
255 heads, 63 sectors/track, 17769 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x0002a137

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1               1       17769   142729461   83  Linux

























Configuração RAID 10


qManufacturer: Dell Inc.
Product Name: PowerEdge 2950




NOME DA INSTANCIA:......................... NBS

NOME DO USUARIO:........... NBS
TAMANHO DO OWNER:.......... 118,218 GB

NOME DO USUARIO:........... SFREITAS
TAMANHO DO OWNER:.......... 3 MB

NOME DO USUARIO:........... USREP
TAMANHO DO OWNER:.......... 15 MB

NOME DO USUARIO:........... BSC
TAMANHO DO OWNER:.......... 11 MB

NOME DO USUARIO:........... ADRIANAP
TAMANHO DO OWNER:.......... 64 KB

NOME DO USUARIO:........... DEFAULT_ACESSO
TAMANHO DO OWNER:.......... 462 MB

NOME DO USUARIO:........... AURORA$JIS$UTILITY$
TAMANHO DO OWNER:.......... 2 MB

NOME DO USUARIO:........... RMAXIMO
TAMANHO DO OWNER:.......... 297 MB

NOME DO USUARIO:........... OSE$HTTP$ADMIN
TAMANHO DO OWNER:.......... 192 KB

NOME DO USUARIO:........... WEBEASY
TAMANHO DO OWNER:.......... 65 MB

NOME DO USUARIO:........... MAUROC
TAMANHO DO OWNER:.......... 256 KB



NOME DO USUARIO:........... NBSLAN
TAMANHO DO OWNER:.......... 10 MB

NOME DO USUARIO:........... FORPONTO
TAMANHO DO OWNER:.......... 426 MB

NOME DO USUARIO:........... DBA_ITTECH
TAMANHO DO OWNER:.......... 320 KB

NOME DO USUARIO:........... RDORTA
TAMANHO DO OWNER:.......... 64 KB

NOME DO USUARIO:........... RMORAES
TAMANHO DO OWNER:.......... 128 KB

NOME DO USUARIO:........... OMWB_EMULATION
TAMANHO DO OWNER:.......... 128 KB

NOME DO USUARIO:........... VINIBR
TAMANHO DO OWNER:.......... 2,523 GB

NOME DO USUARIO:........... EMALTA
TAMANHO DO OWNER:.......... 384 KB

NOME DO USUARIO:........... CRMGOLD
TAMANHO DO OWNER:.......... 32 MB

NOME DO USUARIO:........... QUEST
TAMANHO DO OWNER:.......... 69 MB

NOME DO USUARIO:........... NINA
TAMANHO DO OWNER:.......... 256 KB

NOME DO USUARIO:........... AGENCE
TAMANHO DO OWNER:.......... 4,167 GB

NOME DO USUARIO:........... JCARVALHO
TAMANHO DO OWNER:.......... 1 MB

NOME DO USUARIO:........... NBSA
TAMANHO DO OWNER:.......... 34 MB





select distinct TABLESPACE_NAME,OWNER from  dba_segments where owner='NBS';

TABLESPACE_NAME                OWNER
------------------------------ -----
NBS_DATA                       NBS
NBS_INDEX                      NBS
PROD01_DATA                    NBS


select distinct TABLESPACE_NAME,OWNER from  dba_segments where TABLESPACE_NAME='XDB';



set long 300
set pages 300
set lines 300

select dbms_metadata.get_ddl('USER',username) from dba_users where username in ('NBS');


CREATE USER "NBS" IDENTIFIED BY VALUES '13582E923F1E0DB8' DEFAULT TABLESPACE "NBS_DATA" TEMPORARY TABLESPACE "TEMP";





set pagesize 0
set linesize 1000
select ' create tablespace ' || df.tablespace_name || chr(10)
|| ' datafile ''' || df.file_name || ''' size ' || df.bytes
|| decode(autoextensible,'N',null, chr(10) || ' autoextend on maxsize '
|| maxbytes)
|| chr(10)
|| 'default storage ( initial ' || initial_extent
|| decode (next_extent, null, null, ' next ' || next_extent )
|| ' minextents ' || min_extents
|| ' maxextents ' || decode(max_extents,'2147483645','unlimited',max_extents)
|| ') ;'
from dba_data_files df, dba_tablespaces t
where df.tablespace_name=t.tablespace_name and df.tablespace_name in ('INTEGRATOR');



















                                            Tamanho      Tamanho      Espaco       Espaco        %
Tablespace                  T     Em uso      atual       maximo livre atual  livre total Ocupacao
--------------------------- - ---------- ---------- ------------ ----------- ------------ --------
XDB                         P          0         12        4,096          11        4,095        0
INDX                        P         22         52        4,096          29        4,073        0
PROD01_INDX                 P         26        100        4,096          73        4,069        0
TS_REP                      P         15         36        4,096          20        4,080        0
SYSAUX                      P        944      9,138       49,941       8,193       48,996        1
USERS                       P        105        128        4,096          22        3,990        2
TOOLS                       P        216        431        4,096         214        3,879        5
FORPONTO                    P        283        341        4,096          57        3,812        6
TS_CONTRACESSO              P        462        555        4,096          92        3,633       11
SYSTEM                      P        898      2,528        4,096       1,629        3,197       21
UNDOTBS1                    U      3,459     12,157       16,384       8,697       12,924       21
PROD01_DATA                 P      6,254      6,327        8,192          72        1,937       76
TEMP                        T     36,096     36,096       47,360           0       11,264       76
NBS_DATA                    P     99,475     99,584      122,880         108       23,404       80
NBS_INDEX                   P     22,550     24,036       27,648       1,485        5,097       81
                              ---------- ---------- ------------ ----------- ------------
Total:                           170,805    191,521      309,269      20,702      138,450


GROUP_TEMP



nohup impdp \'/ as sysdba\' directory=MIGRACAO full=y dumpfile=expdp_full_producao_2_01.dmp,expdp_full_producao_2_02.dmp,expdp_full_producao_2_03.dmp,expdp_full_producao_2_04.dmp,expdp_full_producao_2_05.dmp,expdp_full_producao_2_06.dmp,expdp_full_producao_2_07.dmp,expdp_full_producao_2_08.dmp logfile=impdp_full_migra.log &


create directory MIGRACAO as '/u02/backup/nbs/logico/u02/oracle/backup/nbs/logico';




TOOLS




                                            Tamanho      Tamanho      Espaco       Espaco        %
Tablespace                  T     Em uso      atual       maximo livre atual  livre total Ocupacao
--------------------------- - ---------- ---------- ------------ ----------- ------------ --------
XDB                         P          0         12        4,096          11        4,095        0
INDX                        P         22         52        4,096          29        4,073        0
PROD01_INDX                 P         26        100        4,096          73        4,069        0
TS_REP                      P         15         36        4,096          20        4,080        0
SYSAUX                      P        944      9,138       49,941       8,193       48,996        1
USERS                       P        105        128        4,096          22        3,990        2
TOOLS                       P        216        431        4,096         214        3,879        5
FORPONTO                    P        283        341        4,096          57        3,812        6
TS_CONTRACESSO              P        462        555        4,096          92        3,633       11
SYSTEM                      P        898      2,528        4,096       1,629        3,197       21
UNDOTBS1                    U      3,520     12,157       16,384       8,636       12,863       21
PROD01_DATA                 P      6,254      6,327        8,192          72        1,937       76
TEMP                        T     36,096     36,096       47,360           0       11,264       76
NBS_DATA                    P     99,475     99,584      122,880         108       23,404       80
NBS_INDEX                   P     22,551     24,036       27,648       1,484        5,096       81
                              ---------- ---------- ------------ ----------- ------------
Total:                           170,867    191,521      309,269      20,640      138,388



create temporary tablespace GROUP_TEMP tempfile '+DGDATA' size 128m autoextend on next 128m maxsize 8g, '+DGDATA' size 128m autoextend on next 128m maxsize 8g;





5120


vm.nr_hugepages = 5125





COLUMN object_name FORMAT A30
SELECT count(*)
FROM   dba_objects
WHERE  status = 'INVALID'
ORDER BY owner, object_type, object_name;

  COUNT(*)
----------
      5934


 +DGDATA/nbs/controlfile/current.256.879757789


 compatible

 log_archive_dest

 log_archive_dest

 3446,3444





NLS_LANG
------------------------------------------------------------
export NLS_LANG=AMERICAN_AMERICA.WE8ISO8859P1



NBSHOMO =
        (DESCRIPTION=
          (ADDRESS=(PROTOCOL=TCP)(HOST=129.1.7.250)(PORT=1521))
          (CONNECT_DATA =
           (SERVER = DEDICATED)
           (SID=NBS)
        )
)











LISTENER =
  (DESCRIPTION_LIST =
    (DESCRIPTION =
      (ADDRESS = (PROTOCOL = TCP)(HOST = 129.1.7.250)(PORT = 1521))
    )
  )

SID_LIST_LISTENER =
  (SID_LIST =
    (SID_DESC =
      (SID_NAME = NBS)
      (ORACLE_HOME = /u01/app/oracle/product/11.2.0/db_1)
    )
  )














nbs =
        (description=
          (address=(protocol=tcp)(host=129.1.2.250)(port=1521))
          (connect_data =
           (server = dedicated)
           (sid=nbs)
        )
)
nbs_antigo =
        (description=
          (address=(protocol=tcp)(host=129.1.2.250)(port=1521))
          (connect_data =
           (server = dedicated)
           (service_name = nbs)
        )
)


nbshomo =
        (description=
          (address=(protocol=tcp)(host=129.1.7.250)(port=1521))
          (connect_data =
           (server = dedicated)
           (sid=nbs)
        )
)

