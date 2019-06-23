#!/usr/bin/env bash

#####################################################################################
#                                                                                   #
# * APMinstaller v.0.3.9                                                            #
# * CentOS 7.X   Minimal ISO                                                        #
# * Apache 2.4.X , MariaDB 10.3.X, PHP 7.2.X setup shell script                     #
# * Created Date    : 2019/6/23                                                     #
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

sh APMinstaller.sh

cd /root/AAI

#설치 파일 삭제
rm -rf /root/AAI/APM

echo ""
echo ""
echo "AAI 설치 완료!"
echo ""
exit;

esac
