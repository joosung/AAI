#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * CentOS APMinstaller v.1.5.6                                                     #
# * CentOS 7.X   Minimal ISO                                                        #
# * Apache 2.4.X , MariaDB 10.5.X, Multi-PHP(base php7.2) setup shell script        #
# * Created Date    : 2021/12/17                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

##########################################
#                                        #
#           repositories install         #
#                                        #
########################################## 

yum -y install wget openssh-clients bind-utils git nc vim-enhanced man ntsysv \
iotop sysstat strace lsof mc lrzsz zip unzip bzip2 glibc* net-tools bind ntp gcc dnf \
libxml2-devel libXpm-devel gmp-devel libicu-devel t1lib-devel aspell-devel openssl-devel \
bzip2-devel libcurl-devel libjpeg-devel libvpx-devel libpng-devel freetype-devel readline-devel \
libxslt-devel pcre-devel curl-devel mysql-devel ncurses-devel autoconf autogen automake zlib-devel libuuid-devel \
gettext-devel net-snmp-devel libevent-devel libtool-ltdl-devel postgresql-devel bison make pkgconfig firewalld yum-utils

cd /etc/yum.repos.d && wget https://repo.codeit.guru/codeit.mainline.el`rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release)`.repo

yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install http://rpms.remirepo.net/enterprise/remi-release-7.rpm

yum install -y epel-release

echo "[mariadb]" > /etc/yum.repos.d/MariaDB.repo
echo "name = MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "baseurl = http://yum.mariadb.org/10.5/rhel7-amd64" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgkey=https://yum.mariadb.org/RPM-GPG-KEY-MariaDB" >> /etc/yum.repos.d/MariaDB.repo
echo "gpgcheck=1" >> /etc/yum.repos.d/MariaDB.repo 

yum -y update

systemctl start firewalld 
systemctl enable firewalld

systemctl start named.service
systemctl enable  named.service

systemctl start ntpd.service
systemctl enable  ntpd.service
ntpdate -d 0.centos.pool.ntp.org

cd /root/AAI/APM

##########################################
#                                        #
#           SELINUX disabled             #
#                                        #
##########################################

sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
/usr/sbin/setenforce 0

##########################################
#                                        #
#           아파치 및 HTTP2 설치            #
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
firewall-cmd --permanent --zone=public --add-port=3306/tcp
firewall-cmd --permanent --zone=public --add-port=19999/tcp
firewall-cmd --permanent --zone=public --add-port=9090/tcp
firewall-cmd --reload

##########################################
#                                        #
#           httpd.conf   Setup           #
#                                        #
##########################################  


sed -i '/nameserver/i\nameserver 127.0.0.1' /etc/resolv.conf
cp -av /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.original

sed -i 's/DirectoryIndex index.html/ DirectoryIndex index.html index.htm index.php index.php3 index.cgi index.jsp/' /etc/httpd/conf/httpd.conf
sed -i 's/Options Indexes FollowSymLinks/Options FollowSymLinks/' /etc/httpd/conf/httpd.conf
sed -i 's/#ServerName www.example.com:80/ServerName localhost:80/' /etc/httpd/conf/httpd.conf
sed -i 's/AllowOverride none/AllowOverride All/' /etc/httpd/conf/httpd.conf
sed -i 's/#AddHandler cgi-script .cgi/AddHandler cgi-script .cgi/' /etc/httpd/conf/httpd.conf
sed -i '/AddType application\/x-gzip .gz .tgz/a\    AddType application\/x-httpd-php .htm .html .php .ph php3 .php4 .phtml .inc' /etc/httpd/conf/httpd.conf
sed -i '/AddType application\/x-httpd-php .htm .html .php .ph php3 .php4 .phtml .inc/a\    AddType application/x-httpd-php-source .phps' /etc/httpd/conf/httpd.conf
sed -i 's/UserDir disabled/#UserDir disabled/' /etc/httpd/conf.d/userdir.conf
sed -i 's/#UserDir public_html/UserDir public_html/' /etc/httpd/conf.d/userdir.conf
sed -i 's/Options MultiViews Indexes SymLinksIfOwnerMatch IncludesNoExec/Options MultiViews SymLinksIfOwnerMatch IncludesNoExec/' /etc/httpd/conf.d/userdir.conf
sed -i 's/LoadModule mpm_prefork_module/#LoadModule mpm_prefork_modul/' /etc/httpd/conf.modules.d/00-mpm.conf
sed -i 's/#LoadModule mpm_event_module/LoadModule mpm_event_module/' /etc/httpd/conf.modules.d/00-mpm.conf

