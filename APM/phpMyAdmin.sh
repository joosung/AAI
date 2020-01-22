#!/bin/bash
 
#####################################################################################
#                                                                                   #
# * CentOS APMinstaller v.1.5                                                             #
# * CentOS 7.X   Minimal ISO                                                        #
# * Apache 2.4.X , MariaDB 10.3.X, Multi-PHP setup shell script                     #
# * Created Date    : 2019/11/30                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################


##########################################
#                                        #
#           phpMyAdmin install           #
#                                        #
########################################## 

yum install -y phpmyadmin

sed -i 's/Require ip 127.0.0.1/#Require ip 127.0.0.1/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i 's/Require ip ::1/#Require ip ::1/' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i '/Require ip ::1/a\       Require all granted' /etc/httpd/conf.d/phpMyAdmin.conf
sed -i 's/cookie/http/' /etc/phpMyAdmin/config.inc.php

sh /root/AAI/restart.sh

echo ""
echo ""
echo "축하 드립니다. phpMyAdmin 설치 작업이 끝났습니다."

exit 0
