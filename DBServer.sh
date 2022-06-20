yum -y update

#mariaDB
echo "[mariadb]
name = MariaDB
baseurl = http://yum.mariadb.org/10.3/centos7-amd64
gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB
gpgcheck=1" | tee /etc/yum.repos.d/MariaDB.repo

yum -y install mariadb-server
systemctl start mariadb
systemctl enable mariadb.service

mysql_secure_installation <<EOF

y
Kode1234!
Kode1234!
y
y
y
y
EOF

sed -i '/\[mysqld\]/a bind-address = 192.168.1.3' /etc/my.cnf.d/server.cnf

systemctl restart mariadb
firewall-cmd --permanent --add-port=3306/tcp
firewall-cmd --reload 

Q1="CREATE DATABASE wordpress;"
Q2="CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'Kode1234!';"
Q3="GRANT ALL PRIVILEGES on wordpress.* TO 'wpuser'@'localhost';"
Q5="CREATE USER 'wpuser'@'192.168.1.2' IDENTIFIED BY 'Kode1234!';"
Q6="GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'192.168.1.2';"
Q7="FLUSH PRIVILEGES;"
SQL=${Q1}${Q2}${Q3}${Q5}${Q6}${Q7}
mysql -u root --password=Kode1234! -e "$SQL"