cp /root/AAI/APM/index.html /var/www/html/
cp -f /root/AAI/APM/index.html /usr/share/httpd/noindex/

echo "<VirtualHost *:80>
  DocumentRoot /var/www/html
</VirtualHost> " >> /etc/httpd/conf.d/default.conf

systemctl restart httpd
systemctl restart named.service

##########################################
#                                        #
#      Multi PHP 및 라이브러리 install      #
#                                        #
########################################## 

yum-config-manager --enable remi-php72
yum -y install php 

yum -y install php54 php54-php-cli php54-php-fpm \
php54-php-common php54-php-pdo php54-php-mysqlnd php54-php-mbstring php54-php-mcrypt \
php54-php-opcache php54-php-xml php54-php-pecl-imagick php54-php-gd php54-php-fileinfo \
php54-php-pecl-ssh2 php54-php-soap php54-php-devel php54-php-imap \
php54-php-json php54-php-ldap php54-php-xml php54-php-iconv php54-php-xmlrpc php54-php-snmp \
php54-php-pecl-apcu php54-php-pecl-geoip php54-php-pecl-memcached php54-php-pecl-redis \
php54-php-pecl-xdebug php54-php-pecl-mailparse php54-php-pgsql php54-php-process php54-php-ioncube-loader

yum -y install php55 php55-php-cli php55-php-fpm \
php55-php-common php55-php-pdo php55-php-mysqlnd php55-php-mbstring php55-php-mcrypt \
php55-php-opcache php55-php-xml php55-php-pecl-imagick php55-php-gd php55-php-fileinfo \
php55-php-pecl-ssh2 php55-php-soap php55-php-devel php55-php-imap \
php55-php-json php55-php-ldap php55-php-xml php55-php-iconv php55-php-xmlrpc php55-php-snmp \
php55-php-pecl-apcu php55-php-pecl-geoip php55-php-pecl-memcached php55-php-pecl-redis \
php55-php-pecl-xdebug php55-php-pecl-mailparse php55-php-pgsql php55-php-process php55-php-ioncube-loader

yum -y install php56 php56-php-cli php56-php-fpm \
php56-php-common php56-php-pdo php56-php-mysqlnd php56-php-mbstring php56-php-mcrypt \
php56-php-opcache php56-php-xml php56-php-pecl-imagick php56-php-gd php56-php-fileinfo \
php56-php-pecl-ssh2 php56-php-soap php56-php-devel php56-php-imap php56-php-json php56-php-mysql \
php56-php-ldap php56-php-xml php56-php-iconv php56-php-xmlrpc php56-php-snmp php56-php-pgsql \
php56-php-pecl-apcu php56-php-pecl-geoip php56-php-pecl-memcached php56-php-pecl-redis \
php56-php-pecl-xdebug php56-php-pecl-mailparse php56-php-process php56-php-ioncube-loader

