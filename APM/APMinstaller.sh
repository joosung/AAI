#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * APMinstaller v.0.3.5                                                            #
# * CentOS 7.6   Minimal ISO                                                        #
# * Apache 2.4.X , MariaDB 10.3.X, PHP 7.2.X setup shell script                     #
# * Created Date    : 2019/1/15                                                     #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           repositories install         #
#                                        #
########################################## 

yum -y install wget openssh-clients bind-utils git nc vim-enhanced man ntsysv \
iotop sysstat strace lsof mc lrzsz zip unzip bzip2 glibc* net-tools

cd /etc/yum.repos.d && wget https://repo.codeit.guru/codeit.el`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo

yum install -y epel-release yum-utils

rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm

echo "[mariadb]" > /etc/yum.repos.d/MariaDB.repo
echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "baseurl = http://yum.mariadb.org/10.3/rhel7-amd64" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo 

yum -y update

cd /root/APM

##########################################
#                                        #
#           SELINUX disabled             #
#                                        #
##########################################

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
/usr/sbin/setenforce 0

##########################################
#                                        #
#           아파치 및 HTTP2 설치             #
#                                        #
########################################## 

# Nghttp2 설치
yum --enablerepo=epel -y install libnghttp2

# /etc/mime.types 설치 
yum -y install mailcap

# httpd 설치
yum -y install c-ares

yum -y install httpd

yum -y install openldap-devel expat-devel

yum -y install libdb-devel perl

yum -y install httpd-devel mod_ssl python-certbot-apache

systemctl start httpd
systemctl enable httpd

##########################################
#                                        #
#               firewalld                #
#                                        #
##########################################  

firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --zone=trusted --add-port=3306/tcp
firewall-cmd --reload

##########################################
#                                        #
#           httpd.conf   Setup           #
#                                        #
##########################################  

cp -av /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original
sed -i 's/DirectoryIndex index.html/ DirectoryIndex index.html index.htm index.php index.php3 index.cgi index.jsp/' /etc/httpd/conf/httpd.conf
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/httpd/conf/httpd.conf
sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/' /etc/httpd/conf/httpd.conf
sed -i 's/UserDir disabled/#UserDir disabled/' /etc/httpd/conf.d/userdir.conf
sed -i 's/#UserDir public_html/UserDir public_html/' /etc/httpd/conf.d/userdir.conf
sed -i 's/Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec/Options MultiViews SymLinksIfOwnerMatch IncludesNoExec/' /etc/httpd/conf.d/userdir.conf
sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_modul/' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/' /etc/httpd/conf.modules.d/00-mpm.conf

cp /root/APM/index.html /var/www/html/
cp -f /root/APM/index.html /usr/share/httpd/noindex/

echo "<VirtualHost *:80>
  DocumentRoot /var/www/html
</VirtualHost> " >> /etc/httpd/conf.d/default.conf

systemctl restart httpd

##########################################
#                                        #
#         PHP7.2 및 라이브러리 install      #
#                                        #
########################################## 

yum -y --enablerepo=remi,remi-php72 install php
yum -y install GeoIP GeoIP-data GeoIP-devel mod_geoip
yum -y --enablerepo=remi,remi-php72 install php-cli php-fpm \
php-common php-devel php-gd php-imap php-json php-ldap \
php-mbstring php-mcrypt php-mysqlnd php-opcache php-soap php-xml \
php-iconv php-xmlrpc php-pdo uwsgi-plugin-php php-ioncube-loader php-pecl-apcu \
php-pecl-geoip php-pecl-imagick php-pecl-memcached php-pecl-redis php-pecl-xdebug php-pecl-ssh2 \
php-pecl-mailparse php-pgsql php-process php-snmp php-soap phpMyAdmin

echo "#geoip setup
<IfModule mod_geoip.c>
 GeoIPEnable On
 GeoIPDBFile /usr/share/GeoIP/GeoIP.dat MemoryCache
</IfModule>" > /etc/httpd/conf.d/geoip.conf

