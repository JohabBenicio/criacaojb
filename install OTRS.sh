


yum -y update
yum -y install epel-release
yum -y install httpd mod_perl




/sbin/chkconfig httpd on
systemctl start httpd
firewall-cmd --zone=public --add-port=80/tcp --permanent
firewall-cmd --reload

yum -y install mariadb


 yum -y install mariadb-server
 /sbin/chkconfig mariadb on
 systemctl start mariadb
 mysql_secure_installation



sed -i '/\[mysqld\]/d' /etc/my.cnf

cp /etc/my.cnf /tmp/

cat <<EOF>/etc/my.cnf
[mysqld]
max_allowed_packet = 20M
query_cache_size = 32M
innodb_log_file_size = 256M
EOF

cat /tmp/my.cnf>>/etc/my.cnf


 systemctl stop mariadb
 rm -f /var/lib/mysql/ib_logfile0
 rm -f /var/lib/mysql/ib_logfile1
 systemctl start mariadb

 yum -y install policycoreutils-python


 yum -y install wget bzip2
cd /opt

 wget http://ftp.otrs.org/pub/otrs/otrs-5.0.11.tar.bz2

 tar jxvpf otrs-5.0.11.tar.bz2
 mv otrs-5.0.11 otrs

 useradd -d /opt/otrs/ -c 'OTRS user' otrs
 usermod -G apache otrs

 yum -y install "perl(ExtUtils::MakeMaker)" "perl(Sys::Syslog)"

yum -y install "perl(Archive::Tar)" "perl(Archive::Zip)" "perl(Crypt::Eksblowfish::Bcrypt)" "perl(Crypt::SSLeay)" "perl(Date::Format)" "perl(DBD::Pg)" "perl(Encode::HanExtra)" "perl(IO::Socket::SSL)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(IO::Socket::SSL)" "perl(ModPerl::Util)" "perl(Net::DNS)" "perl(Net::LDAP)" "perl(Template)" "perl(Template::Stash::XS)" "perl(Text::CSV_XS)" "perl(Time::Piece)" "perl(XML::LibXML)" "perl(XML::LibXSLT)" "perl(XML::Parser)" "perl(YAML::XS)"


yum -y install "perl(Crypt::Eksblowfish::Bcrypt)" "perl(Encode::HanExtra)" "perl(JSON::XS)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(ModPerl::Util)" "perl(YAML::XS)"

cd /opt/otrs/

cp Kernel/Config.pm.dist Kernel/Config.pm
ln -s /opt/otrs/scripts/apache2-httpd.include.conf /etc/httpd/conf.d/zzz_otrs.conf
/opt/otrs/bin/otrs.SetPermissions.pl --web-group=apache
systemctl restart httpd

systemctl stop firewalld
systemctl disable firewalld
getenforce




find /etc/selinux/config -exec sed -i 's/SELINUX=/#SELINUX=/g'  {} \;
echo "SELINUX=disabled" >> /etc/selinux/config



< CONFIGURE O OTRS E DEPOIS CONTINUE >
172.16.214.165/otrs/installer.pl

sudo cp /opt/otrs/var/cron/otrs_daemon.dist /opt/otrs/var/cron/otrs_daemon
sudo /opt/otrs/bin/Cron.sh start otrs


bin/otrs.Daemon.pl status


ls -l /opt/otrs/var/cron/otrs_daemon


root@localhost
R5cn4nXkvdTQFTTY