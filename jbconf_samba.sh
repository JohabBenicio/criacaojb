
rpm -Uvh samba-3.6.9-151.el6.x86_64.rpm

[root@EstudoSMBnew2 Packages]# rpm -qa samba samba-common samba-client
samba-common-3.6.9-151.el6.x86_64
samba-3.6.9-151.el6.x86_64
samba-client-3.6.9-151.el6.x86_64


 yum search samba


 service samba status


vi /etc/samba/smb.conf


=== || === || === || === || === || === || === || === || === || === || === ||
=== Adicionar no final do doc
=== || === || === || === || === || === || === || === || === || === || === ||

[weblogic]
        path = /u01
        public = yes
        browseable = yes
        writable = yes
        guest ok = yes
        create mode = 0777
        directory mode = 0777


=== || === || === || === || === || === || === || === || === || === || === ||
=== Adicionar usuario para utilização do samba
=== || === || === || === || === || === || === || === || === || === || === ||


[root@EstudoSMBnew2 Packages]# smbpasswd -a oracle
New SMB password:
Retype new SMB password:
Added user oracle.


=== || === || === || === || === || === || === || === || === || === || === ||
=== Fazer que o samba suba ao starta o S.O. e sobir o serviço do mesmo
=== || === || === || === || === || === || === || === || === || === || === ||

[root@EstudoSMBnew2 Packages]# chkconfig smb on

=== || === || === || === || === || === || === || === || === || === || === ||
=== Starta serviços
=== || === || === || === || === || === || === || === || === || === || === ||

[root@EstudoSMBnew2 Packages]# service smb start
Starting SMB services:                                     [  OK  ]
[root@EstudoSMBnew2 Packages]# service smb status
smbd (pid  2506) is running...

=== || === || === || === || === || === || === || === || === || === || === ||
=== Testando Samba
=== || === || === || === || === || === || === || === || === || === || === ||


[root@EstudoSMBnew2 Packages]# smbclient -U oracle -L 10.1.3.195
Enter oracle password:
Domain=[MYGROUP] OS=[Unix] Server=[Samba 3.6.9-151.el6]

        Sharename       Type      Comment
        ---------       ----      -------
        backup          Disk
        IPC$            IPC       IPC Service (Samba Server Version 3.6.9-151.el6)
        oracle          Disk      Home Directories
Domain=[MYGROUP] OS=[Unix] Server=[Samba 3.6.9-151.el6]

        Server               Comment
        ---------            -------

        Workgroup            Master
        ---------            -------


=== || === || === || === || === || === || === || === || === || === || === ||
=== Status do Firewall
=== || === || === || === || === || === || === || === || === || === || === ||

service iptables stop


=== || === || === || === || === || === || === || === || === || === || === ||
=== Conf windows
=== || === || === || === || === || === || === || === || === || === || === ||

set use 10.1.3.195






mount -t smbfs //10.1.3.195/backup /mnt/smb -o username=oracle,password=oracle