cp -av /etc/php.ini /etc/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/php.ini 
sed -i 's/cookie/http/' /etc/phpMyAdmin/config.inc.php
sed -i 's/Require local/Require all granted/' /etc/httpd/conf.d/phpMyAdmin.conf

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/php.ini

mkdir /etc/skel/public_html

chmod 707 /etc/skel/public_html

chmod 700 /root/APM/adduser.sh

chmod 700 /root/APM/deluser.sh

cp /root/APM/skel/index.html /etc/skel/public_html/

systemctl restart httpd

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php.ini

systemctl restart httpd

echo '<?php
phpinfo();
?>' >> /var/www/html/phpinfo.php

##########################################
#                                        #
#          MARIADB 10.3.X install        #
#                                        #
########################################## 

# MariaDB 10.3.x 설치
yum -y install MariaDB-server MariaDB-client

# MariaDB my.cnf 복사
#cp -av /usr/share/mysql/my-huge.cnf /etc/my.cnf.d/

systemctl enable mariadb

systemctl start mariadb

# S.M.A.R.T. 디스크 모니터링을 설치
yum -y install smartmontools

systemctl enable smartd

systemctl start smartd

##########################################
#                                        #
#            mysql root 설정              #
#                                        #
##########################################

/usr/bin/mysql_secure_installation

##########################################
#                                        #
#        운영 및 보안 관련 추가 설정          #
#                                        #
##########################################

cd /root/APM

#chkrootkit 설치
wget ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz 

tar xvfz chkrootkit.tar.gz

mv chkrootkit-* chkrootkit

cd chkrootkit

make sense

rm -rf /root/APM/chkrootkit.tar.gz

#mod_evasive mod_security mod_security_crs mod_qos fail2ban.noarch arpwatch 설치
yum -y install mod_evasive mod_security mod_security_crs mod_qos fail2ban.noarch arpwatch

sed -i 's/SecDefaultAction \"phase:1,deny,log\"/SecDefaultAction \"phase:1,deny,log,auditlog\"/' /etc/httpd/modsecurity.d/modsecurity_crs_10_config.conf
sed -i 's/SecDefaultAction \"phase:2,deny,log\"/SecDefaultAction \"phase:2,deny,log,auditlog\"/' /etc/httpd/modsecurity.d/modsecurity_crs_10_config.conf
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/httpd/conf.d/mod_security.conf

echo "## QoS Settings
<IfModule mod_qos.c>
    QS_ClientEntries 100000
    QS_SrvMaxConnPerIP 50
    MaxClients              256 
    QS_SrvMaxConnClose      180
</IfModule>" >> /etc/httpd/conf.d/mod_qos.conf

#fail2ban 설치
service fail2ban start
chkconfig --level 2345 fail2ban on
service arpwatch start
sed -i 's,\(#filter = sshd-aggressive\),\1\nenabled = true,g;' /etc/fail2ban/jail.conf 

#clamav 설치
yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

cp /usr/share/doc/clamd-0.101.1/clamd.conf /etc/clamd.conf

sed -i '/^Example/d' /etc/clamd.conf
sed -i 's/User <USER>/User clamscan/' /etc/clamd.conf
sed -i 's/#LocalSocket /LocalSocket /' /etc/clamd.conf
sed -i 's/clamd.<SERVICE>/clamd.scan/' /etc/clamd.conf

chmod 755 /var/run/clamd.scan

sed 's/710/755/' /usr/lib/tmpfiles.d/clamd.scan.conf > /etc/tmpfiles.d/clamd.scan.conf
cp /etc/freshclam.conf /etc/freshclam.conf.bak
sed -i '/^Example/d' /etc/freshclam.conf

echo "# Run the freshclam as daemon
[Unit]
Description = freshclam scanner
After = network.target
[Service]
Type = forking
ExecStart = /usr/bin/freshclam -d -c 4
Restart = on-failure
PrivateTmp = true
[Install]
WantedBy=multi-user.target" >> /usr/lib/systemd/system/clam-freshclam.service