yum -y install php70 php70-php-cli php70-php-fpm \
php70-php-common php70-php-pdo php70-php-mysqlnd php70-php-mbstring php70-php-mcrypt \
php70-php-opcache php70-php-xml php70-php-pecl-imagick php70-php-gd php70-php-fileinfo \
php70-php-pecl-mysql php70-php-pecl-ssh2 php70-php-soap php70-php-devel php70-php-imap \
php70-php-json php70-php-ldap php70-php-xml php70-php-iconv php70-php-xmlrpc php70-php-snmp \
php70-php-pecl-apcu php70-php-pecl-geoip php70-php-pecl-memcached php70-php-pecl-redis \
php70-php-pecl-xdebug php70-php-pecl-mailparse php70-php-pgsql php70-php-process php70-php-ioncube-loader

yum -y install php71 php71-php-cli php71-php-fpm \
php71-php-common php71-php-pdo php71-php-mysqlnd php71-php-mbstring php71-php-mcrypt \
php71-php-opcache php71-php-xml php71-php-pecl-imagick php71-php-gd php71-php-fileinfo \
php71-php-pecl-mysql php71-php-pecl-ssh2 php71-php-soap php71-php-devel php71-php-imap \
php71-php-json php71-php-ldap php71-php-xml php71-php-iconv php71-php-xmlrpc php71-php-snmp \
php71-php-pecl-apcu php71-php-pecl-geoip php71-php-pecl-memcached php71-php-pecl-redis \
php71-php-pecl-xdebug php71-php-pecl-mailparse php71-php-pgsql php71-php-process php71-php-ioncube-loader

yum -y install php72 php72-php-cli php72-php-fpm \
php72-php-common php72-php-pdo php72-php-mysqlnd php72-php-mbstring php72-php-mcrypt \
php72-php-opcache php72-php-xml php72-php-pecl-imagick php72-php-gd php72-php-fileinfo \
php72-php-pecl-mysql php72-php-pecl-ssh2 php72-php-soap php72-php-devel php72-php-imap \
php72-php-json php72-php-ldap php72-php-xml php72-php-iconv php72-php-xmlrpc php72-php-snmp \
php72-php-pecl-apcu php72-php-pecl-geoip php72-php-pecl-memcached php72-php-pecl-redis \
php72-php-pecl-xdebug php72-php-pecl-mailparse php72-php-pgsql php72-php-process php72-php-ioncube-loader

yum -y install php73 php73-php-cli php73-php-fpm \
php73-php-common php73-php-pdo php73-php-mysqlnd php73-php-mbstring php73-php-mcrypt \
php73-php-opcache php73-php-xml php73-php-pecl-imagick php73-php-gd php73-php-fileinfo \
php73-php-pecl-mysql php73-php-pecl-ssh2 php73-php-soap php73-php-devel php73-php-imap \
php73-php-json php73-php-ldap php73-php-xml php73-php-iconv php73-php-xmlrpc php73-php-snmp \
php73-php-pecl-apcu php73-php-pecl-geoip php73-php-pecl-memcached php73-php-pecl-redis \
php73-php-pecl-xdebug php73-php-pecl-mailparse php73-php-pgsql php73-php-process php73-php-ioncube-loader

yum -y install php74 php74-php-cli php74-php-fpm \
php74-php-common php74-php-pdo php74-php-mysqlnd php74-php-mbstring php74-php-mcrypt \
php74-php-opcache php74-php-xml php74-php-pecl-imagick php74-php-gd php74-php-fileinfo \
php74-php-pecl-mysql php74-php-pecl-ssh2 php74-php-soap php74-php-devel php74-php-imap \
php74-php-json php74-php-ldap php74-php-xml php74-php-iconv php74-php-xmlrpc php74-php-snmp \
php74-php-pecl-apcu php74-php-pecl-geoip php74-php-pecl-memcached php74-php-pecl-redis \
php74-php-pecl-xdebug php74-php-pecl-mailparse php74-php-pgsql php74-php-process php74-php-ioncube-loader

