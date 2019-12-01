#!/usr/bin/env bash

#####################################################################################
#                                                                                   #
# * CentOS APMinstaller v.1.5                                                       #
# * CentOS 7.X   Minimal ISO                                                        #
# * Apache 2.4.X , MariaDB 10.4.X, Multi-PHP(base php7.2) setup shell script        #
# * Created Date    : 2019/11/30                                                    #
# * Created by  : Joo Sung ( webmaster@apachezone.com )                             #
#                                                                                   #
#####################################################################################

echo "
 =======================================================

               < AAI 설치 하기>

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

cd /root/AAI/APM

chmod 700 APMinstaller.sh

chmod 700 /root/AAI/adduser.sh

chmod 700 /root/AAI/deluser.sh

chmod 700 /root/AAI/restart.sh

sh APMinstaller.sh

cd /root/AAI

#설치 파일 삭제
rm -rf /root/AAI/APM

echo ""
echo ""
echo "AAI 설치 완료!"
echo ""
echo ""
echo ""

echo "
 =======================================================

               < phpMyAdmin 설치 하기>

 =======================================================
"
echo "phpMyAdmin 설치 하시겠습니까? 'Y' or 'N'"
read YN
YN=`echo $YN | tr "a-z" "A-Z"`
 
if [ "$YN" != "Y" ]
then
    echo "설치 중단."
    exit
fi

echo""
echo "phpMyAdmin 설치를 시작 합니다."
cd /root/UAAI/APM

chmod 700 phpMyAdmin.sh

sh phpMyAdmin.sh

echo ""
echo ""
echo "phpMyAdmin 설치 완료!"
echo ""
echo ""
echo ""

#설치 파일 삭제
rm -rf /root/UAAI/APM
echo ""
rm -rf /root/UAAI/install.sh
echo ""
exit;

esac
