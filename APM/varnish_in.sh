#!/bin/bash

##########################################################
# * varnish 4.0.x.x Install & setup                      #
# * Created Date    : 2019/1/25                          #
# * Created by  : Joo Sung ( webmaster@apachezone.com )  # 
##########################################################

echo "
 =======================================================

               < Varnish Cache 추가하기>

 =======================================================
"
echo "설치 하시겠습니까? 'Y' or 'N'"
read YN
YN=`echo $YN | tr "a-z" "A-Z"`
 
if [ "$YN" != "Y" ]
then
    echo "설치 중단."
    exit
fi

echo""
echo "설치를 시작 합니다."

#Install varnish on CentOS
yum -y install varnish

#varnish start & enable
systemctl start varnish
systemctl enable varnish

#Configure Apache on port 8080
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/httpd.conf
sed -i 's/ServerName localhost:80/ServerName localhost:8080/' /etc/httpd/conf/httpd.conf
sed -i 's/*:80/*:8080/' /etc/httpd/conf.d/default.conf
sed -i 's/*:80/*:8080/' /root/APM/adduser.sh
sed -i 's/VARNISH_LISTEN_PORT=6081/VARNISH_LISTEN_PORT=80/' /etc/varnish/varnish.params

#Apache & varnish restart
systemctl restart httpd
systemctl restart varnish

echo ""
echo ""
echo "Varnish Cache 설치 완료!"
echo ""
exit;

esac
