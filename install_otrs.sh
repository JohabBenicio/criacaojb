178.63.99.24


sudo yum install "perl(Archive::Tar)" "perl(Archive::Zip)" "perl(Crypt::Eksblowfish::Bcrypt)" "perl(Crypt::SSLeay)" "perl(Date::Format)" "perl(DBD::Pg)" "perl(Encode::HanExtra)" "perl(IO::Socket::SSL)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(IO::Socket::SSL)" "perl(ModPerl::Util)" "perl(Net::DNS)" "perl(Net::LDAP)" "perl(Template)" "perl(Template::Stash::XS)" "perl(Text::CSV_XS)" "perl(Time::Piece)" "perl(XML::LibXML)" "perl(XML::LibXSLT)" "perl(XML::Parser)" "perl(YAML::XS)"


sudo yum install "perl(Crypt::Eksblowfish::Bcrypt)" "perl(Encode::HanExtra)" "perl(JSON::XS)" "perl(JSON::XS)" "perl(Mail::IMAPClient)" "perl(ModPerl::Util)" "perl(YAML::XS)"

/otrs/installer.pl

update user set password=PASSWORD("oracle") where User='root';



 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/var/httpd/htdocs(/.*)?" 
 semanage fcontext -a -t httpd_sys_content_t "/opt/otrs/bin/cgi-bin(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/Kernel(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/var/sessions(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/var/log(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/var/packages(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/var/stats(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/var/tmp(/.*)?" 
 semanage fcontext -a -t httpd_sys_rw_content_t "/opt/otrs/bin(/.*)?" 
 


systemctl stop mariadb.service
systemctl start mariadb.service


/bin/systemctl restart  mariadb.service

max_allowed_packet = 20M 
query_cache_size = 32M 
innodb_log_file_size = 256M


/opt/otrs/bin/otrs.CheckModules.pl