##php8에서는 아직 지원 안됨 - php80-php-pecl-mysql php80-php-ioncube-loader
yum -y install php80 php80-php-cli php80-php-fpm \
php74-php-common php80-php-pdo php80-php-mysqlnd php80-php-mbstring php80-php-mcrypt \
php80-php-opcache php80-php-xml php80-php-pecl-imagick php80-php-gd php80-php-fileinfo \
php80-php-pecl-ssh2 php80-php-soap php80-php-devel php80-php-imap \
php80-php-json php80-php-ldap php80-php-xml php80-php-iconv php80-php-xmlrpc php80-php-snmp \
php80-php-pecl-apcu php80-php-pecl-geoip php80-php-pecl-memcached php80-php-pecl-redis \
php80-php-pecl-xdebug php80-php-pecl-mailparse php80-php-pgsql php80-php-process

##php8에서는 아직 지원 안됨 - php81-php-pecl-mysql php81-php-ioncube-loader
yum -y install php81 php81-php-cli php81-php-fpm \
php74-php-common php81-php-pdo php81-php-mysqlnd php81-php-mbstring php81-php-mcrypt \
php81-php-opcache php81-php-xml php81-php-pecl-imagick php81-php-gd php81-php-fileinfo \
php81-php-pecl-ssh2 php81-php-soap php81-php-devel php81-php-imap \
php81-php-json php81-php-ldap php81-php-xml php81-php-iconv php81-php-xmlrpc php81-php-snmp \
php81-php-pecl-apcu php81-php-pecl-geoip php81-php-pecl-memcached php81-php-pecl-redis \
php81-php-pecl-xdebug php81-php-pecl-mailparse php81-php-pgsql php81-php-process

echo 'listen = 127.0.0.1:9054
pm = ondemand' >> /opt/remi/php54/root/etc/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9055
pm = ondemand' >> /opt/remi/php55/root/etc/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9056
pm = ondemand' >> /opt/remi/php56/root/etc/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9070
pm = ondemand' >> /etc/opt/remi/php70/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9071
pm = ondemand' >> /etc/opt/remi/php71/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9072
pm = ondemand' >> /etc/opt/remi/php72/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9073
pm = ondemand' >> /etc/opt/remi/php73/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9074
pm = ondemand' >> /etc/opt/remi/php74/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9080
pm = ondemand' >> /etc/opt/remi/php80/php-fpm.d/www.conf

echo 'listen = 127.0.0.1:9081
pm = ondemand' >> /etc/opt/remi/php81/php-fpm.d/www.conf

#systemctl start php-fpm
#systemctl enable php-fpm

systemctl start php54-php-fpm
systemctl enable php54-php-fpm

systemctl start php55-php-fpm
systemctl enable php55-php-fpm

systemctl start php56-php-fpm
systemctl enable php56-php-fpm

systemctl start php70-php-fpm
systemctl enable php70-php-fpm

systemctl start php71-php-fpm
systemctl enable php71-php-fpm

systemctl start php72-php-fpm
systemctl enable php72-php-fpm

systemctl start php73-php-fpm
systemctl enable php73-php-fpm

systemctl start php74-php-fpm
systemctl enable php74-php-fpm

systemctl start php80-php-fpm
systemctl enable php80-php-fpm

systemctl start php81-php-fpm
systemctl enable php81-php-fpm

sed -i 's/php_value/#php_value/' /etc/httpd/conf.d/php.conf

echo '<Files ".user.ini">
  Require all denied
</Files>
AddType text/html .php
DirectoryIndex index.php
SetEnvIfNoCase ^Authorization$ "(.+)" HTTP_AUTHORIZATION=$1
<FilesMatch \.php$>
  SetHandler "proxy:fcgi://127.0.0.1:9072"
</FilesMatch>' >> /etc/httpd/conf.d/php.conf

yum -y install GeoIP GeoIP-data GeoIP-devel mod_geoip

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

