yum -y update

firewall-cmd --permanent --add-port=115/tcp

#fail2ban
sudo yum -y install fail2ban fail2ban-systemd
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

#apache
yum -y install httpd
firewall-cmd --permanent --add-service=http --add-service=https
firewall-cmd --reload
systemctl start httpd
systemctl enable httpd

setsebool -P httpd_can_network_connect_db on
setsebool -P httpd_can_network_connect on

#php
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install https://rpms.remirepo.net/enterprise/remi-release-7.rpm
yum -y install yum-utils
yum-config-manager --disable 'remi-php*'
yum-config-manager --enable remi-php81
yum repolist
yum -y install php php-{cli,fpm,mysqlnd,zip,devel,gd,mbstring,curl,xml,pear,bcmath,json,opcache,redis,memcache}
service httpd restart

#wget and rsync
yum -y install wget
yum -y install rsync

#mariaDB klient
echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" | tee /etc/yum.repos.d/MariaDB.repo
yum -y install MariaDB-client MariaDB-shared

#Wordpress 
mkdir /var/www/html/wordpress 
cd ~
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
rsync -avP ~/wordpress/ /var/www/html/wordpress/
mkdir /var/www/html/wordpress/wp-content/uploads
chown -R apache:apache /var/www/html/wordpress/
cd /var/www/html/wordpress
cp wp-config-sample.php wp-config.php

sed -i "/database_name_here/c\define('DB_NAME', 'wordpress');" wp-config.php
sed -i "/username_here/c\define('DB_USER', 'wpuser');" wp-config.php
sed -i "/password_here/c\define('DB_PASSWORD', 'Kode1234\!');" wp-config.php
sed -i "/localhost/c\define('DB_HOST', '192.168.1.3');" wp-config.php

cd /home/user

#DHCP
yum install -y dhcp
firewall-cmd --add-service=dhcp --permanent
systemctl enable dhcpd.service 

#DNS
yum install -y bind bind-utils
systemctl enable named
systemctl start named
firewall-cmd --permanent --add-port=53/tcp
firewall-cmd --permanent --add-port=53/udp
firewall-cmd --reload 

#webmin
echo "[Webmin]
name=Webmin Distribution Neutral
#baseurl=http://download.webmin.com/download/yum
mirrorlist=http://download.webmin.com/download/yum/mirrorlist
enabled=1" | tee /etc/yum.repos.d/webmin.repo

wget http://www.webmin.com/jcameron-key.asc
rpm --import jcameron-key.asc
yum -y install webmin
systemctl enable webmin
service webmin start
firewall-cmd --zone=public --add-port=10000/tcp --permanent
firewall-cmd --reload 