systemctl enable clam-freshclam.service
systemctl start clam-freshclam.service
mv /usr/lib/systemd/system/clamd\@.service /usr/lib/systemd/system/clamd.service
mv /usr/lib/systemd/system/clamd\@scan.service /usr/lib/systemd/system/clamd-scan.service
sed -i 's/clamd@.service/clamd.service/' /usr/lib/systemd/system/clamd-scan.service
rm -rf /usr/lib/systemd/system/clamd.service

echo "[Unit]
Description = clamd scanner daemon
After = syslog.target nss-lookup.target network.target

[Service]
Type = simple
ExecStart = /usr/sbin/clamd -c /etc/clamd.conf --foreground=yes
Restart = on-failure
PrivateTmp = true

[Install]
WantedBy=multi-user.target" >> /usr/lib/systemd/system/clamd.service

sed -i '/^Example$/d' /etc/clamd.d/scan.conf
sed -i -e 's/#LocalSocket \/var\/run\/clamd.scan\/clamd.sock/LocalSocket \/var\/run\/clamd.scan\/clamd.sock/g' /etc/clamd.d/scan.conf

systemctl enable clamd.service
systemctl enable clamd-scan.service
systemctl start clamd.service
systemctl start clamd-scan.service

mkdir /virus
mkdir /backup

#memcache 설치
yum -y install memcached python-memcached
yum -y --enablerepo=remi,remi-php72 install php-pecl-memcache
systemctl start memcached
systemctl enable memcached
systemctl restart memcached
systemctl restart httpd

echo "#mod_expires configuration" > /tmp/httpd.conf_tempfile
echo "<IfModule mod_expires.c>"   >> /tmp/httpd.conf_tempfile
echo "    ExpiresActive On"    >> /tmp/httpd.conf_tempfile
echo "    ExpiresDefault \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/css \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/javascript \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType text/x-javascript \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/x-javascript \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/javascript \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/jpeg \"access plus 1 days\""    >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/gif \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/png \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/bmp \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/cgm \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType image/tiff \"access plus 1 days\""       >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/basic \"access plus 1 days\""      >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/midi \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/mpeg \"access plus 1 days\""        >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-aiff \"access plus 1 days\""  >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-mpegurl \"access plus 1 days\"" >> /tmp/httpd.conf_tempfile
echo "	  ExpiresByType audio/x-pn-realaudio \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType audio/x-wav \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "    ExpiresByType application/x-shockwave-flash \"access plus 1 days\""   >> /tmp/httpd.conf_tempfile
echo "</IfModule>"   >> /tmp/httpd.conf_tempfile
cat /tmp/httpd.conf_tempfile >> /etc/httpd/conf.d/mod_expires.conf
rm -f /tmp/httpd.conf_tempfile

##########################################
#                                        #
#            Local SSL 설정               #
#                                        #
##########################################

mv /root/APM/etc/cron.daily/backup /etc/cron.daily/
mv /root/APM/etc/cron.daily/check_chkrootkit /etc/cron.daily/
mv /root/APM/etc/cron.daily/letsencrypt-renew /etc/cron.daily/

chmod 700 /etc/cron.daily/backup
chmod 700 /etc/cron.daily/check_chkrootkit
chmod 700 /etc/cron.daily/letsencrypt-renew

echo "00 20 * * * /root/check_chkrootkit" >> /etc/crontab
echo "01 02,14 * * * /etc/cron.daily/letsencrypt-renew" >> /etc/crontab
echo "02 1 * * * clamscan -r /home --move=/virus" >> /etc/crontab

#openssl 로 디피-헬만 파라미터(dhparam) 키 만들기 둘중 하나 선택
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#중요 폴더 및 파일 링크
ln -s /etc/letsencrypt /root/APM/letsencrypt
ln -s /etc/httpd/conf.d /root/APM/conf.d
ln -s /etc/my.cnf /root/APM/my.cnf
ln -s /etc/php.ini /root/APM/php.ini

#설치 파일 삭제
rm -rf /root/APM/etc
rm -rf /root/APM/skel
rm -rf /root/APM/index.html

service httpd restart
echo ""
echo ""
echo "축하 드립니다. APMinstaller 모든 작업이 끝났습니다."

rm -rf /root/APM/APMinstaller.sh

exit 0