cp -av /opt/remi/php54/root/etc/php.ini /opt/remi/php54/root/etc/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /opt/remi/php54/root/etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /opt/remi/php54/root/etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /opt/remi/php54/root/etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /opt/remi/php54/root/etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /opt/remi/php54/root/etc/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /opt/remi/php54/root/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /opt/remi/php54/root/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /opt/remi/php54/root/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /opt/remi/php54/root/etc/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /opt/remi/php54/root/etc/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /opt/remi/php54/root/etc/php.ini 

cp -av /opt/remi/php55/root/etc/php.ini /opt/remi/php55/root/etc/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /opt/remi/php55/root/etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /opt/remi/php55/root/etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /opt/remi/php55/root/etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /opt/remi/php55/root/etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /opt/remi/php55/root/etc/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /opt/remi/php55/root/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /opt/remi/php55/root/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /opt/remi/php55/root/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /opt/remi/php55/root/etc/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /opt/remi/php55/root/etc/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /opt/remi/php55/root/etc/php.ini 

cp -av /opt/remi/php56/root/etc/php.ini /opt/remi/php56/root/etc/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /opt/remi/php56/root/etc/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /opt/remi/php56/root/etc/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /opt/remi/php56/root/etc/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /opt/remi/php56/root/etc/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /opt/remi/php56/root/etc/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /opt/remi/php56/root/etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /opt/remi/php56/root/etc/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /opt/remi/php56/root/etc/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /opt/remi/php56/root/etc/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /opt/remi/php56/root/etc/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /opt/remi/php56/root/etc/php.ini 

cp -av /etc/opt/remi/php70/php.ini /etc/opt/remi/php70/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php70/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php70/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php70/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php70/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php70/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php70/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php70/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php70/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php70/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php70/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php70/php.ini 

cp -av /etc/opt/remi/php71/php.ini /etc/opt/remi/php71/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php71/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php71/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php71/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php71/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php71/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php71/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php71/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php71/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php71/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php71/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php71/php.ini 

cp -av /etc/opt/remi/php72/php.ini /etc/opt/remi/php72/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php72/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php72/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php72/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php72/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php72/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php72/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php72/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php72/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php72/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php72/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php72/php.ini 

cp -av /etc/opt/remi/php73/php.ini /etc/opt/remi/php73/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php73/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php73/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php73/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php73/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php73/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php73/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php73/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php73/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php73/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php73/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php73/php.ini 

cp -av /etc/opt/remi/php74/php.ini /etc/opt/remi/php74/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php74/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php74/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php74/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php74/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php74/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php74/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php74/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php74/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php74/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php74/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php74/php.ini 

cp -av /etc/opt/remi/php80/php.ini /etc/opt/remi/php80/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php80/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php80/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php80/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php80/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php80/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php80/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php80/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php80/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php80/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php80/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php80/php.ini 

cp -av /etc/opt/remi/php81/php.ini /etc/opt/remi/php81/php.ini.original
sed -i 's/short_open_tag = Off/short_open_tag = On/' /etc/opt/remi/php81/php.ini
sed -i 's/expose_php = On/expose_php = Off/' /etc/opt/remi/php81/php.ini
sed -i 's/display_errors = Off/display_errors = On/' /etc/opt/remi/php81/php.ini
sed -i 's/;error_log = php_errors.log/error_log = php_errors.log/' /etc/opt/remi/php81/php.ini
sed -i 's/error_reporting = E_ALL \& ~E_DEPRECATED/error_reporting = E_ALL \& ~E_NOTICE \& ~E_DEPRECATED \& ~E_USER_DEPRECATED/' /etc/opt/remi/php81/php.ini
sed -i 's/variables_order = "GPCS"/variables_order = "EGPCS"/' /etc/opt/remi/php81/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 100M/' /etc/opt/remi/php81/php.ini
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 100M/' /etc/opt/remi/php81/php.ini
sed -i 's/;date.timezone =/date.timezone = "Asia\/Seoul"/' /etc/opt/remi/php81/php.ini
sed -i 's/session.gc_maxlifetime = 1440/session.gc_maxlifetime = 86400/' /etc/opt/remi/php81/php.ini
sed -i 's/disable_functions =/disable_functions = system,exec,passthru,proc_open,popen,curl_multi_exec,parse_ini_file,show_source/' /etc/opt/remi/php81/php.ini 


echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /opt/remi/php54/root/etc/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /opt/remi/php55/root/etc/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /opt/remi/php56/root/etc/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php70/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php71/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php72/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php73/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php74/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php80/php.ini

echo "[xdebug]
xdebug.remote_autostart = 1
xdebug.remote_connect_back = 1
xdebug.remote_enable = 1
xdebug.remote_port = 9009
xdebug.remote_handler = dbgp" >> /etc/opt/remi/php81/php.ini

mkdir /etc/skel/public_html

chmod 707 /etc/skel/public_html

chmod 700 /root/AAI/adduser.sh

chmod 700 /root/AAI/deluser.sh

chmod 700 /root/AAI/restart.sh

chmod 700 /root/AAI/clamav.sh

cp /root/AAI/APM/skel/index.html /etc/skel/public_html/

systemctl restart httpd

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ && ln -s /usr/local/bin/composer.phar /usr/local/bin/composer

sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /opt/remi/php54/root/etc/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /opt/remi/php55/root/etc/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /opt/remi/php56/root/etc/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php70/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php71/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php72/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php73/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php74/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php80/php.ini
sed -i 's/allow_url_fopen = On/allow_url_fopen = Off/' /etc/opt/remi/php81/php.ini

systemctl restart httpd

echo '<?php
phpinfo();
?>' >> /var/www/html/phpinfo.php

##########################################
#                                        #
#          MARIADB 10.5.X install        #
#                                        #
########################################## 

# MariaDB 10.5.x 설치
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
#                mysql 설정               #
#                                        #
##########################################

echo "[mysql]
default-character-set = utf8mb4
 
[mysqld]
character-set-client-handshake=FALSE
init_connect="SET collation_connection = utf8mb4_unicode_ci"
init_connect="SET NAMES utf8mb4"
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
  
[client]
default-character-set = utf8mb4" > /etc/my.cnf.d/mysql-aai.cnf

/usr/bin/mysql_secure_installation

##########################################
#                                        #
#        운영 및 보안 관련 추가 설정           #
#                                        #
##########################################

cd /root/AAI/

#chkrootkit 설치
#wget ftp://ftp.pangeia.com.br/pub/seg/pac/chkrootkit.tar.gz 

tar xvfz chkrootkit.tar.gz

mv chkrootkit-* chkrootkit

cd chkrootkit

make sense

rm -rf /root/AAI/chkrootkit.tar.gz

#mod_evasive mod_security fail2ban.noarch arpwatch 설치
yum -y install mod_evasive mod_security mod_security_crs fail2ban.noarch arpwatch

sed -i 's/SecDefaultAction \"phase:1,deny,log\"/SecDefaultAction \"phase:1,deny,log,auditlog\"/' /etc/httpd/modsecurity.d/modsecurity_crs_10_config.conf
sed -i 's/SecDefaultAction \"phase:2,deny,log\"/SecDefaultAction \"phase:2,deny,log,auditlog\"/' /etc/httpd/modsecurity.d/modsecurity_crs_10_config.conf
sed -i 's/SecRuleEngine On/SecRuleEngine DetectionOnly/' /etc/httpd/conf.d/mod_security.conf

sed -i 's/DOSPageCount        2/DOSPageCount        100/' /etc/httpd/conf.d/mod_evasive.conf
sed -i 's/DOSSiteCount        50/DOSSiteCount        100/' /etc/httpd/conf.d/mod_evasive.conf

