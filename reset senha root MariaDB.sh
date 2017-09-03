
# Parar o mariaDB
sudo systemctl stop mariadb.service

sudo mysqld_safe --skip-grant-tables --skip-networking &

mysql -u root

use mysql;

update user set password=PASSWORD("new-password") where User='root';

flush privileges;

exit

sudo systemctl start mariadb.service