#fail2ban 설치
service fail2ban start
chkconfig --level 2345 fail2ban on
service arpwatch start
sed -i 's,\(#filter = sshd-aggressive\),\1\nenabled = true,g;' /etc/fail2ban/jail.conf 
service arpwatch restart

#clamav 설치
yum -y install clamav-server clamav-data clamav-update clamav-filesystem clamav clamav-scanner-systemd clamav-devel clamav-lib clamav-server-systemd

cp /usr/share/doc/clamd-0.103.4/clamd.conf /etc/clamd.conf

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

systemctl start clamd.service

systemctl stop clamd.service


mkdir /virus
mkdir /backup
mkdir /root/AAI/php

#memcache 설치
yum -y install memcached python-memcached php-pecl-memcache memcached-devel
#yum -y install php54-php-pecl-memcache php55-php-pecl-memcache php56-php-pecl-memcache php70-php-pecl-memcache php71-php-pecl-memcache php72-php-pecl-memcache php73-php-pecl-memcache php74-php-pecl-memcache php80-php-pecl-memcache

sed -i 's/OPTIONS=""/OPTIONS="-l 127.0.0.1"/' /etc/sysconfig/memcached

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

mv /root/AAI/APM/etc/cron.daily/backup /etc/cron.daily/
mv /root/AAI/APM/etc/cron.daily/check_chkrootkit /etc/cron.daily/
mv /root/AAI/APM/etc/cron.daily/letsencrypt-renew /etc/cron.daily/

chmod 700 /etc/cron.daily/backup
chmod 700 /etc/cron.daily/check_chkrootkit
chmod 700 /etc/cron.daily/letsencrypt-renew

echo "00 20 * * * /root/cron.daily/check_chkrootkit" >> /etc/crontab
echo "01 02,14 * * * /etc/cron.daily/letsencrypt-renew" >> /etc/crontab
echo "01 01 * * 7 /root/AAI/clamav.sh" >> /etc/crontab

#openssl 로 디피-헬만 파라미터(dhparam) 키 만들기 둘중 하나 선택
#openssl dhparam -out /etc/ssl/certs/dhparam.pem 4096
openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

#http2 설정
echo "
<IfModule http2_module>
ProtocolsHonorOrder On
Protocols h2 h2c http/1.1
</IfModule>" >> /etc/httpd/conf.modules.d/10-h2.conf

#중요 폴더 및 파일 링크
ln -s /etc/letsencrypt /root/AAI/letsencrypt
ln -s /etc/httpd/conf.d /root/AAI/conf.d
ln -s /etc/my.cnf.d /root/AAI/my.cnf.d
ln -s /etc/php.ini /root/AAI/php/php.ini
ln -s /opt/remi/php54/root/etc/php.ini /root/AAI/php/php54.ini
ln -s /opt/remi/php55/root/etc/php.ini /root/AAI/php/php55.ini
ln -s /opt/remi/php56/root/etc/php.ini /root/AAI/php/php56.ini
ln -s /etc/opt/remi/php70/php.ini /root/AAI/php/php70.ini
ln -s /etc/opt/remi/php71/php.ini /root/AAI/php/php71.ini
ln -s /etc/opt/remi/php72/php.ini /root/AAI/php/php72.ini
ln -s /etc/opt/remi/php73/php.ini /root/AAI/php/php73.ini
ln -s /etc/opt/remi/php74/php.ini /root/AAI/php/php74.ini
ln -s /etc/opt/remi/php80/php.ini /root/AAI/php/php80.ini
ln -s /etc/opt/remi/php81/php.ini /root/AAI/php/php81.ini

service httpd restart

cd /root/AAI

##########################################
#                                        #
#             Cockpit install            #
#                                        #
########################################## 

yum install -y cockpit cockpit-storaged

systemctl start cockpit

systemctl enable --now cockpit.socket

sh restart.sh

echo ""
echo ""
echo "축하 드립니다. APMinstaller 모든 작업이 끝났습니다."


exit 0
